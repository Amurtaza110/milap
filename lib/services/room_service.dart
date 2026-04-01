import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room.dart';

class RoomService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _roomsCollection = FirebaseFirestore.instance.collection('rooms');

  static final RoomService _instance = RoomService._internal();
  factory RoomService() => _instance;
  RoomService._internal();

  /// Get a stream of all active rooms
  Stream<List<Room>> getRooms() {
    return _roomsCollection
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Room.fromFirestore(doc)).toList();
    });
  }

  /// Alias for compatibility with older code
  Stream<List<Room>> streamActiveRooms() => getRooms();

  /// Get a stream of messages for a specific room
  Stream<List<RoomMessage>> streamRoomMessages(String roomId) {
    return _roomsCollection
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RoomMessage.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  /// Create a new room
  Future<void> createRoom(Room room) async {
    await _roomsCollection.doc(room.id).set(room.toMap());
  }

  /// Delete a room (Host only)
  Future<void> deleteRoom(String roomId) async {
    // 1. Delete all messages first
    final messages = await _roomsCollection.doc(roomId).collection('messages').get();
    final batch = _firestore.batch();
    for (var doc in messages.docs) {
      batch.delete(doc.reference);
    }

    // 2. Delete the room document
    batch.delete(_roomsCollection.doc(roomId));

    await batch.commit();
  }

  /// Join a room
  Future<void> joinRoom(String roomId, RoomParticipant participant) async {
    final docRef = _roomsCollection.doc(roomId);

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>?;
      if (data == null) return;

      List<String> members = List<String>.from(data['members'] ?? []);
      List<dynamic> participantsList = List.from(data['participants'] ?? []);

      if (!members.contains(participant.userId)) {
        members.add(participant.userId);
        participantsList.add(participant.toMap());

        transaction.update(docRef, {
          'members': members,
          'participants': participantsList,
        });
      }
    });
  }

  /// Leave a room
  Future<void> leaveRoom(String roomId, String userId) async {
    final docRef = _roomsCollection.doc(roomId);

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>?;
      if (data == null) return;

      List<String> members = List<String>.from(data['members'] ?? []);
      List<dynamic> participantsList = List.from(data['participants'] ?? []);

      members.remove(userId);
      participantsList.removeWhere((p) => (p as Map)['userId'] == userId);

      transaction.update(docRef, {
        'members': members,
        'participants': participantsList,
      });
    });
  }

  /// Send a message in a room
  Future<void> sendMessage(String roomId, RoomMessage message) async {
    final messageData = message.toMap();

    final roomUpdate = {
      'lastMessage': message.message,
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
    };

    WriteBatch batch = _firestore.batch();
    
    DocumentReference messageDoc = _roomsCollection.doc(roomId).collection('messages').doc();
    batch.set(messageDoc, messageData);
    
    DocumentReference roomDoc = _roomsCollection.doc(roomId);
    batch.update(roomDoc, roomUpdate);

    return batch.commit();
  }
}
