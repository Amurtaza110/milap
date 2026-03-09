import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  Stream<UserProfile?> streamProfile(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserProfile.fromMap(doc.data()!);
      }
      return null;
    });
  }

  /// Update user's online status
  Future<void> updateOnlineStatus(String uid, bool isOnline) async {
    try {
      await _db.collection('users').doc(uid).update({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('UserService: Error updating online status: $e');
    }
  }

  Future<void> updateProfile(UserProfile profile) async {
    try {
      await _db.collection('users').doc(profile.id).set(
            profile.toMap(),
            SetOptions(merge: true),
          );
    } catch (e) {
      print('UserService: Error updating profile: $e');
      rethrow;
    }
  }

  Future<void> updateHeartsBalance(String uid, int newBalance) async {
    try {
      final String dateOnly = DateTime.now().toIso8601String().split('T')[0];
      await _db.collection('users').doc(uid).update({
        'heartsBalance': newBalance,
        'lastHeartRefill': dateOnly,
      });
    } catch (e) {
      print('UserService: Error updating hearts: $e');
      rethrow;
    }
  }

  Future<List<UserProfile>> getSocialFeed({String? preferredCity, String? excludeUid}) async {
    try {
      final snapshot = await _db
          .collection('users')
          .where('isDeactivated', isEqualTo: false)
          .get();

      List<UserProfile> allUsers = snapshot.docs
          .map((doc) => UserProfile.fromMap(doc.data()))
          .where((u) => u.id != excludeUid)
          .toList();

      if (preferredCity != null) {
        final targetCity = preferredCity.trim().toLowerCase();
        allUsers.sort((a, b) {
          final cityA = a.location.trim().toLowerCase();
          final cityB = b.location.trim().toLowerCase();
          if (cityA == targetCity && cityB != targetCity) return -1;
          if (cityA != targetCity && cityB == targetCity) return 1;
          return b.rating.compareTo(a.rating);
        });
      }
      return allUsers;
    } catch (e) {
      return [];
    }
  }
}
