import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/social_event.dart';
import '../models/enums.dart';
import '../models/ticket.dart';

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

  /// Create a new event (Milap+ feature)
  Future<void> createEvent(SocialEvent event) async {
    await _db.collection('events').doc(event.id).set(event.toMap());
  }

  /// Fetch events created by a specific organizer
  Future<List<SocialEvent>> getMyEvents(String userId) async {
    try {
      final snapshot = await _db
          .collection('events')
          .where('organizerId', isEqualTo: userId)
          .get();
      return snapshot.docs
          .map((doc) => SocialEvent.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching my events: $e');
      return [];
    }
  }

  /// Stream tickets for a specific user
  Stream<List<Ticket>> streamUserTickets(String userId) {
    return _db
        .collection('tickets')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Ticket.fromMap(doc.data())).toList());
  }

  /// Book an event and generate a real ticket
  Future<bool> bookEvent({
    required String userId,
    required SocialEvent event,
    required EventPackage package,
  }) async {
    try {
      final ticketRef = _db.collection('tickets').doc();
      
      final ticket = Ticket(
        id: ticketRef.id,
        userId: userId,
        eventId: event.id,
        eventTitle: event.title,
        eventDate: event.date,
        eventLocation: event.location,
        packageId: package.id,
        packageName: package.name,
        price: package.price,
        status: TicketStatus.confirmed,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        qrCode: 'MILAP-${ticketRef.id.substring(0, 8).toUpperCase()}',
      );

      final batch = _db.batch();
      
      // 1. Create the Ticket document
      batch.set(ticketRef, ticket.toMap());

      // 2. Increment attendee count on event
      batch.update(_db.collection('events').doc(event.id), {
        'attendeesCount': FieldValue.increment(1),
      });

      await batch.commit();
      return true;
    } catch (e) {
      print('Error booking event: $e');
      return false;
    }
  }
}
