import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification.dart';

class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  /// Create a new notification in Firestore
  Future<void> sendNotification({
    required String receiverId,
    required NotificationType type,
    required String title,
    required String message,
    String? senderId,
    String? senderPhoto,
  }) async {
    try {
      final docRef = _db.collection('notifications').doc();
      await docRef.set({
        'id': docRef.id,
        'type': type.name,
        'title': title,
        'message': message,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'isRead': false,
        'senderId': senderId,
        'senderPhoto': senderPhoto,
        'receiverId': receiverId,
      });
    } catch (e) {
      print('NotificationService Error: $e');
    }
  }

  /// Real-time stream of notifications for a specific user
  Stream<List<NotificationModel>> streamNotifications(String userId) {
    return _db
        .collection('notifications')
        .where('receiverId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              final data = doc.data();
              return NotificationModel(
                id: data['id'],
                type: NotificationType.values.firstWhere(
                    (e) => e.name == data['type'],
                    orElse: () => NotificationType.system),
                title: data['title'],
                message: data['message'],
                timestamp: data['timestamp'],
                isRead: data['isRead'],
                senderId: data['senderId'],
                senderPhoto: data['senderPhoto'],
              );
            }).toList());
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await _db.collection('notifications').doc(notificationId).update({'isRead': true});
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    await _db.collection('notifications').doc(notificationId).delete();
  }
}
