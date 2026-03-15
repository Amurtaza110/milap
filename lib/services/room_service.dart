import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room.dart';

class RoomService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static final RoomService _instance = RoomService._internal();
  factory RoomService() => _instance;
  RoomService._internal();

  /// Create a new room (Milap+ feature)
  Future<void> createRoom(Room room) async {
    await _db.collection('rooms').doc(room.id).set(room.toMap());
  }

  /// Delete a room (Host only)
  Future<void> deleteRoom(String roomId) async {
    // 1. Delete all messages in subcollection first (Cleanup)
    final messages = await _db.collection('rooms').doc(roomId).collection('messages').get();
    final batch = _db.batch();
    for (var doc in messages.docs) {
      batch.delete(doc.reference);
    }

    // 2. Delete the room document
    batch.delete(_db.collection('rooms').doc(roomId));

    await batch.commit();
  }

  /// Stream all active rooms
  Stream<List<Room>> streamActiveRooms() {
    return _db
        .collection('rooms')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Room.fromMap(doc.data() as Map<String, dynamic>)).toList());
  }

  /// Join a room
  Future<void> joinRoom(String roomId, RoomParticipant participant) async {
    await _db.collection('rooms').doc(roomId).update({
      'participants': FieldValue.arrayUnion([participant.toMap()]),
    });
  }

  /// Leave a room
  Future<void> leaveRoom(String roomId, String userId) async {
    final doc = await _db.collection('rooms').doc(roomId).get();
    if (doc.exists) {
      final data = doc.data()!;
      List participants = List.from(data['participants'] ?? []);
      participants.removeWhere((p) => p['userId'] == userId);
      await _db.collection('rooms').doc(roomId).update({
        'participants': participants,
      });
    }
  }

  /// Send message in a room
  Future<void> sendMessage(String roomId, RoomMessage message) async {
    final docRef = _db.collection('rooms').doc(roomId).collection('messages').doc();
    await docRef.set({
      ...message.toMap(),
      'id': docRef.id,
      'timestamp': FieldValue.serverTimestamp(),
    });
    
    await _db.collection('rooms').doc(roomId).update({
      'messageCount': FieldValue.increment(1),
    });
  }

  /// Stream messages for a specific room
  Stream<List<RoomMessage>> streamRoomMessages(String roomId) {
    return _db
        .collection('rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => RoomMessage.fromMap(doc.data())).toList());
  }
}
