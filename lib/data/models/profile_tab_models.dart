import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileWishlistItem {
  final String id;
  final String title;
  final String subtitle;
  final int price;
  final double progress;
  final String imageAsset;
  final String? imageUrl;
  final bool highlighted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProfileWishlistItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.progress,
    required this.imageAsset,
    this.imageUrl,
    this.highlighted = false,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toFirestoreMap() {
    return <String, dynamic>{
      'title': title,
      'subtitle': subtitle,
      'price': price,
      'progress': progress,
      'image_asset': imageAsset,
      'image_url': imageUrl,
      'highlighted': highlighted,
      'created_at': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  factory ProfileWishlistItem.fromFirestoreMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return ProfileWishlistItem(
      id: id,
      title: data['title']?.toString().trim().isNotEmpty == true
          ? data['title'].toString().trim()
          : 'Untitled wish',
      subtitle: data['subtitle']?.toString().trim() ?? '',
      price: _toInt(data['price']),
      progress: _toProgress(data['progress']),
      imageAsset: data['image_asset']?.toString().trim().isNotEmpty == true
          ? data['image_asset'].toString().trim()
          : 'assets/login.png',
      imageUrl: _toNullableTrimmed(data['image_url']),
      highlighted: data['highlighted'] == true,
      createdAt: _toDateTime(data['created_at']),
      updatedAt: _toDateTime(data['updated_at']),
    );
  }
}

class ProfileGalleryItem {
  final String id;
  final String imageAsset;
  final String? imageUrl;
  final String? overlayAsset;
  final double overlayWidthFactor;
  final bool isPrivate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProfileGalleryItem({
    required this.id,
    required this.imageAsset,
    this.imageUrl,
    this.overlayAsset,
    this.overlayWidthFactor = 0.42,
    this.isPrivate = false,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toFirestoreMap() {
    return <String, dynamic>{
      'image_asset': imageAsset,
      'image_url': imageUrl,
      'overlay_asset': overlayAsset,
      'overlay_width_factor': overlayWidthFactor,
      'is_private': isPrivate,
      'created_at': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  factory ProfileGalleryItem.fromFirestoreMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return ProfileGalleryItem(
      id: id,
      imageAsset: data['image_asset']?.toString().trim().isNotEmpty == true
          ? data['image_asset'].toString().trim()
          : 'assets/pp6.png',
      imageUrl: _toNullableTrimmed(data['image_url']),
      overlayAsset: _toNullableTrimmed(data['overlay_asset']),
      overlayWidthFactor: _toOverlayWidthFactor(data['overlay_width_factor']),
      isPrivate: data['is_private'] == true,
      createdAt: _toDateTime(data['created_at']),
      updatedAt: _toDateTime(data['updated_at']),
    );
  }
}

class ProfileServiceOption {
  final String label;
  final String price;
  final String unit;

  const ProfileServiceOption({
    required this.label,
    required this.price,
    required this.unit,
  });

  Map<String, dynamic> toFirestoreMap() {
    return <String, dynamic>{'label': label, 'price': price, 'unit': unit};
  }

  factory ProfileServiceOption.fromFirestoreMap(Map<String, dynamic> data) {
    return ProfileServiceOption(
      label: data['label']?.toString().trim().isNotEmpty == true
          ? data['label'].toString().trim()
          : 'Option',
      price: data['price']?.toString().trim().isNotEmpty == true
          ? data['price'].toString().trim()
          : '0',
      unit: data['unit']?.toString().trim().isNotEmpty == true
          ? data['unit'].toString().trim()
          : 'Unit',
    );
  }
}

class ProfileServiceItem {
  final String id;
  final String title;
  final String price;
  final String unit;
  final String iconKey;
  final int iconBackgroundColor;
  final int iconColor;
  final bool selected;
  final int servedCount;
  final int ratingPercent;
  final String description;
  final String bannerImageAsset;
  final String? bannerImageUrl;
  final List<ProfileServiceOption> options;
  final int sortOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProfileServiceItem({
    required this.id,
    required this.title,
    required this.price,
    required this.unit,
    required this.iconKey,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.selected,
    required this.servedCount,
    required this.ratingPercent,
    required this.description,
    required this.bannerImageAsset,
    required this.bannerImageUrl,
    required this.options,
    required this.sortOrder,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toFirestoreMap() {
    return <String, dynamic>{
      'title': title,
      'price': price,
      'unit': unit,
      'icon_key': iconKey,
      'icon_background_color': iconBackgroundColor,
      'icon_color': iconColor,
      'selected': selected,
      'served_count': servedCount,
      'rating_percent': ratingPercent,
      'description': description,
      'banner_image_asset': bannerImageAsset,
      'banner_image_url': bannerImageUrl,
      'options': options.map((item) => item.toFirestoreMap()).toList(),
      'sort_order': sortOrder,
      'created_at': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  factory ProfileServiceItem.fromFirestoreMap(
    String id,
    Map<String, dynamic> data,
  ) {
    final optionsRaw = data['options'];
    final parsedOptions = optionsRaw is Iterable
        ? optionsRaw
              .whereType<Map>()
              .map(
                (item) => ProfileServiceOption.fromFirestoreMap(
                  item.map((key, value) => MapEntry(key.toString(), value)),
                ),
              )
              .toList(growable: false)
        : const <ProfileServiceOption>[];

    return ProfileServiceItem(
      id: id,
      title: data['title']?.toString().trim().isNotEmpty == true
          ? data['title'].toString().trim()
          : 'Service',
      price: data['price']?.toString().trim().isNotEmpty == true
          ? data['price'].toString().trim()
          : '0.00',
      unit: data['unit']?.toString().trim().isNotEmpty == true
          ? data['unit'].toString().trim()
          : 'Unit',
      iconKey: data['icon_key']?.toString().trim().isNotEmpty == true
          ? data['icon_key'].toString().trim()
          : 'chat',
      iconBackgroundColor: _toInt(
        data['icon_background_color'],
        fallback: 0xFF5A90F8,
      ),
      iconColor: _toInt(data['icon_color'], fallback: 0xFF06163A),
      selected: data['selected'] == true,
      servedCount: _toInt(data['served_count']),
      ratingPercent: _toInt(data['rating_percent']),
      description: data['description']?.toString().trim().isNotEmpty == true
          ? data['description'].toString().trim()
          : '',
      bannerImageAsset:
          data['banner_image_asset']?.toString().trim().isNotEmpty == true
          ? data['banner_image_asset'].toString().trim()
          : 'assets/login.png',
      bannerImageUrl: _toNullableTrimmed(data['banner_image_url']),
      options: parsedOptions,
      sortOrder: _toInt(data['sort_order']),
      createdAt: _toDateTime(data['created_at']),
      updatedAt: _toDateTime(data['updated_at']),
    );
  }
}

class ProfileReviewEntry {
  final String id;
  final String name;
  final String title;
  final String text;
  final double rating;
  final String avatarAsset;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProfileReviewEntry({
    required this.id,
    required this.name,
    required this.title,
    required this.text,
    required this.rating,
    required this.avatarAsset,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toFirestoreMap() {
    return <String, dynamic>{
      'name': name,
      'title': title,
      'text': text,
      'rating': rating,
      'avatar_asset': avatarAsset,
      'avatar_url': avatarUrl,
      'created_at': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  factory ProfileReviewEntry.fromFirestoreMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return ProfileReviewEntry(
      id: id,
      name: data['name']?.toString().trim().isNotEmpty == true
          ? data['name'].toString().trim()
          : 'Hidden',
      title: data['title']?.toString().trim().isNotEmpty == true
          ? data['title'].toString().trim()
          : 'Review',
      text: data['text']?.toString().trim().isNotEmpty == true
          ? data['text'].toString().trim()
          : '',
      rating: _toDouble(data['rating'], fallback: 5),
      avatarAsset: data['avatar_asset']?.toString().trim().isNotEmpty == true
          ? data['avatar_asset'].toString().trim()
          : 'assets/pp6.png',
      avatarUrl: _toNullableTrimmed(data['avatar_url']),
      createdAt: _toDateTime(data['created_at']),
      updatedAt: _toDateTime(data['updated_at']),
    );
  }
}

class ProfilePostEntry {
  final String id;
  final String text;
  final String? imageUrl;
  final String? imageAsset;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProfilePostEntry({
    required this.id,
    required this.text,
    this.imageUrl,
    this.imageAsset,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toFirestoreMap() {
    return <String, dynamic>{
      'text': text,
      'image_url': imageUrl,
      'image_asset': imageAsset,
      'created_at': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  factory ProfilePostEntry.fromFirestoreMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return ProfilePostEntry(
      id: id,
      text: data['text']?.toString().trim().isNotEmpty == true
          ? data['text'].toString().trim()
          : '',
      imageUrl: _toNullableTrimmed(data['image_url']),
      imageAsset: _toNullableTrimmed(data['image_asset']),
      createdAt: _toDateTime(data['created_at']),
      updatedAt: _toDateTime(data['updated_at']),
    );
  }
}

String? _toNullableTrimmed(dynamic value) {
  final normalized = value?.toString().trim();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }
  return normalized;
}

int _toInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

double _toDouble(dynamic value, {double fallback = 0}) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}

double _toProgress(dynamic value) {
  final parsed = _toDouble(value);
  if (parsed.isNaN) return 0;
  if (parsed < 0) return 0;
  if (parsed > 1) return 1;
  return parsed;
}

double _toOverlayWidthFactor(dynamic value) {
  final parsed = _toDouble(value, fallback: 0.42);
  if (parsed.isNaN || parsed <= 0) return 0.42;
  if (parsed > 1) return 1;
  return parsed;
}

DateTime? _toDateTime(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}
