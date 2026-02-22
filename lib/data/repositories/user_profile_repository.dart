import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_profile.dart';

class UserProfileRepository {
  UserProfileRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<UserProfile?> fetchById(String userId) async {
    final snapshot = await _users.doc(userId).get();
    final data = snapshot.data();
    if (!snapshot.exists || data == null) {
      return null;
    }
    return UserProfile.fromFirestoreMap(snapshot.id, data);
  }

  Stream<UserProfile?> watchById(String userId) {
    return _users.doc(userId).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        return null;
      }
      return UserProfile.fromFirestoreMap(snapshot.id, data);
    });
  }

  Future<void> upsert(UserProfile profile) {
    return _users
        .doc(profile.id)
        .set(profile.toFirestoreMap(), SetOptions(merge: true));
  }

  Future<void> updateFields(String userId, Map<String, dynamic> fields) {
    return _users.doc(userId).set(<String, dynamic>{
      ...fields,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteById(String userId) {
    return _users.doc(userId).delete();
  }
}
