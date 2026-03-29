import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class CountryDiscoveryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static final CountryDiscoveryService _instance =
      CountryDiscoveryService._internal();
  factory CountryDiscoveryService() => _instance;
  CountryDiscoveryService._internal();

  /// Stream users from a specific country in real-time.
  /// Excludes deactivated users and optionally the current user.
  Stream<List<UserProfile>> streamUsersByCountry(
    String country, {
    String? excludeUid,
  }) {
    return _db
        .collection('users')
        .where('country', isEqualTo: country)
        .where('isDeactivated', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserProfile.fromMap(doc.data()))
          .where((u) => u.id != excludeUid)
          .toList()
        ..sort((a, b) {
          // Online users first, then by rating
          if (a.isOnline && !b.isOnline) return -1;
          if (!a.isOnline && b.isOnline) return 1;
          return b.rating.compareTo(a.rating);
        });
    });
  }

  /// Fetch users from a specific country once (with optional limit).
  Future<List<UserProfile>> fetchUsersByCountry(
    String country, {
    String? excludeUid,
    int limit = 50,
  }) async {
    try {
      Query query = _db
          .collection('users')
          .where('country', isEqualTo: country)
          .where('isDeactivated', isEqualTo: false)
          .limit(limit);

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) =>
              UserProfile.fromMap(doc.data() as Map<String, dynamic>))
          .where((u) => u.id != excludeUid)
          .toList()
        ..sort((a, b) {
          if (a.isOnline && !b.isOnline) return -1;
          if (!a.isOnline && b.isOnline) return 1;
          return b.rating.compareTo(a.rating);
        });
    } catch (e) {
      print('CountryDiscoveryService: Error fetching users by country: $e');
      return [];
    }
  }

  /// Get a map of country -> user count for displaying badges on the country list.
  /// NOTE: For large user bases, consider pre-computing this via Cloud Functions
  /// and storing in a dedicated `country_stats` collection.
  Future<Map<String, int>> getCountryUserCounts() async {
    try {
      final snapshot = await _db
          .collection('users')
          .where('isDeactivated', isEqualTo: false)
          .get();

      final Map<String, int> counts = {};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final country = data['country'] as String?;
        if (country != null && country.isNotEmpty) {
          counts[country] = (counts[country] ?? 0) + 1;
        }
      }
      return counts;
    } catch (e) {
      print('CountryDiscoveryService: Error getting country counts: $e');
      return {};
    }
  }

  /// Stream user count for a specific country (for real-time badge updates).
  Stream<int> streamCountryUserCount(String country) {
    return _db
        .collection('users')
        .where('country', isEqualTo: country)
        .where('isDeactivated', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
