import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class LiveRoomJoinSession {
  final String roomId;
  final String roomName;
  final String tagline;
  final String language;
  final List<String> tags;
  final String atmosphereImageUrl;
  final String overviewImageUrl;
  final String visibility;
  final bool isPrivate;
  final String hostId;
  final String hostName;
  final String hostAvatarUrl;
  final String pinnedMessage;
  final bool giftGoalEnabled;
  final double? giftGoalBuds;
  final bool isHost;
  final String effectiveRole;
  final String roomStatus;
  final String livekitUrl;
  final String token;
  final String participantIdentity;

  const LiveRoomJoinSession({
    required this.roomId,
    required this.roomName,
    required this.tagline,
    required this.language,
    required this.tags,
    required this.atmosphereImageUrl,
    required this.overviewImageUrl,
    required this.visibility,
    required this.isPrivate,
    required this.hostId,
    required this.hostName,
    required this.hostAvatarUrl,
    required this.pinnedMessage,
    required this.giftGoalEnabled,
    required this.giftGoalBuds,
    required this.isHost,
    required this.effectiveRole,
    required this.roomStatus,
    required this.livekitUrl,
    required this.token,
    required this.participantIdentity,
  });

  factory LiveRoomJoinSession.fromJson(Map<String, dynamic> json) {
    List<String> tags = const <String>[];
    final tagsRaw = json['tags'];
    if (tagsRaw is Iterable) {
      tags = tagsRaw
          .map((item) => item?.toString().trim() ?? '')
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
    }

    double? giftGoalBuds;
    final giftGoalRaw = json['giftGoalBuds'];
    if (giftGoalRaw is num) {
      giftGoalBuds = giftGoalRaw.toDouble();
    } else if (giftGoalRaw is String) {
      giftGoalBuds = double.tryParse(giftGoalRaw);
    }

    return LiveRoomJoinSession(
      roomId: json['roomId']?.toString().trim() ?? '',
      roomName: json['roomName']?.toString().trim() ?? 'Untitled room',
      tagline: json['tagline']?.toString().trim() ?? '',
      language: json['language']?.toString().trim() ?? '',
      tags: tags,
      atmosphereImageUrl:
          json['atmosphereImageUrl']?.toString().trim() ??
          json['atmosphere_image_url']?.toString().trim() ??
          '',
      overviewImageUrl:
          json['overviewImageUrl']?.toString().trim() ??
          json['overview_image_url']?.toString().trim() ??
          '',
      visibility: json['visibility']?.toString().trim() ?? 'public',
      isPrivate: json['isPrivate'] == true,
      hostId: json['hostId']?.toString().trim() ?? '',
      hostName: json['hostName']?.toString().trim() ?? '',
      hostAvatarUrl: json['hostAvatarUrl']?.toString().trim() ?? '',
      pinnedMessage: json['pinnedMessage']?.toString().trim() ?? '',
      giftGoalEnabled: json['giftGoalEnabled'] == true,
      giftGoalBuds: giftGoalBuds,
      isHost: json['isHost'] == true,
      effectiveRole: json['effectiveRole']?.toString().trim() ?? 'joiner',
      roomStatus: json['roomStatus']?.toString().trim() ?? 'live',
      livekitUrl: json['livekitUrl']?.toString().trim() ?? '',
      token: json['token']?.toString().trim() ?? '',
      participantIdentity: json['participantIdentity']?.toString().trim() ?? '',
    );
  }
}

@immutable
class LiveRoomRecord {
  final String id;
  final String roomName;
  final String tagline;
  final String language;
  final List<String> tags;
  final String atmosphereImageUrl;
  final String overviewImageUrl;
  final String hostId;
  final String hostName;
  final String hostAvatarUrl;
  final String status;
  final String visibility;
  final bool isPrivate;
  final String pinnedMessage;
  final bool giftGoalEnabled;
  final double? giftGoalBuds;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const LiveRoomRecord({
    required this.id,
    required this.roomName,
    required this.tagline,
    required this.language,
    required this.tags,
    required this.atmosphereImageUrl,
    required this.overviewImageUrl,
    required this.hostId,
    required this.hostName,
    required this.hostAvatarUrl,
    required this.status,
    required this.visibility,
    required this.isPrivate,
    required this.pinnedMessage,
    required this.giftGoalEnabled,
    required this.giftGoalBuds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LiveRoomRecord.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    DateTime? toDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    final data = snapshot.data() ?? const <String, dynamic>{};
    final tagsRaw = data['tags'];
    final tags = tagsRaw is Iterable
        ? tagsRaw
              .map((item) => item?.toString().trim() ?? '')
              .where((item) => item.isNotEmpty)
              .toList(growable: false)
        : const <String>[];

    double? giftGoalBuds;
    final giftGoalRaw = data['gift_goal_buds'];
    if (giftGoalRaw is num) {
      giftGoalBuds = giftGoalRaw.toDouble();
    } else if (giftGoalRaw is String) {
      giftGoalBuds = double.tryParse(giftGoalRaw);
    }

    return LiveRoomRecord(
      id: snapshot.id,
      roomName: data['room_name']?.toString().trim() ?? 'Untitled room',
      tagline: data['tagline']?.toString().trim() ?? '',
      language: data['language']?.toString().trim() ?? '',
      tags: tags,
      atmosphereImageUrl:
          data['atmosphere_image_url']?.toString().trim() ??
          data['atmosphereImageUrl']?.toString().trim() ??
          '',
      overviewImageUrl:
          data['overview_image_url']?.toString().trim() ??
          data['overviewImageUrl']?.toString().trim() ??
          '',
      hostId: data['host_id']?.toString().trim() ?? '',
      hostName: data['host_name']?.toString().trim() ?? '',
      hostAvatarUrl: data['host_avatar_url']?.toString().trim() ?? '',
      status: data['status']?.toString().trim() ?? 'live',
      visibility: data['visibility']?.toString().trim() ?? 'public',
      isPrivate: data['is_private'] == true,
      pinnedMessage: data['pinned_message']?.toString().trim() ?? '',
      giftGoalEnabled: data['gift_goal_enabled'] == true,
      giftGoalBuds: giftGoalBuds,
      createdAt: toDate(data['created_at']),
      updatedAt: toDate(data['updated_at']),
    );
  }
}

@immutable
class LiveRoomParticipantRecord {
  final String userId;
  final String displayName;
  final String avatarUrl;
  final bool isHost;
  final bool micEnabled;
  final bool cameraEnabled;
  final bool screenShareEnabled;
  final DateTime? joinedAt;

  const LiveRoomParticipantRecord({
    required this.userId,
    required this.displayName,
    required this.avatarUrl,
    required this.isHost,
    required this.micEnabled,
    required this.cameraEnabled,
    required this.screenShareEnabled,
    required this.joinedAt,
  });

  factory LiveRoomParticipantRecord.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    DateTime? toDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    final data = snapshot.data() ?? const <String, dynamic>{};
    return LiveRoomParticipantRecord(
      userId: data['user_id']?.toString().trim() ?? snapshot.id,
      displayName: data['display_name']?.toString().trim() ?? 'User',
      avatarUrl: data['avatar_url']?.toString().trim() ?? '',
      isHost: data['is_host'] == true,
      micEnabled: data['mic_enabled'] == true,
      cameraEnabled: data['camera_enabled'] == true,
      screenShareEnabled: data['screen_share_enabled'] == true,
      joinedAt: toDate(data['joined_at']),
    );
  }
}

@immutable
class LiveRoomMessageRecord {
  final String id;
  final String roomId;
  final String senderId;
  final String senderName;
  final String senderAvatarUrl;
  final String text;
  final String messageType;
  final String? giftId;
  final String? giftName;
  final String? giftAssetPath;
  final int? giftMultiplier;
  final double? giftTotalBuds;
  final DateTime? createdAt;

  const LiveRoomMessageRecord({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    required this.senderAvatarUrl,
    required this.text,
    required this.messageType,
    required this.giftId,
    required this.giftName,
    required this.giftAssetPath,
    required this.giftMultiplier,
    required this.giftTotalBuds,
    required this.createdAt,
  });

  bool get isGift => messageType == 'gift' && giftAssetPath != null;

  factory LiveRoomMessageRecord.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    DateTime? toDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    double? toDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    int? toInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    final data = snapshot.data() ?? const <String, dynamic>{};
    return LiveRoomMessageRecord(
      id: snapshot.id,
      roomId: data['room_id']?.toString().trim() ?? '',
      senderId: data['sender_id']?.toString().trim() ?? '',
      senderName: data['sender_name']?.toString().trim() ?? 'User',
      senderAvatarUrl: data['sender_avatar_url']?.toString().trim() ?? '',
      text: data['text']?.toString() ?? '',
      messageType: data['message_type']?.toString().trim() ?? 'text',
      giftId: data['gift_id']?.toString(),
      giftName: data['gift_name']?.toString(),
      giftAssetPath: data['gift_asset_path']?.toString(),
      giftMultiplier: toInt(data['gift_multiplier']),
      giftTotalBuds: toDouble(data['gift_total_buds']),
      createdAt: toDate(data['created_at']),
    );
  }
}

@immutable
class LiveRoomGiftResult {
  final double senderBudsBalance;
  final double chargedBuds;
  final double hostIncomeUsd;

  const LiveRoomGiftResult({
    required this.senderBudsBalance,
    required this.chargedBuds,
    required this.hostIncomeUsd,
  });

  factory LiveRoomGiftResult.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0;
      return 0;
    }

    final senderWallet = json['senderWallet'];
    final senderWalletMap = senderWallet is Map
        ? senderWallet.cast<String, dynamic>()
        : const <String, dynamic>{};

    return LiveRoomGiftResult(
      senderBudsBalance: toDouble(
        senderWalletMap['buds_balance'] ?? senderWalletMap['balance_buds'],
      ),
      chargedBuds: toDouble(json['chargedBuds']),
      hostIncomeUsd: toDouble(json['hostIncomeUsd']),
    );
  }
}
