import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

import '../core/config/app_config.dart';
import '../data/models/live_room_models.dart';
import '../data/repositories/user_profile_repository.dart';

class LiveRoomException implements Exception {
  final String message;

  const LiveRoomException(this.message);

  @override
  String toString() => message;
}

class LiveRoomService {
  LiveRoomService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    http.Client? httpClient,
    UserProfileRepository? userProfileRepository,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _httpClient = httpClient ?? http.Client(),
       _userProfileRepository =
           userProfileRepository ??
           UserProfileRepository(
             firestore: firestore ?? FirebaseFirestore.instance,
           );

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final http.Client _httpClient;
  final UserProfileRepository _userProfileRepository;

  DocumentReference<Map<String, dynamic>> _roomDoc(String roomId) =>
      _firestore.collection('live_rooms').doc(roomId);

  Future<LiveRoomJoinSession> joinRoom({
    required String roomId,
    String? roomName,
    String role = 'joiner',
    String? tagline,
    String? language,
    List<String>? tags,
    String? atmosphereImageUrl,
    String? overviewImageUrl,
    String visibility = 'public',
    String? pinnedMessage,
    bool giftGoalEnabled = false,
    double? giftGoalBuds,
  }) async {
    final endpoint = Uri.parse('${_resolveBackendApiBaseUrl()}/joinLiveRoom');
    final payload = <String, dynamic>{
      'roomId': roomId,
      'role': role,
      'visibility': visibility,
      'giftGoalEnabled': giftGoalEnabled,
    };
    if (roomName != null) payload['roomName'] = roomName;
    if (tagline != null) payload['tagline'] = tagline;
    if (language != null) payload['language'] = language;
    if (tags != null) payload['tags'] = tags;
    if (atmosphereImageUrl != null && atmosphereImageUrl.trim().isNotEmpty) {
      payload['atmosphereImageUrl'] = atmosphereImageUrl.trim();
    }
    if (overviewImageUrl != null && overviewImageUrl.trim().isNotEmpty) {
      payload['overviewImageUrl'] = overviewImageUrl.trim();
    }
    if (pinnedMessage != null) payload['pinnedMessage'] = pinnedMessage;
    if (giftGoalBuds != null) payload['giftGoalBuds'] = giftGoalBuds;
    final response = await _postJson(endpoint: endpoint, payload: payload);

    final body = _decodeBody(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LiveRoomException(
        body['error']?.toString() ?? 'Could not join live room.',
      );
    }

    return LiveRoomJoinSession.fromJson(body);
  }

  Future<void> endRoom(String roomId) async {
    final endpoint = Uri.parse('${_resolveBackendApiBaseUrl()}/endLiveRoom');
    final response = await _postJson(
      endpoint: endpoint,
      payload: <String, dynamic>{'roomId': roomId},
    );
    final body = _decodeBody(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LiveRoomException(
        body['error']?.toString() ?? 'Could not end live room.',
      );
    }
  }

  Future<LiveRoomGiftResult> sendGift({
    required String roomId,
    required String giftId,
    int multiplier = 1,
  }) async {
    final endpoint = Uri.parse(
      '${_resolveBackendApiBaseUrl()}/sendLiveRoomGift',
    );
    final response = await _postJson(
      endpoint: endpoint,
      payload: <String, dynamic>{
        'roomId': roomId,
        'giftId': giftId,
        'multiplier': multiplier,
      },
    );
    final body = _decodeBody(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LiveRoomException(
        body['error']?.toString() ?? 'Could not send gift right now.',
      );
    }
    return LiveRoomGiftResult.fromJson(body);
  }

  Stream<LiveRoomRecord?> watchRoom(String roomId) {
    final normalizedRoomId = roomId.trim();
    if (normalizedRoomId.isEmpty) {
      return const Stream<LiveRoomRecord?>.empty();
    }

    return _roomDoc(normalizedRoomId).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        return null;
      }
      return LiveRoomRecord.fromSnapshot(snapshot);
    });
  }

  Stream<List<LiveRoomRecord>> watchPublicLiveRooms({int limit = 24}) {
    return _firestore
        .collection('live_rooms')
        .where('status', isEqualTo: 'live')
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          final rooms =
              snapshot.docs
                  .map(LiveRoomRecord.fromSnapshot)
                  .where(
                    (room) => !room.isPrivate && room.visibility == 'public',
                  )
                  .toList(growable: false)
                ..sort((a, b) {
                  final aTime =
                      a.updatedAt?.millisecondsSinceEpoch ??
                      a.createdAt?.millisecondsSinceEpoch ??
                      0;
                  final bTime =
                      b.updatedAt?.millisecondsSinceEpoch ??
                      b.createdAt?.millisecondsSinceEpoch ??
                      0;
                  return bTime.compareTo(aTime);
                });
          return rooms;
        });
  }

  Stream<List<LiveRoomParticipantRecord>> watchParticipants(String roomId) {
    final normalizedRoomId = roomId.trim();
    if (normalizedRoomId.isEmpty) {
      return const Stream<List<LiveRoomParticipantRecord>>.empty();
    }

    return _roomDoc(
      normalizedRoomId,
    ).collection('participants').snapshots().map((snapshot) {
      final participants = snapshot.docs
          .map(LiveRoomParticipantRecord.fromSnapshot)
          .toList(growable: false);
      final sorted = participants.toList(growable: false)
        ..sort((a, b) {
          if (a.isHost != b.isHost) {
            return a.isHost ? -1 : 1;
          }
          final aJoined = a.joinedAt?.millisecondsSinceEpoch ?? 0;
          final bJoined = b.joinedAt?.millisecondsSinceEpoch ?? 0;
          return aJoined.compareTo(bJoined);
        });
      return sorted;
    });
  }

  Stream<int> watchParticipantCount(String roomId) {
    final normalizedRoomId = roomId.trim();
    if (normalizedRoomId.isEmpty) {
      return const Stream<int>.empty();
    }

    return _roomDoc(normalizedRoomId)
        .collection('participants')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<List<LiveRoomMessageRecord>> watchMessages(
    String roomId, {
    int limit = 200,
  }) {
    final normalizedRoomId = roomId.trim();
    if (normalizedRoomId.isEmpty) {
      return const Stream<List<LiveRoomMessageRecord>>.empty();
    }

    return _roomDoc(normalizedRoomId)
        .collection('messages')
        .orderBy('created_at', descending: false)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(LiveRoomMessageRecord.fromSnapshot)
              .toList(growable: false);
        });
  }

  Future<void> joinParticipantPresence({
    required String roomId,
    required bool isHost,
    required bool micEnabled,
    required bool cameraEnabled,
    required bool screenShareEnabled,
  }) async {
    final currentUser = await _loadCurrentUserIdentity();
    await _roomDoc(roomId).collection('participants').doc(currentUser.uid).set({
      'user_id': currentUser.uid,
      'display_name': currentUser.displayName,
      'avatar_url': currentUser.avatarUrl,
      'is_host': isHost,
      'mic_enabled': micEnabled,
      'camera_enabled': cameraEnabled,
      'screen_share_enabled': screenShareEnabled,
      'joined_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateParticipantPresence({
    required String roomId,
    required bool micEnabled,
    required bool cameraEnabled,
    required bool screenShareEnabled,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const LiveRoomException('Please sign in first.');
    }
    await _roomDoc(roomId).collection('participants').doc(user.uid).set({
      'mic_enabled': micEnabled,
      'camera_enabled': cameraEnabled,
      'screen_share_enabled': screenShareEnabled,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> leaveParticipantPresence(String roomId) async {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }
    await _roomDoc(roomId).collection('participants').doc(user.uid).delete();
  }

  Future<void> sendTextMessage({
    required String roomId,
    required String text,
  }) async {
    final normalizedRoomId = roomId.trim();
    final normalizedText = text.trim();
    if (normalizedRoomId.isEmpty || normalizedText.isEmpty) {
      return;
    }

    final currentUser = await _loadCurrentUserIdentity();
    await _roomDoc(normalizedRoomId).collection('messages').add({
      'room_id': normalizedRoomId,
      'sender_id': currentUser.uid,
      'sender_name': currentUser.displayName,
      'sender_avatar_url': currentUser.avatarUrl,
      'text': normalizedText,
      'message_type': 'text',
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  String resolveInviteUrl(String roomId, {String? roomName}) {
    final current = Uri.base;
    final queryParameters = <String, String>{
      'roomId': roomId,
      'role': 'joiner',
      if (roomName != null && roomName.trim().isNotEmpty)
        'roomName': roomName.trim(),
    };
    return current
        .replace(
          path: '/playground/live-room',
          queryParameters: queryParameters,
          fragment: '',
        )
        .toString();
  }

  String _resolveBackendApiBaseUrl() {
    final configured = AppConfig.paymentsApiBaseUrl.trim();
    if (configured.isNotEmpty) {
      return configured.endsWith('/')
          ? configured.substring(0, configured.length - 1)
          : configured;
    }

    final projectId = Firebase.app().options.projectId;
    if (projectId.isEmpty) {
      throw const LiveRoomException('Backend API base URL is not configured.');
    }

    final region = AppConfig.paymentsRegion.trim().isEmpty
        ? 'us-central1'
        : AppConfig.paymentsRegion.trim();
    return 'https://$region-$projectId.cloudfunctions.net';
  }

  Future<_CurrentUserIdentity> _loadCurrentUserIdentity() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const LiveRoomException('Please sign in to join live rooms.');
    }

    final profile = await _userProfileRepository.fetchById(user.uid);
    final displayName = profile?.fullName?.trim().isNotEmpty == true
        ? profile!.fullName!.trim()
        : user.displayName?.trim().isNotEmpty == true
        ? user.displayName!.trim()
        : user.email?.trim().isNotEmpty == true
        ? user.email!.trim()
        : 'User';
    final avatarUrl = profile?.avatarUrl?.trim().isNotEmpty == true
        ? profile!.avatarUrl!.trim()
        : user.photoURL?.trim() ?? '';

    return _CurrentUserIdentity(
      uid: user.uid,
      displayName: displayName,
      avatarUrl: avatarUrl,
    );
  }

  Future<http.Response> _postJson({
    required Uri endpoint,
    required Map<String, dynamic> payload,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const LiveRoomException('Please sign in first.');
    }
    final idToken = await user.getIdToken(true);
    if (idToken == null || idToken.isEmpty) {
      throw const LiveRoomException(
        'Unable to authenticate live room request.',
      );
    }

    try {
      return await _httpClient
          .post(
            endpoint,
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $idToken',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 30));
    } on TimeoutException {
      throw const LiveRoomException(
        'Live room service timed out. Please try again.',
      );
    } catch (_) {
      throw const LiveRoomException(
        'Live room service is unavailable right now.',
      );
    }
  }

  Map<String, dynamic> _decodeBody(http.Response response) {
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw const LiveRoomException(
        'Live room service returned an invalid response.',
      );
    }
  }
}

class _CurrentUserIdentity {
  final String uid;
  final String displayName;
  final String avatarUrl;

  const _CurrentUserIdentity({
    required this.uid,
    required this.displayName,
    required this.avatarUrl,
  });
}
