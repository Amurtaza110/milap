import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat.dart';
import '../models/user_profile.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  /// Get or create a chat room between two users
  Future<String> getOrCreateChat(String userA, String userB) async {
    final roomId = userA.compareTo(userB) < 0 ? '${userA}_$userB' : '${userB}_$userA';
    
    final doc = await _db.collection('chats').doc(roomId).get();
    if (!doc.exists) {
      await _db.collection('chats').doc(roomId).set({
        'id': roomId,
        'participants': [userA, userB],
        'lastMessage': '',
        'timestamp': FieldValue.serverTimestamp(),
        'unreadCount': 0,
        'autoDeleteHours': 24,
      });
    }
    return roomId;
  }

  /// Send a message to a chat room
  Future<void> sendMessage(String roomId, Message message) async {
    final batch = _db.batch();
    
    // 1. Add message to subcollection
    final msgDoc = _db.collection('chats').doc(roomId).collection('messages').doc();
    batch.set(msgDoc, message.copyWith(id: msgDoc.id).toMap());

    // 2. Update chat metadata
    batch.update(_db.collection('chats').doc(roomId), {
      'lastMessage': message.text,
      'timestamp': FieldValue.serverTimestamp(),
      'unreadCount': FieldValue.increment(1),
    });

    await batch.commit();
  }

  /// Mark all messages in a chat as read for the current user
  Future<void> markMessagesAsRead(String roomId, String userId) async {
    final messagesQuery = await _db
        .collection('chats')
        .doc(roomId)
        .collection('messages')
        .where('senderId', isNotEqualTo: userId)
        .where('readStatus', isNotEqualTo: MessageReadStatus.read.index)
        .get();

    if (messagesQuery.docs.isEmpty) {
      // Still reset unreadCount if it's > 0
      await _db.collection('chats').doc(roomId).update({'unreadCount': 0});
      return;
    }

    final batch = _db.batch();
    for (var doc in messagesQuery.docs) {
      batch.update(doc.reference, {'readStatus': MessageReadStatus.read.index});
    }

    // Also reset unreadCount in the chat document
    batch.update(_db.collection('chats').doc(roomId), {'unreadCount': 0});

    await batch.commit();
  }

  /// Stream list of chats for a user
  Stream<List<Chat>> streamUserChats(String userId) {
    return _db
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .asyncMap((snap) async {
          List<Chat> chats = [];
          for (var doc in snap.docs) {
            final data = doc.data();
            final participantIds = List<String>.from(data['participants']);
            final otherUserId = participantIds.firstWhere((id) => id != userId);
            
            // Fetch other participant's profile
            final userDoc = await _db.collection('users').doc(otherUserId).get();
            if (userDoc.exists) {
              final otherUser = UserProfile.fromMap(userDoc.data()!);
              chats.add(Chat(
                id: data['id'],
                participants: [otherUser], // We only need the other person for the list
                lastMessage: data['lastMessage'],
                unreadCount: data['unreadCount'] ?? 0,
                autoDeleteHours: data['autoDeleteHours'] ?? 24,
              ));
            }
          }
          return chats;
        });
  }

  /// Stream messages for a specific chat room
  Stream<List<Message>> streamMessages(String roomId) {
    return _db
        .collection('chats')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Message.fromMap(doc.data())).toList());
  }
}
