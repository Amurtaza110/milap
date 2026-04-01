import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/notification.dart';

class NotificationService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream for in-app floating notifications
  final _localUiController = StreamController<AppNotification>.broadcast();
  Stream<AppNotification> get localUiStream => _localUiController.stream;

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  /// Stream notifications for a specific user in real-time
  Stream<List<AppNotification>> getNotifications(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => AppNotification.fromMap(doc.data())).toList();
    });
  }

  /// Mark a notification as read
  Future<void> markAsRead(String userId, String notificationId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  /// Send a notification (local Firestore + Cloud Function for Push)
  Future<void> sendNotification({
    required String receiverId,
    required NotificationType type,
    required String title,
    required String message,
    String? senderId,
    String? senderPhoto,
    String? imageUrl,
  }) async {
    try {
      final String notificationId = _db.collection('users').doc(receiverId).collection('notifications').doc().id;

      final AppNotification notification = AppNotification(
        id: notificationId,
        type: type,
        title: title,
        message: message,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        isRead: false,
        senderId: senderId,
        senderPhoto: senderPhoto,
        imageUrl: imageUrl,
      );

      // 1. Save to Firestore for in-app notification list
      await _db
          .collection('users')
          .doc(receiverId)
          .collection('notifications')
          .doc(notificationId)
          .set(notification.toMap());

      // 2. Add to local UI stream if it's for the current user (simplified logic)
      // In a real app, you might check if the current user ID matches receiverId
      _localUiController.add(notification);

      // 3. Call Cloud Function for real Push Notification (FCM)
      final HttpsCallable callable = _functions.httpsCallable('sendNotification');
      await callable.call(<String, dynamic>{
        'userId': receiverId,
        'title': title,
        'message': message,
      });
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
}
