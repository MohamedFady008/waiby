import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/store/frame_catalog.dart';
import '../models/chat_models.dart';
import '../models/user_profile.dart';
import 'user_profile_repository.dart';

class ChatRepository {
  ChatRepository({
    FirebaseFirestore? firestore,
    UserProfileRepository? userProfileRepository,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _userProfileRepository =
           userProfileRepository ??
           UserProfileRepository(
             firestore: firestore ?? FirebaseFirestore.instance,
           );

  final FirebaseFirestore _firestore;
  final UserProfileRepository _userProfileRepository;
  final Set<String> _frameBackfillInFlight = <String>{};

  CollectionReference<Map<String, dynamic>> get _conversations =>
      _firestore.collection('conversations');

  DocumentReference<Map<String, dynamic>> _conversationDoc(
    String conversationId,
  ) => _conversations.doc(conversationId);

  static String directConversationId(String firstUserId, String secondUserId) {
    final pair = <String>[firstUserId.trim(), secondUserId.trim()]..sort();
    return '${pair.first}_${pair.last}';
  }

  Stream<List<ChatConversation>> watchConversationsForUser(String userId) {
    final trimmedUserId = userId.trim();
    if (trimmedUserId.isEmpty) {
      return const Stream<List<ChatConversation>>.empty();
    }
    return _conversations
        .where('participants', arrayContains: trimmedUserId)
        .orderBy('updated_at', descending: true)
        .limit(250)
        .snapshots()
        .map((snapshot) {
          final conversations = snapshot.docs
              .map(ChatConversation.fromSnapshot)
              .toList(growable: false);
          for (final conversation in conversations) {
            _scheduleConversationFrameBackfill(conversation);
          }
          final sorted = conversations.toList(growable: false)
            ..sort((a, b) {
              final aTime = a.lastMessageAt ?? a.updatedAt ?? a.createdAt;
              final bTime = b.lastMessageAt ?? b.updatedAt ?? b.createdAt;
              if (aTime == null && bTime == null) return 0;
              if (aTime == null) return 1;
              if (bTime == null) return -1;
              return bTime.compareTo(aTime);
            });
          return sorted;
        });
  }

  Stream<List<ChatMessageRecord>> watchMessages(
    String conversationId, {
    int limit = 150,
  }) {
    final trimmedConversationId = conversationId.trim();
    if (trimmedConversationId.isEmpty) {
      return const Stream<List<ChatMessageRecord>>.empty();
    }
    return _conversationDoc(trimmedConversationId)
        .collection('messages')
        .orderBy('created_at', descending: false)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) =>
                    ChatMessageRecord.fromSnapshot(trimmedConversationId, doc),
              )
              .toList(growable: false);
        });
  }

  Future<String> ensureDirectConversation({
    required String currentUserId,
    required String otherUserId,
    String? currentUserName,
    String? currentUserAvatarUrl,
    String? otherUserName,
    String? otherUserAvatarUrl,
  }) async {
    final left = currentUserId.trim();
    final right = otherUserId.trim();
    if (left.isEmpty || right.isEmpty) {
      throw ArgumentError('Both user ids are required.');
    }
    if (left == right) {
      throw ArgumentError('Cannot create a direct conversation with self.');
    }

    final conversationId = directConversationId(left, right);
    final conversationRef = _conversationDoc(conversationId);

    final preload = await Future.wait<Object?>(<Future<Object?>>[
      _userProfileRepository.fetchById(left),
      _userProfileRepository.fetchById(right),
      _fetchUserRawData(left),
      _fetchUserRawData(right),
    ]);
    final currentProfile = preload[0] as UserProfile?;
    final otherProfile = preload[1] as UserProfile?;
    final currentRawData = preload[2] as Map<String, dynamic>?;
    final otherRawData = preload[3] as Map<String, dynamic>?;

    final resolvedCurrentName = _firstNonEmpty(<String?>[
      currentUserName,
      currentProfile?.fullName,
    ], fallback: 'User');
    final resolvedOtherName = _firstNonEmpty(<String?>[
      otherUserName,
      otherProfile?.fullName,
    ], fallback: 'User');

    final resolvedCurrentAvatar = _firstNonEmptyOrNull(<String?>[
      currentUserAvatarUrl,
      currentProfile?.avatarUrl,
    ]);
    final resolvedOtherAvatar = _firstNonEmptyOrNull(<String?>[
      otherUserAvatarUrl,
      otherProfile?.avatarUrl,
    ]);
    final resolvedCurrentFrame = _resolveProfileFrameAsset(
      profile: currentProfile,
      rawData: currentRawData,
    );
    final resolvedOtherFrame = _resolveProfileFrameAsset(
      profile: otherProfile,
      rawData: otherRawData,
    );

    final participants = <String>[left, right]..sort();
    final names = <String, String>{
      left: resolvedCurrentName,
      right: resolvedOtherName,
    };
    final avatars = <String, String>{
      left: resolvedCurrentAvatar ?? '',
      right: resolvedOtherAvatar ?? '',
    };
    final frameAssets = <String, String>{
      left: resolvedCurrentFrame ?? '',
      right: resolvedOtherFrame ?? '',
    };
    final online = <String, bool>{
      left: currentProfile?.isOnline ?? false,
      right: otherProfile?.isOnline ?? false,
    };

    await conversationRef.set(<String, dynamic>{
      'participants': participants,
      'participant_names': names,
      'participant_avatar_urls': avatars,
      'participant_frame_assets': frameAssets,
      'participant_online': online,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return conversationId;
  }

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String text,
  }) async {
    final trimmedText = text.trim();
    final trimmedSenderId = senderId.trim();
    final trimmedConversationId = conversationId.trim();

    if (trimmedText.isEmpty ||
        trimmedSenderId.isEmpty ||
        trimmedConversationId.isEmpty) {
      return;
    }

    final conversationRef = _conversationDoc(trimmedConversationId);
    final messageRef = conversationRef.collection('messages').doc();
    final senderProfileAndRaw = await Future.wait<Object?>(<Future<Object?>>[
      _userProfileRepository.fetchById(trimmedSenderId),
      _fetchUserRawData(trimmedSenderId),
    ]);
    final senderProfile = senderProfileAndRaw[0] as UserProfile?;
    final senderRawData = senderProfileAndRaw[1] as Map<String, dynamic>?;
    final senderFrameAsset =
        _resolveProfileFrameAsset(
          profile: senderProfile,
          rawData: senderRawData,
        ) ??
        '';

    await _firestore.runTransaction((transaction) async {
      final conversationSnapshot = await transaction.get(conversationRef);
      final conversationData = conversationSnapshot.data();
      if (!conversationSnapshot.exists || conversationData == null) {
        throw StateError('Conversation does not exist.');
      }

      final participantsRaw = conversationData['participants'];
      final participants = participantsRaw is Iterable
          ? participantsRaw
                .map((entry) => entry.toString().trim())
                .where((entry) => entry.isNotEmpty)
                .toSet()
          : <String>{};
      if (!participants.contains(trimmedSenderId)) {
        throw StateError('Sender is not a participant in this conversation.');
      }

      final unreadCounts = _intMap(conversationData['unread_counts']);
      for (final participant in participants) {
        if (participant == trimmedSenderId) {
          unreadCounts[participant] = 0;
          continue;
        }
        unreadCounts[participant] = (unreadCounts[participant] ?? 0) + 1;
      }

      transaction.set(messageRef, <String, dynamic>{
        'conversation_id': trimmedConversationId,
        'sender_id': trimmedSenderId,
        'text': trimmedText,
        'created_at': FieldValue.serverTimestamp(),
      });

      transaction.update(conversationRef, <String, dynamic>{
        'last_message_text': trimmedText,
        'last_message_sender_id': trimmedSenderId,
        'last_message_at': FieldValue.serverTimestamp(),
        'unread_counts': unreadCounts,
        'participant_frame_assets.$trimmedSenderId': senderFrameAsset,
        'updated_at': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> markConversationRead({
    required String conversationId,
    required String userId,
  }) async {
    final trimmedConversationId = conversationId.trim();
    final trimmedUserId = userId.trim();
    if (trimmedConversationId.isEmpty || trimmedUserId.isEmpty) {
      return;
    }

    final conversationRef = _conversationDoc(trimmedConversationId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(conversationRef);
      final data = snapshot.data();
      if (!snapshot.exists || data == null) return;

      final unreadCounts = _intMap(data['unread_counts']);
      final currentValue = unreadCounts[trimmedUserId] ?? 0;
      if (currentValue <= 0) return;

      unreadCounts[trimmedUserId] = 0;
      transaction.update(conversationRef, <String, dynamic>{
        'unread_counts': unreadCounts,
        'updated_at': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<Map<String, dynamic>?> _fetchUserRawData(String userId) async {
    final trimmedUserId = userId.trim();
    if (trimmedUserId.isEmpty) {
      return null;
    }
    final snapshot = await _firestore
        .collection('users')
        .doc(trimmedUserId)
        .get();
    final data = snapshot.data();
    if (!snapshot.exists || data == null) {
      return null;
    }
    return data;
  }

  void _scheduleConversationFrameBackfill(ChatConversation conversation) {
    if (_frameBackfillInFlight.contains(conversation.id)) {
      return;
    }

    final missingParticipants = conversation.participants
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .where((id) {
          final existing = conversation.participantFrameAssets[id]?.trim();
          return existing == null || existing.isEmpty;
        })
        .toList(growable: false);
    if (missingParticipants.isEmpty) {
      return;
    }

    _frameBackfillInFlight.add(conversation.id);
    unawaited(
      _backfillConversationFrames(
        conversationId: conversation.id,
        participantIds: missingParticipants,
      ).whenComplete(() {
        _frameBackfillInFlight.remove(conversation.id);
      }),
    );
  }

  Future<void> _backfillConversationFrames({
    required String conversationId,
    required List<String> participantIds,
  }) async {
    final updates = <String, dynamic>{};
    for (final participantId in participantIds) {
      final profileRawData = await _fetchUserRawData(participantId);
      final frameAssetPath = _resolveProfileFrameAsset(rawData: profileRawData);
      if (frameAssetPath != null && frameAssetPath.isNotEmpty) {
        updates['participant_frame_assets.$participantId'] = frameAssetPath;
      }
    }
    if (updates.isEmpty) {
      return;
    }
    try {
      await _conversationDoc(conversationId).update(updates);
    } catch (_) {
      // Ignore transient failures; next snapshots will retry as needed.
    }
  }
}

Map<String, int> _intMap(dynamic value) {
  if (value is! Map) return <String, int>{};
  final result = <String, int>{};
  value.forEach((key, entryValue) {
    if (entryValue is int) {
      result[key.toString()] = entryValue;
    } else if (entryValue is num) {
      result[key.toString()] = entryValue.toInt();
    }
  });
  return result;
}

String _firstNonEmpty(Iterable<String?> values, {String? fallback}) {
  for (final value in values) {
    final trimmed = value?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      return trimmed;
    }
  }
  return fallback ?? '';
}

String? _firstNonEmptyOrNull(Iterable<String?> values) {
  for (final value in values) {
    final trimmed = value?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      return trimmed;
    }
  }
  return null;
}

String? _resolveProfileFrameAsset({
  UserProfile? profile,
  Map<String, dynamic>? rawData,
}) {
  final normalizedRawData = _toStringKeyMap(rawData);
  final normalizedRawMetadata = _toStringKeyMap(normalizedRawData['metadata']);
  final normalizedProfileMetadata = _toStringKeyMap(profile?.metadata);
  final candidateSources = <Map<String, dynamic>>[
    normalizedRawData,
    normalizedRawMetadata,
    normalizedProfileMetadata,
  ];

  const directFrameKeys = <String>[
    'profile_frame_asset',
    'active_frame_asset',
    'profileFrameAsset',
    'activeFrameAsset',
  ];
  final directFrameCandidate = _firstNonEmptyOrNull(
    candidateSources.expand(
      (source) => directFrameKeys.map((key) => source[key]?.toString()),
    ),
  );
  if (directFrameCandidate != null) {
    final mappedDirectCandidate = frameAssetPathById(directFrameCandidate);
    return mappedDirectCandidate ?? directFrameCandidate;
  }

  const frameIdKeys = <String>[
    'active_frame_id',
    'profile_frame_id',
    'activeFrameId',
    'profileFrameId',
  ];
  final frameIdCandidate = _firstNonEmptyOrNull(
    candidateSources.expand(
      (source) => frameIdKeys.map((key) => source[key]?.toString()),
    ),
  );
  if (frameIdCandidate == null) {
    return null;
  }
  return frameAssetPathById(frameIdCandidate);
}

Map<String, dynamic> _toStringKeyMap(dynamic value) {
  if (value is! Map) {
    return <String, dynamic>{};
  }
  final result = <String, dynamic>{};
  value.forEach((key, entryValue) {
    result[key.toString()] = entryValue;
  });
  return result;
}
