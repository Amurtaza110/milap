
enum NotificationType { match, like, review, system, alert, accepted, rejected, security }

class NotificationModel {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final int timestamp;
  final bool isRead;
  final String? senderPhoto;
  final String? senderId;
  final String? relatedUserId;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
    this.senderPhoto,
    this.senderId,
    this.relatedUserId,
  });
}
