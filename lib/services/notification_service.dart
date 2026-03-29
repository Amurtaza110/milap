import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:milap/models/notification.dart';

class NotificationService {
  final CollectionReference _usersCollection = FirebaseFirestore.instance.collection('users');

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final StreamController<AppNotification> _localUiStreamController =
      StreamController<AppNotification>.broadcast();

  Stream<AppNotification> get localUiStream => _localUiStreamController.stream;

  Stream<List<AppNotification>> getNotifications(String userId) {
    return _usersCollection
        .doc(userId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => AppNotification.fromMap(doc.data() as Map<String, dynamic>)).toList();
    });
  }

  Future<void> markAsRead(String userId, String notificationId) {
    return _usersCollection
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  /// $0-cost in-app notification: writes directly to Firestore.
  ///
  /// Stored under: `users/{receiverId}/notifications/{id}`
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
      final docRef =
          _usersCollection.doc(receiverId).collection('notifications').doc();

      final notification = AppNotification(
        id: docRef.id,
        type: type,
        title: title,
        message: message,
        imageUrl: imageUrl,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        isRead: false,
        senderId: senderId,
        senderPhoto: senderPhoto,
      );

      await docRef.set(notification.toMap());
      _localUiStreamController.add(notification);
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
}
