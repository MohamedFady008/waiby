import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/profile_tab_models.dart';

class ProfileTabsRepository {
  ProfileTabsRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _userDoc(String userId) {
    return _firestore.collection('users').doc(userId);
  }

  CollectionReference<Map<String, dynamic>> _wishlist(String userId) {
    return _userDoc(userId).collection('wishlist');
  }

  CollectionReference<Map<String, dynamic>> _gallery(String userId) {
    return _userDoc(userId).collection('gallery');
  }

  CollectionReference<Map<String, dynamic>> _services(String userId) {
    return _userDoc(userId).collection('services');
  }

  CollectionReference<Map<String, dynamic>> _reviews(String userId) {
    return _userDoc(userId).collection('reviews');
  }

  CollectionReference<Map<String, dynamic>> _posts(String userId) {
    return _userDoc(userId).collection('posts');
  }

  Stream<List<ProfileWishlistItem>> watchWishlist(String userId) {
    if (userId.trim().isEmpty) {
      return Stream.value(const <ProfileWishlistItem>[]);
    }

    return _wishlist(userId).snapshots().map((snapshot) {
      final items = snapshot.docs
          .map(
            (doc) => ProfileWishlistItem.fromFirestoreMap(doc.id, doc.data()),
          )
          .toList();
      items.sort(
        (a, b) => (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
            .compareTo(a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)),
      );
      return items;
    });
  }

  Future<void> createWishlistItem(
    String userId,
    ProfileWishlistItem item, {
    String? id,
  }) {
    final doc = id == null
        ? _wishlist(userId).doc()
        : _wishlist(userId).doc(id);
    return doc.set(item.toFirestoreMap(), SetOptions(merge: true));
  }

  Future<void> updateWishlistItem(
    String userId,
    String itemId, {
    required String title,
    required String subtitle,
    required int price,
    required bool highlighted,
  }) {
    return _wishlist(userId).doc(itemId).set(<String, dynamic>{
      'title': title,
      'subtitle': subtitle,
      'price': price,
      'highlighted': highlighted,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteWishlistItem(String userId, String itemId) {
    return _wishlist(userId).doc(itemId).delete();
  }

  Stream<List<ProfileGalleryItem>> watchGallery(
    String userId, {
    required bool includePrivate,
  }) {
    if (userId.trim().isEmpty) {
      return Stream.value(const <ProfileGalleryItem>[]);
    }

    return _gallery(userId).snapshots().map((snapshot) {
      final items = snapshot.docs
          .map((doc) => ProfileGalleryItem.fromFirestoreMap(doc.id, doc.data()))
          .where((item) => includePrivate || !item.isPrivate)
          .toList();
      items.sort(
        (a, b) => (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
            .compareTo(a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)),
      );
      return items;
    });
  }

  Future<void> createGalleryPost(
    String userId,
    ProfileGalleryItem item, {
    String? id,
  }) {
    final doc = id == null ? _gallery(userId).doc() : _gallery(userId).doc(id);
    return doc.set(item.toFirestoreMap(), SetOptions(merge: true));
  }

  Future<void> deleteGalleryPost(String userId, String postId) {
    return _gallery(userId).doc(postId).delete();
  }

  Stream<List<ProfileServiceItem>> watchServices(String userId) {
    if (userId.trim().isEmpty) {
      return Stream.value(const <ProfileServiceItem>[]);
    }

    return _services(userId).snapshots().map((snapshot) {
      final items = snapshot.docs
          .map((doc) => ProfileServiceItem.fromFirestoreMap(doc.id, doc.data()))
          .toList();
      items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return items;
    });
  }

  Stream<List<ProfileReviewEntry>> watchReviews(String userId) {
    if (userId.trim().isEmpty) {
      return Stream.value(const <ProfileReviewEntry>[]);
    }

    return _reviews(userId).limit(25).snapshots().map((snapshot) {
      final items = snapshot.docs
          .map((doc) => ProfileReviewEntry.fromFirestoreMap(doc.id, doc.data()))
          .toList();
      items.sort(
        (a, b) => (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
            .compareTo(a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)),
      );
      return items;
    });
  }

  Stream<List<ProfilePostEntry>> watchPosts(String userId) {
    if (userId.trim().isEmpty) {
      return Stream.value(const <ProfilePostEntry>[]);
    }

    return _posts(userId).snapshots().map((snapshot) {
      final items = snapshot.docs
          .map((doc) => ProfilePostEntry.fromFirestoreMap(doc.id, doc.data()))
          .toList();
      items.sort(
        (a, b) => (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
            .compareTo(a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)),
      );
      return items;
    });
  }

  Future<void> createPost(String userId, ProfilePostEntry post, {String? id}) {
    final doc = id == null ? _posts(userId).doc() : _posts(userId).doc(id);
    return doc.set(post.toFirestoreMap(), SetOptions(merge: true));
  }

  Future<void> deletePost(String userId, String postId) {
    return _posts(userId).doc(postId).delete();
  }
}
