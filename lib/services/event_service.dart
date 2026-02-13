import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/social_event.dart';
import '../models/enums.dart';

class EventService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static final EventService _instance = EventService._internal();
  factory EventService() => _instance;
  EventService._internal();

  /// Fetch social events from Firestore
  Future<List<SocialEvent>> getEvents({
    EventType? category,
    AccessLevel? accessLevel,
    int limit = 50,
  }) async {
    try {
      Query query = _db.collection('events');

      if (category != null) {
        query = query.where('eventType', isEqualTo: category.index);
      }

      if (accessLevel != null) {
        query = query.where('accessLevel', isEqualTo: accessLevel.index);
      }

      final snapshot = await query.orderBy('date').limit(limit).get();
      return snapshot.docs
          .map((doc) => SocialEvent.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching events: $e');
      return [];
    }
  }

  /// Fetch a single event by ID
  Future<SocialEvent?> getEventById(String eventId) async {
    try {
      final doc = await _db.collection('events').doc(eventId).get();
      if (doc.exists && doc.data() != null) {
        return SocialEvent.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error fetching event details: $e');
      return null;
    }
  }

  /// Book an event package
  Future<bool> bookEvent({
    required String userId,
    required String eventId,
    required String packageId,
    required double price,
  }) async {
    try {
      // 1. Create booking record
      final bookingRef = _db.collection('bookings').doc();
      await bookingRef.set({
        'id': bookingRef.id,
        'userId': userId,
        'eventId': eventId,
        'packageId': packageId,
        'price': price,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'confirmed',
      });

      // 2. Increment attendee count on event (transactional)
      await _db.collection('events').doc(eventId).update({
        'attendeesCount': FieldValue.increment(1),
      });

      return true;
    } catch (e) {
      print('Error booking event: $e');
      return false;
    }
  }
}
