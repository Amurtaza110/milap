import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:milap/models/room.dart';
import 'package:milap/models/message.dart';

class RoomService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _roomsCollection = FirebaseFirestore.instance.collection('rooms');

  // Get a stream of all rooms
  Stream<List<Room>> getRooms() {
    return _roomsCollection.orderBy('lastMessageTimestamp', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Room.fromFirestore(doc)).toList();
    });
  }

  // Get a stream of messages for a specific room
  Stream<List<Message>> getMessages(String roomId) {
    return _roomsCollection
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList();
    });
  }

  // Create a new room
  Future<DocumentReference> createRoom(String name, String description, String creatorId, String? imageUrl) {
    return _roomsCollection.add({
      'name': name,
      'description': description,
      'creatorId': creatorId,
      'members': [creatorId],
      'createdAt': Timestamp.now(),
      'lastMessage': 'Room created',
      'lastMessageTimestamp': Timestamp.now(),
      'imageUrl': imageUrl,
    });
  }

  // Join a room
  Future<void> joinRoom(String roomId, String userId) {
    return _roomsCollection.doc(roomId).update({
      'members': FieldValue.arrayUnion([userId]),
    });
  }

  // Leave a room
  Future<void> leaveRoom(String roomId, String userId) {
    return _roomsCollection.doc(roomId).update({
      'members': FieldValue.arrayRemove([userId]),
    });
  }

  // Send a message in a room
  Future<void> sendMessage(String roomId, String senderId, String senderName, String text, {String? imageUrl}) {
    final messageData = {
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'timestamp': Timestamp.now(),
      'imageUrl': imageUrl,
    };

    final roomUpdate = {
      'lastMessage': text.isNotEmpty ? text : 'Image',
      'lastMessageTimestamp': Timestamp.now(),
    };

    WriteBatch batch = _firestore.batch();
    
    DocumentReference messageDoc = _roomsCollection.doc(roomId).collection('messages').doc();
    batch.set(messageDoc, messageData);
    
    DocumentReference roomDoc = _roomsCollection.doc(roomId);
    batch.update(roomDoc, roomUpdate);

    return batch.commit();
  }
}
