import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String id;
  final String? email;
  final String? fullName;
  final String? avatarUrl;
  final bool emailVerified;
  final bool isOnline;
  final bool isCreator;
  final bool isProGamer;
  final bool lastTestPassed;
  final DateTime? lastTestAttempt;
  final DateTime? creatorActivatedAt;
  final List<String> providers;
  final Map<String, dynamic> metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    required this.id,
    this.email,
    this.fullName,
    this.avatarUrl,
    this.emailVerified = false,
    this.isOnline = true,
    this.isCreator = false,
    this.isProGamer = false,
    this.lastTestPassed = false,
    this.lastTestAttempt,
    this.creatorActivatedAt,
    this.providers = const <String>[],
    this.metadata = const <String, dynamic>{},
    this.createdAt,
    this.updatedAt,
  });

  UserProfile copyWith({
    String? email,
    String? fullName,
    String? avatarUrl,
    bool? emailVerified,
    bool? isOnline,
    bool? isCreator,
    bool? isProGamer,
    bool? lastTestPassed,
    DateTime? lastTestAttempt,
    DateTime? creatorActivatedAt,
    List<String>? providers,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      emailVerified: emailVerified ?? this.emailVerified,
      isOnline: isOnline ?? this.isOnline,
      isCreator: isCreator ?? this.isCreator,
      isProGamer: isProGamer ?? this.isProGamer,
      lastTestPassed: lastTestPassed ?? this.lastTestPassed,
      lastTestAttempt: lastTestAttempt ?? this.lastTestAttempt,
      creatorActivatedAt: creatorActivatedAt ?? this.creatorActivatedAt,
      providers: providers ?? this.providers,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toFirestoreMap() {
    final map = <String, dynamic>{
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'email_verified': emailVerified,
      'is_online': isOnline,
      'isCreator': isCreator,
      'isProGamer': isProGamer,
      'lastTestPassed': lastTestPassed,
      'providers': providers,
      'metadata': metadata,
      'created_at': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };

    if (lastTestAttempt != null) {
      map['lastTestAttempt'] = Timestamp.fromDate(lastTestAttempt!);
    }
    if (creatorActivatedAt != null) {
      map['creatorActivatedAt'] = Timestamp.fromDate(creatorActivatedAt!);
    }

    return map;
  }

  factory UserProfile.fromFirestoreMap(String id, Map<String, dynamic> data) {
    DateTime? toDateTime(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    final providersRaw = data['providers'];
    final providers = providersRaw is Iterable
        ? providersRaw.map((e) => e.toString()).toList(growable: false)
        : const <String>[];

    final metadataRaw = data['metadata'];
    final metadata = <String, dynamic>{};
    if (metadataRaw is Map) {
      metadataRaw.forEach((key, value) {
        metadata[key.toString()] = value;
      });
    }

    return UserProfile(
      id: id,
      email: data['email']?.toString(),
      fullName: data['full_name']?.toString(),
      avatarUrl: data['avatar_url']?.toString(),
      emailVerified: data['email_verified'] == true,
      isOnline: data['is_online'] != false,
      isCreator: data['isCreator'] == true,
      isProGamer: data['isProGamer'] == true,
      lastTestPassed: data['lastTestPassed'] == true,
      lastTestAttempt: toDateTime(data['lastTestAttempt']),
      creatorActivatedAt: toDateTime(data['creatorActivatedAt']),
      providers: providers,
      metadata: metadata,
      createdAt: toDateTime(data['created_at']),
      updatedAt: toDateTime(data['updated_at']),
    );
  }
}
