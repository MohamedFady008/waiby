import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class WaibyChatMessage {
  final String text;
  final bool fromCurrentUser;
  final DateTime sentAt;
  final String messageType;
  final String? giftAssetPath;
  final String? giftName;
  final int? giftMultiplier;
  final double? giftTotalBuds;

  const WaibyChatMessage({
    required this.text,
    required this.fromCurrentUser,
    required this.sentAt,
    this.messageType = 'text',
    this.giftAssetPath,
    this.giftName,
    this.giftMultiplier,
    this.giftTotalBuds,
  });

  bool get isGift => messageType == 'gift' && giftAssetPath != null;
}

@immutable
class WaibyChatGift {
  final String id;
  final String name;
  final String assetPath;
  final double priceBuds;
  final int multiplier;

  const WaibyChatGift({
    required this.id,
    required this.name,
    required this.assetPath,
    required this.priceBuds,
    required this.multiplier,
  });

  double get totalCostBuds => priceBuds * multiplier;
}

@immutable
class WaibyChatThread {
  final String id;
  final String displayName;
  final String avatarAsset;
  final String? avatarUrl;
  final String? frameAsset;
  final String previewText;
  final bool previewItalic;
  final String lastActivityLabel;
  final int unreadCount;
  final bool showUnreadIndicator;
  final bool isOnline;
  final List<WaibyChatMessage> messages;

  WaibyChatThread({
    required this.id,
    required this.displayName,
    required this.avatarAsset,
    this.avatarUrl,
    this.frameAsset,
    required this.previewText,
    this.previewItalic = false,
    required this.lastActivityLabel,
    this.unreadCount = 0,
    this.showUnreadIndicator = false,
    this.isOnline = false,
    List<WaibyChatMessage> messages = const <WaibyChatMessage>[],
  }) : messages = List<WaibyChatMessage>.unmodifiable(messages);

  static List<WaibyChatThread> demoThreads() {
    final anchorTime = DateTime(2026, 1, 21, 8, 50);
    return <WaibyChatThread>[
      WaibyChatThread(
        id: 'arvkiny',
        displayName: 'Arvkiny',
        avatarAsset: 'assets/pp1.png',
        frameAsset: 'assets/medals/vine_wreath.png',
        previewText: 'we can echat',
        lastActivityLabel: 'now',
        unreadCount: 1,
        showUnreadIndicator: true,
        isOnline: true,
        messages: <WaibyChatMessage>[
          WaibyChatMessage(
            text: 'Hello, can i order?',
            fromCurrentUser: true,
            sentAt: anchorTime,
          ),
          WaibyChatMessage(
            text: 'hello! what u wanna order',
            fromCurrentUser: false,
            sentAt: anchorTime.add(const Duration(minutes: 1)),
          ),
          WaibyChatMessage(
            text: 'we can echat',
            fromCurrentUser: false,
            sentAt: anchorTime.add(const Duration(minutes: 2)),
          ),
        ],
      ),
      WaibyChatThread(
        id: 'miathekat',
        displayName: 'miatheKAT',
        avatarAsset: 'assets/pp2.png',
        frameAsset: 'assets/medals/kittybloom.png',
        previewText: 'Kirck just placed an ord...',
        previewItalic: true,
        lastActivityLabel: '1min ago',
      ),
      WaibyChatThread(
        id: 'issacthetuff',
        displayName: 'issacthetuff',
        avatarAsset: 'assets/pp3.png',
        previewText: 'whos??',
        lastActivityLabel: '1min ago',
      ),
      WaibyChatThread(
        id: 'ice',
        displayName: 'ICE',
        avatarAsset: 'assets/pp4.png',
        frameAsset: 'assets/medals/golden.png',
        previewText: 'bruh what',
        lastActivityLabel: '1min ago',
        unreadCount: 1,
        showUnreadIndicator: true,
      ),
      WaibyChatThread(
        id: 'tster',
        displayName: 'Tster',
        avatarAsset: 'assets/pp5.png',
        previewText: 'Tster has completed the or...',
        previewItalic: true,
        lastActivityLabel: '2min ago',
        unreadCount: 1,
        showUnreadIndicator: true,
      ),
      WaibyChatThread(
        id: 'weed1980',
        displayName: 'weed1980',
        avatarAsset: 'assets/pp6.png',
        frameAsset: 'assets/medals/lolita_pearl.png',
        previewText: 'no',
        lastActivityLabel: '5min ago',
        unreadCount: 1,
        showUnreadIndicator: true,
      ),
      WaibyChatThread(
        id: 'raion-shiro',
        displayName: 'Raion Shiro',
        avatarAsset: 'assets/pp7.png',
        frameAsset: 'assets/medals/aqua_ring.png',
        previewText: 'thats what i did idk',
        lastActivityLabel: '12min ago',
      ),
      WaibyChatThread(
        id: 'lilith',
        displayName: 'Lilith',
        avatarAsset: 'assets/pp2.png',
        frameAsset: 'assets/medals/lolita_pearl.png',
        previewText: 'LIlith offered a service of...',
        previewItalic: true,
        lastActivityLabel: '26min ago',
      ),
      WaibyChatThread(
        id: 'waxal',
        displayName: 'waxal',
        avatarAsset: 'assets/pp6.png',
        frameAsset: 'assets/medals/vine_wreath.png',
        previewText: 'Sure',
        lastActivityLabel: '40min ago',
      ),
      WaibyChatThread(
        id: 'nikkiex',
        displayName: 'Nikkiex',
        avatarAsset: 'assets/pp5.png',
        frameAsset: 'assets/medals/aurealux_emblem.png',
        previewText: 'smile',
        lastActivityLabel: '2h ago',
      ),
    ];
  }
}

@immutable
class ChatConversation {
  final String id;
  final List<String> participants;
  final Map<String, String> participantNames;
  final Map<String, String> participantAvatarUrls;
  final Map<String, String> participantFrameAssets;
  final Map<String, bool> participantOnline;
  final Map<String, int> unreadCounts;
  final String? lastMessageText;
  final String? lastMessageSenderId;
  final DateTime? lastMessageAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ChatConversation({
    required this.id,
    required this.participants,
    required this.participantNames,
    required this.participantAvatarUrls,
    required this.participantFrameAssets,
    required this.participantOnline,
    required this.unreadCounts,
    this.lastMessageText,
    this.lastMessageSenderId,
    this.lastMessageAt,
    this.createdAt,
    this.updatedAt,
  });

  factory ChatConversation.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    DateTime? toDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    Map<String, String> toStringMap(dynamic value) {
      if (value is! Map) return const <String, String>{};
      final result = <String, String>{};
      value.forEach((key, entryValue) {
        final resolvedKey = key.toString();
        final resolvedValue = entryValue?.toString();
        if (resolvedValue != null && resolvedValue.isNotEmpty) {
          result[resolvedKey] = resolvedValue;
        }
      });
      return result;
    }

    Map<String, bool> toBoolMap(dynamic value) {
      if (value is! Map) return const <String, bool>{};
      final result = <String, bool>{};
      value.forEach((key, entryValue) {
        result[key.toString()] = entryValue == true;
      });
      return result;
    }

    Map<String, int> toIntMap(dynamic value) {
      if (value is! Map) return const <String, int>{};
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

    final data = snapshot.data() ?? const <String, dynamic>{};
    final participantsRaw = data['participants'];
    final participants = participantsRaw is Iterable
        ? participantsRaw
              .map((entry) => entry.toString())
              .toList(growable: false)
        : const <String>[];

    return ChatConversation(
      id: snapshot.id,
      participants: participants,
      participantNames: toStringMap(data['participant_names']),
      participantAvatarUrls: toStringMap(data['participant_avatar_urls']),
      participantFrameAssets: toStringMap(data['participant_frame_assets']),
      participantOnline: toBoolMap(data['participant_online']),
      unreadCounts: toIntMap(data['unread_counts']),
      lastMessageText: data['last_message_text']?.toString(),
      lastMessageSenderId: data['last_message_sender_id']?.toString(),
      lastMessageAt: toDate(data['last_message_at']),
      createdAt: toDate(data['created_at']),
      updatedAt: toDate(data['updated_at']),
    );
  }

  String otherParticipantId(String currentUserId) {
    for (final userId in participants) {
      if (userId != currentUserId) return userId;
    }
    return currentUserId;
  }

  int unreadCountFor(String userId) => unreadCounts[userId] ?? 0;

  String displayNameFor(String userId, {String fallback = 'Unknown'}) {
    final value = participantNames[userId]?.trim();
    if (value != null && value.isNotEmpty) return value;
    return fallback;
  }

  String? avatarUrlFor(String userId) {
    final value = participantAvatarUrls[userId]?.trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  String? frameAssetFor(String userId) {
    final value = participantFrameAssets[userId]?.trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  bool isOnlineFor(String userId) => participantOnline[userId] == true;
}

@immutable
class ChatMessageRecord {
  final String id;
  final String conversationId;
  final String senderId;
  final String text;
  final DateTime sentAt;
  final String messageType;
  final String? giftAssetPath;
  final String? giftName;
  final int? giftMultiplier;
  final double? giftTotalBuds;

  const ChatMessageRecord({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.text,
    required this.sentAt,
    this.messageType = 'text',
    this.giftAssetPath,
    this.giftName,
    this.giftMultiplier,
    this.giftTotalBuds,
  });

  factory ChatMessageRecord.fromSnapshot(
    String conversationId,
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    DateTime toDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) {
        final parsed = DateTime.tryParse(value);
        if (parsed != null) return parsed;
      }
      return DateTime.now();
    }

    final data = snapshot.data() ?? const <String, dynamic>{};
    final parsedMessageType = data['message_type']
        ?.toString()
        .trim()
        .toLowerCase();
    int? toInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    double? toDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return ChatMessageRecord(
      id: snapshot.id,
      conversationId: conversationId,
      senderId: data['sender_id']?.toString() ?? '',
      text: data['text']?.toString() ?? '',
      sentAt: toDate(data['created_at']),
      messageType: parsedMessageType == 'gift' ? 'gift' : 'text',
      giftAssetPath: data['gift_asset_path']?.toString(),
      giftName: data['gift_name']?.toString(),
      giftMultiplier: toInt(data['gift_multiplier']),
      giftTotalBuds: toDouble(data['gift_total_buds']),
    );
  }
}
