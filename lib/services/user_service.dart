import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  /// Fetch a single user profile from Firestore
  Future<UserProfile?> fetchProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserProfile.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }

  /// Update an existing user profile or create a new one
  Future<void> updateProfile(UserProfile profile) async {
    try {
      await _db.collection('users').doc(profile.id).set(
            profile.toMap(),
            SetOptions(merge: true),
          );
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  /// Get the social feed (active users) paginated
  Future<List<UserProfile>> getSocialFeed({
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      var query = _db
          .collection('users')
          .where('isDeactivated', isEqualTo: false)
          .orderBy('rating', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => UserProfile.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting social feed: $e');
      return [];
    }
  }

  /// Block a user
  Future<void> blockUser(String currentUserId, String targetUserId) async {
    try {
      await _db.collection('users').doc(currentUserId).update({
        'blockedUserIds': FieldValue.arrayUnion([targetUserId]),
      });
    } catch (e) {
      print('Error blocking user: $e');
      rethrow;
    }
  }

  /// Update hearts balance
  Future<void> updateHeartsBalance(String uid, int newBalance) async {
    try {
      await _db.collection('users').doc(uid).update({
        'heartsBalance': newBalance,
        'lastHeartRefill': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error updating hearts: $e');
      rethrow;
    }
  }
}
