import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_profile.dart';

class UserProfileRepository {
  UserProfileRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _serverTimeSync =>
      _firestore.collection('server_time_sync');

  Future<UserProfile?> fetchById(String userId, {GetOptions? options}) async {
    final snapshot = await _users.doc(userId).get(options);
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

  Future<void> recordCreatorTestAttempt({
    required String userId,
    required bool passed,
  }) {
    return updateFields(userId, <String, dynamic>{
      'lastTestAttempt': FieldValue.serverTimestamp(),
      'lastTestPassed': passed,
    });
  }

  Future<DateTime?> fetchCurrentServerTime(String userId) async {
    final docRef = _serverTimeSync.doc(userId);
    await docRef.set(<String, dynamic>{
      'uid': userId,
      'now': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final snapshot = await docRef.get(const GetOptions(source: Source.server));
    final data = snapshot.data();
    if (data == null) {
      return null;
    }

    final timestamp = data['now'];
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    return null;
  }

  Future<void> promoteUserToCreator({required String userId}) async {
    final docRef = _users.doc(userId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      final existing = snapshot.data() ?? <String, dynamic>{};
      final alreadyCreator = existing['isCreator'] == true;

      if (alreadyCreator) {
        return;
      }

      transaction.set(docRef, <String, dynamic>{
        'isCreator': true,
        'creatorActivatedAt': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  Stream<List<UserProfile>> watchNewestCreators({int limit = 10}) {
    return _users
        .where('isCreator', isEqualTo: true)
        .limit(limit * 3)
        .snapshots()
        .map((snapshot) {
          final users = snapshot.docs
              .map((doc) => UserProfile.fromFirestoreMap(doc.id, doc.data()))
              .toList(growable: false);

          final sorted = users.toList(growable: false)
            ..sort((a, b) {
              final aTime =
                  a.creatorActivatedAt ??
                  DateTime.fromMillisecondsSinceEpoch(0);
              final bTime =
                  b.creatorActivatedAt ??
                  DateTime.fromMillisecondsSinceEpoch(0);
              return bTime.compareTo(aTime);
            });

          if (sorted.length <= limit) {
            return sorted;
          }
          return sorted.take(limit).toList(growable: false);
        });
  }

  Stream<List<UserProfile>> watchProGamers({int limit = 10}) {
    return _users
        .where('isProGamer', isEqualTo: true)
        .limit(limit * 3)
        .snapshots()
        .map((snapshot) {
          final users = snapshot.docs
              .map((doc) => UserProfile.fromFirestoreMap(doc.id, doc.data()))
              .toList(growable: false);

          final sorted = users.toList(growable: false)
            ..sort((a, b) {
              final aTime =
                  a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
              final bTime =
                  b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
              return bTime.compareTo(aTime);
            });

          if (sorted.length <= limit) {
            return sorted;
          }
          return sorted.take(limit).toList(growable: false);
        });
  }

  Future<void> deleteById(String userId) {
    return _users.doc(userId).delete();
  }
}
