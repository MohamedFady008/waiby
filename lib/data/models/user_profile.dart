import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String id;
  final String? email;
  final String? fullName;
  final String? avatarUrl;
  final bool emailVerified;
  final bool isOnline;
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
      providers: providers ?? this.providers,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toFirestoreMap() {
    return <String, dynamic>{
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'email_verified': emailVerified,
      'is_online': isOnline,
      'providers': providers,
      'metadata': metadata,
      'created_at': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };
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
    final metadata = metadataRaw is Map<String, dynamic>
        ? metadataRaw
        : <String, dynamic>{};

    return UserProfile(
      id: id,
      email: data['email']?.toString(),
      fullName: data['full_name']?.toString(),
      avatarUrl: data['avatar_url']?.toString(),
      emailVerified: data['email_verified'] == true,
      isOnline: data['is_online'] != false,
      providers: providers,
      metadata: metadata,
      createdAt: toDateTime(data['created_at']),
      updatedAt: toDateTime(data['updated_at']),
    );
  }
}
