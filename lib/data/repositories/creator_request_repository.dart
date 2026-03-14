import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/creator_request.dart';

/// Repository for managing creator request documents in Firestore.
///
/// Uses the `creator_requests` collection. Documents are keyed by user UID
/// to prevent duplicate submissions.
class CreatorRequestRepository {
  CreatorRequestRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('creator_requests');

  /// Submits a creator request to Firestore.
  ///
  /// Uses the [CreatorRequest.userId] as the document ID to guarantee
  /// one request per user (prevents duplicate submissions).
  Future<void> submitRequest(CreatorRequest request) async {
    final docRef = _collection.doc(request.userId);
    await _firestore.runTransaction((transaction) async {
      final existing = await transaction.get(docRef);
      if (existing.exists) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'already-exists',
          message: 'Creator request already exists for this user.',
        );
      }
      transaction.set(
        docRef,
        request.toFirestoreMap(),
        SetOptions(merge: false),
      );
    });
  }

  /// Checks if a creator request already exists for the given [userId].
  Future<bool> hasExistingRequest(String userId) async {
    final doc = await _collection.doc(userId).get();
    return doc.exists;
  }

  /// Fetches the creator request for the given [userId].
  /// Returns null if no request is found.
  Future<CreatorRequest?> fetchByUserId(String userId) async {
    final doc = await _collection.doc(userId).get();
    final data = doc.data();
    if (!doc.exists || data == null) return null;
    return CreatorRequest.fromFirestoreMap(data);
  }

  /// Streams real-time updates of the creator request for [userId].
  Stream<CreatorRequest?> watchByUserId(String userId) {
    return _collection.doc(userId).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (!snapshot.exists || data == null) return null;
      return CreatorRequest.fromFirestoreMap(data);
    });
  }

  /// Updates specific fields on an existing creator request.
  Future<void> updateFields(String userId, Map<String, dynamic> fields) async {
    await _collection.doc(userId).update(<String, dynamic>{
      ...fields,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }
}
