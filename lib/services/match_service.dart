import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/match_model.dart';
import '../models/user_profile.dart' hide MatchRequest;
import '../models/notification.dart';
import 'notification_service.dart';

class MatchService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  static final MatchService _instance = MatchService._internal();
  factory MatchService() => _instance;
  MatchService._internal();

  /// Stream match requests sent by the current user
  Stream<List<MatchRequest>> streamSentRequests(String userId) {
    return _db
        .collection('match_requests')
        .where('senderId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => MatchRequest.fromMap(doc.data())).toList());
  }

  /// Send a match request or create a mutual match
  Future<bool> sendMatchRequest({
    required UserProfile sender,
    required UserProfile receiver,
  }) async {
    try {
      final String requestId = '${sender.id}_${receiver.id}';
      final String reverseId = '${receiver.id}_${sender.id}';

      final reverseDoc = await _db.collection('match_requests').doc(reverseId).get();

      if (reverseDoc.exists) {
        // MUTUAL MATCH DETECTED
        await _acceptMatch(
          senderId: sender.id, 
          receiverId: receiver.id, 
          senderName: sender.name, 
          senderPhoto: sender.photos.isNotEmpty ? sender.photos[0] : '',
          receiverName: receiver.name,
          receiverPhoto: receiver.photos.isNotEmpty ? receiver.photos[0] : ''
        );
        return true;
      } else {
        // PENDING REQUEST
        await _db.collection('match_requests').doc(requestId).set(MatchRequest(
          id: requestId,
          senderId: sender.id,
          receiverId: receiver.id,
          senderName: sender.name,
          senderPhoto: sender.photos.isNotEmpty ? sender.photos[0] : '',
          receiverName: receiver.name,
          receiverPhoto: receiver.photos.isNotEmpty ? receiver.photos[0] : '',
          status: MatchStatus.pending,
          createdAt: DateTime.now(),
        ).toMap());

        // Notify User B
        await _notificationService.sendNotification(
          receiverId: receiver.id,
          type: NotificationType.match,
          title: 'Soul Match Request',
          message: '${sender.name} wants to connect with you.',
          senderId: sender.id,
          senderPhoto: sender.photos.isNotEmpty ? sender.photos[0] : null,
        );

        return false;
      }
    } catch (e) {
      print('MatchService Error: $e');
      rethrow;
    }
  }

  /// Accept a match request
  Future<void> acceptMatchRequest(MatchRequest request) async {
    await _acceptMatch(
      senderId: request.senderId,
      receiverId: request.receiverId,
      senderName: request.senderName,
      senderPhoto: request.senderPhoto,
      receiverName: request.receiverName,
      receiverPhoto: request.receiverPhoto,
    );
  }

  /// Internal logic to finalize a match
  Future<void> _acceptMatch({
    required String senderId,
    required String receiverId,
    required String senderName,
    required String senderPhoto,
    required String receiverName,
    required String receiverPhoto,
  }) async {
    final batch = _db.batch();
    final String requestId = '${senderId}_${receiverId}';
    final String reverseId = '${receiverId}_${senderId}';

    // Update both request documents to accepted
    batch.set(_db.collection('match_requests').doc(requestId), {
      'status': MatchStatus.accepted.name,
      'senderId': senderId,
      'receiverId': receiverId,
      'senderName': senderName,
      'senderPhoto': senderPhoto,
      'receiverName': receiverName,
      'receiverPhoto': receiverPhoto,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    
    batch.set(_db.collection('match_requests').doc(reverseId), {
      'status': MatchStatus.accepted.name,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Create a Chat Room
    final chatRoomId = senderId.compareTo(receiverId) < 0
        ? '${senderId}_${receiverId}' 
        : '${receiverId}_${senderId}';
            
    batch.set(_db.collection('chats').doc(chatRoomId), {
      'id': chatRoomId,
      'participants': [senderId, receiverId],
      'lastMessage': 'It\'s a Match! Say hello.',
      'timestamp': FieldValue.serverTimestamp(),
      'unreadCount': 0,
      'autoDeleteHours': 24,
    });

    await batch.commit();

    // Notify User A that User B accepted
    await _notificationService.sendNotification(
      receiverId: senderId, 
      type: NotificationType.accepted,
      title: 'Match Accepted!',
      message: 'You and others have matched! Start chatting now.',
      senderId: receiverId,
      senderPhoto: receiverPhoto,
    );
  }

  /// Reject a match request
  Future<void> rejectMatchRequest(String requestId, String senderId, String receiverId) async {
    await _db.collection('match_requests').doc(requestId).update({
      'status': MatchStatus.rejected.name,
    });

    await _notificationService.sendNotification(
      receiverId: senderId,
      type: NotificationType.rejected,
      title: 'Request Update',
      message: 'A user has declined your match request.',
      senderId: receiverId,
    );
  }
}
