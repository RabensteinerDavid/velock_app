import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:velock_app/schema/lock.dart';
import 'package:velock_app/schema/lock_history.dart';

class LockService {
  String databaseURL = dotenv.env['DATABASE_URL'] ?? '';
  late final DatabaseReference _databaseRef;

  LockService() {
    _databaseRef = FirebaseDatabase.instanceFor(
      databaseURL: databaseURL,
      app: Firebase.app(),
    ).ref('locks');
  }

  Future<List<Lock>> fetchLocks() async {
    try {
      final snapshot = await _databaseRef.get();
      final data = snapshot.value as Map<dynamic, dynamic>?;

      if (data == null) {
        return [];
      }

      final List<Lock> fetchedLocks = [];
      data.forEach((key, value) {
        if (value is Map) {
          final mappedValue = Map<String, dynamic>.from(value);
          fetchedLocks.add(Lock.fromFirebase(key, mappedValue));
        }
      });
      return fetchedLocks;
    } catch (e) {
      print("Error fetching locks: $e");
      return [];
    }
  }

  Future<List<Lock>> fetchLocksByIds(List<String> lockIds) async {
    try {
      final List<Lock> fetchedLocks = [];

      for (String lockId in lockIds) {
        final snapshot = await _databaseRef.child(lockId).get();
        final data = snapshot.value as Map<dynamic, dynamic>?;

        if (data != null) {
          final lock =
              Lock.fromFirebase(lockId, Map<String, dynamic>.from(data));
          fetchedLocks.add(lock);
        }
      }

      return fetchedLocks;
    } catch (e) {
      print("Error fetching locks by ids: $e");
      return [];
    }
  }

  Future<List<LockHistory>> fetchHistoryById(String lockId) async {
    try {
      final snapshot = await _databaseRef.child('locks/$lockId/history').get();

      if (!snapshot.exists) {
        print('No data available for history.');
        return [];
      }

      final data = snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) {
        print('History data is null.');
        return [];
      }

      final List<LockHistory> historyLocks = [];
      data.forEach((key, value) {
        if (value is Map && key == lockId) {
          final mappedValue = Map<String, dynamic>.from(value);
          if (mappedValue.containsKey('history')) {
            final historyData = mappedValue['history'];
            final keys = historyData.keys;
            for (var key in keys) {
              historyLocks.add(LockHistory.fromFirebase(
                  lockId, Map<String, dynamic>.from(historyData[key])));
            }
          }
        }
      });
      return historyLocks;
    } catch (e) {
      print("Error fetching history for lock $lockId: $e");
      return [];
    }
  }

  Future<bool> verifyLockID(String lockID) async {
    try {
      final snapshot = await _databaseRef.get();
      if (snapshot.exists) {
        for (final child in snapshot.children) {
          if (child.key.toString() == lockID) {
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      print("Error verifying lockID: $e");
      return false;
    }
  }

  Stream<List<Lock>> listenToLocks() {
    return _databaseRef.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data == null) {
        return [];
      }

      final List<Lock> fetchedLocks = [];
      data.forEach((key, value) {
        if (value is Map) {
          final mappedValue = Map<String, dynamic>.from(value);
          fetchedLocks.add(Lock.fromFirebase(key, mappedValue));
        }
      });
      return fetchedLocks;
    });
  }

  Stream<List<Lock>> listenToLocksByIds(List<String> lockIDs) {
    return _databaseRef.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data == null) {
        return [];
      }

      final List<Lock> fetchedLocks = [];
      data.forEach((key, value) {
        if (value is Map) {
          final mappedValue = Map<String, dynamic>.from(value);
          if (lockIDs.contains(key)) {
            fetchedLocks.add(Lock.fromFirebase(key, mappedValue));
          }
        }
      });
      return fetchedLocks;
    });
  }

  Stream<List<Lock>> listenToLocksById(String lockID) {
    return _databaseRef.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data == null) {
        return [];
      }

      final List<Lock> fetchedLocks = [];
      data.forEach((key, value) {
        if (value is Map && key == lockID) {
          final mappedValue = Map<String, dynamic>.from(value);
          fetchedLocks.add(Lock.fromFirebase(key, mappedValue));
        }
      });
      return fetchedLocks;
    });
  }
}
