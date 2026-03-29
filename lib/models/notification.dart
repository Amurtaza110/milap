enum NotificationType {
  match,
  message,
  alert,
  accepted,
  rejected,
  system,
  security,
}

class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final String? imageUrl;
  final int timestamp;
  final bool isRead;
  final String? senderId;
  final String? senderPhoto;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.imageUrl,
    required this.timestamp,
    this.isRead = false,
    this.senderId,
    this.senderPhoto,
  });

  static NotificationType _parseType(dynamic raw) {
    if (raw is int) {
      if (raw >= 0 && raw < NotificationType.values.length) {
        return NotificationType.values[raw];
      }
      return NotificationType.alert;
    }
    if (raw is String) {
      return NotificationType.values.firstWhere(
        (t) => t.name == raw,
        orElse: () => NotificationType.alert,
      );
    }
    return NotificationType.alert;
  }

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: (map['id'] ?? '').toString(),
      type: _parseType(map['type']),
      title: (map['title'] ?? '').toString(),
      message: (map['message'] ?? '').toString(),
      imageUrl: map['imageUrl'],
      timestamp: (map['timestamp'] is int)
          ? map['timestamp'] as int
          : (map['timestamp']?.toString() != null
              ? int.tryParse(map['timestamp'].toString()) ?? 0
              : 0),
      isRead: map['isRead'] == true,
      senderId: map['senderId']?.toString(),
      senderPhoto: map['senderPhoto']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      // Store as string for forward-compatibility; fromMap supports both
      'type': type.name,
      'title': title,
      'message': message,
      'imageUrl': imageUrl,
      'timestamp': timestamp,
      'isRead': isRead,
      'senderId': senderId,
      'senderPhoto': senderPhoto,
    };
  }
}
