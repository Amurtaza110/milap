class StatusViewer {
  final String userId;
  final String userName;
  final String userAvatar;
  final int timestamp;
  final bool isSeen;

  StatusViewer({
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.timestamp,
    required this.isSeen,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'timestamp': timestamp,
      'isSeen': isSeen,
    };
  }

  factory StatusViewer.fromMap(Map<String, dynamic> map) {
    return StatusViewer(
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userAvatar: map['userAvatar'] ?? '',
      timestamp: map['timestamp'] ?? 0,
      isSeen: map['isSeen'] ?? false,
    );
  }
}

class Status {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String mediaUrl;
  final String type; // 'image' | 'video'
  final String? caption;
  final int timestamp;
  final bool isSeen;
  final List<StatusViewer>? viewers;

  Status({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.mediaUrl,
    required this.type,
    this.caption,
    required this.timestamp,
    required this.isSeen,
    this.viewers,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'mediaUrl': mediaUrl,
      'type': type,
      'caption': caption,
      'timestamp': timestamp,
      'isSeen': isSeen,
      'viewers': viewers?.map((x) => x.toMap()).toList(),
    };
  }

  factory Status.fromMap(Map<String, dynamic> map) {
    return Status(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userAvatar: map['userAvatar'] ?? '',
      mediaUrl: map['mediaUrl'] ?? '',
      type: map['type'] ?? 'image',
      caption: map['caption'],
      timestamp: map['timestamp'] ?? 0,
      isSeen: map['isSeen'] ?? false,
      viewers: map['viewers'] != null
          ? List<StatusViewer>.from(
              map['viewers'].map((x) => StatusViewer.fromMap(x)))
          : null,
    );
  }
}
