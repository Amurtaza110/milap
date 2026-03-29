import 'package:cloud_firestore/cloud_firestore.dart';

class AppConfigService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static final AppConfigService _instance = AppConfigService._internal();
  factory AppConfigService() => _instance;
  AppConfigService._internal();

  static const List<String> fallbackPakistaniCities = [
    'Karachi',
    'Lahore',
    'Islamabad',
    'Rawalpindi',
    'Faisalabad',
    'Multan',
    'Peshawar',
    'Quetta',
    'Sialkot',
    'Gujranwala',
  ];

  /// Real-time list of Pakistani cities.
  ///
  /// Firestore document shape:
  /// `app_config/pakistani_cities` with field `{ cities: ['Karachi', ...] }`
  Stream<List<String>> streamPakistaniCities() {
    return _db.collection('app_config').doc('pakistani_cities').snapshots().map((doc) {
      final data = doc.data();
      final cities = data?['cities'];
      if (cities is List) {
        final cleaned = cities.whereType<String>().map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
        if (cleaned.isNotEmpty) return cleaned;
      }
      return fallbackPakistaniCities;
    });
  }
}

