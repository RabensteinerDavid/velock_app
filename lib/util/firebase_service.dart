import 'package:cloud_firestore/cloud_firestore.dart';
import 'lock_service.dart';

class FirebaseService {
  final CollectionReference locks =
      FirebaseFirestore.instance.collection('locks');
  final LockService _lockService = LockService();

  Future<void> saveLock(String userUID, String lockID) async {
    try {
      final lockExists = await _lockService.verifyLockID(lockID);
      final userLockDoc = await FirebaseFirestore.instance
          .collection('locks')
          .doc(userUID)
          .get();

      if (!lockExists) {
        throw Exception('LockID does not exist in the database');
      }

      if (userLockDoc.exists) {
        final lockData = userLockDoc.data();
        var lockIds = lockData?['lock_id'];

        for (var lockEntry in lockIds) {
          if (lockEntry == lockID) {
            throw Exception('LockID is already in the database');
          }
        }

        await FirebaseFirestore.instance
            .collection('locks')
            .doc(userUID)
            .update({
          'lock_id': FieldValue.arrayUnion([lockID]),
        });
      } else {
        await FirebaseFirestore.instance.collection('locks').doc(userUID).set({
          'lock_id': [lockID],
        });
      }
    } catch (e) {
      throw Exception('Failed to save lock: $e');
    }
  }

  Future<List<String>> loadLock(String userUID) async {
    try {
      final userLockDoc = await FirebaseFirestore.instance
          .collection('locks')
          .doc(userUID)
          .get();
      if (userLockDoc.exists) {
        final data = userLockDoc.data();
        final List<String> lockIDs = List<String>.from(data?['lock_id'] ?? []);
        return lockIDs;
      } else {
        print('No lock document found for this user.');
        return [];
      }
    } catch (e) {
      print('Failed to load lock: $e');
      return [];
    }
  }

  Future<void> deleteLock(String userUID, String lock) async {
    try {
      final userLockDoc = await FirebaseFirestore.instance
          .collection('locks')
          .doc(userUID)
          .get();

      if (userLockDoc.exists) {
        await FirebaseFirestore.instance
            .collection('locks')
            .doc(userUID)
            .update({
          'lock_id': FieldValue.arrayRemove([lock]),
        });
      } else {
        print('No lock document found for this user.');
      }
    } catch (e) {
      print('Failed to delete lock: $e');
    }
  }

  Future<List<String>> loadLockID(String userUID) async {
    try {
      final userDoc = await locks.doc(userUID).get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        return List<String>.from(data['lock_id'] ?? []);
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      throw Exception('Failed to load lock: $e');
    }
  }
}
