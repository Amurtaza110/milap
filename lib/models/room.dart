import 'package:cloud_firestore/cloud_firestore.dart';

enum RoomCategory {
  Dating,
  Friendship,
  Events,
  General,
}

enum MessageType {
  Text,
  System,
  Announcement,
}

class Room {
  final String id;
  final String name;
  final String description;
  final RoomCategory category;
  final String hostId;
  final String hostName;
  final String hostAvatar;
  final List<RoomParticipant> participants;
  final int maxParticipants;
  final bool isPublic;
  final String? pinCode; // 4-6 digit PIN for private rooms
  final DateTime createdAt;
  final int messageCount;
  final String? coverImage;
  final bool isActive;

  Room({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.hostId,
    required this.hostName,
    required this.hostAvatar,
    required this.participants,
    required this.maxParticipants,
    required this.isPublic,
    this.pinCode,
    required this.createdAt,
    this.messageCount = 0,
    this.coverImage,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category.name,
      'hostId': hostId,
      'hostName': hostName,
      'hostAvatar': hostAvatar,
      'participants': participants.map((x) => x.toMap()).toList(),
      'maxParticipants': maxParticipants,
      'isPublic': isPublic,
      'pinCode': pinCode,
      'createdAt': Timestamp.fromDate(createdAt),
      'messageCount': messageCount,
      'coverImage': coverImage,
      'isActive': isActive,
    };
  }

  factory Room.fromMap(Map<String, dynamic> map) {
    return Room(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: RoomCategory.values.firstWhere((e) => e.name == map['category'], orElse: () => RoomCategory.General),
      hostId: map['hostId'] ?? '',
      hostName: map['hostName'] ?? '',
      hostAvatar: map['hostAvatar'] ?? '',
      participants: List<RoomParticipant>.from(map['participants']?.map((x) => RoomParticipant.fromMap(x)) ?? []),
      maxParticipants: map['maxParticipants'] ?? 0,
      isPublic: map['isPublic'] ?? true,
      pinCode: map['pinCode'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      messageCount: map['messageCount'] ?? 0,
      coverImage: map['coverImage'],
      isActive: map['isActive'] ?? true,
    );
  }

  Room copyWith({
    String? id,
    String? name,
    String? description,
    RoomCategory? category,
    String? hostId,
    String? hostName,
    String? hostAvatar,
    List<RoomParticipant>? participants,
    int? maxParticipants,
    bool? isPublic,
    String? pinCode,
    DateTime? createdAt,
    int? messageCount,
    String? coverImage,
    bool? isActive,
  }) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      hostId: hostId ?? this.hostId,
      hostName: hostName ?? this.hostName,
      hostAvatar: hostAvatar ?? this.hostAvatar,
      participants: participants ?? this.participants,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      isPublic: isPublic ?? this.isPublic,
      pinCode: pinCode ?? this.pinCode,
      createdAt: createdAt ?? this.createdAt,
      messageCount: messageCount ?? this.messageCount,
      coverImage: coverImage ?? this.coverImage,
      isActive: isActive ?? this.isActive,
    );
  }

  bool get isFull => participants.length >= maxParticipants;
  bool get requiresPin => !isPublic && pinCode != null;
  int get participantCount => participants.length;
}

class RoomParticipant {
  final String userId;
  final String name;
  final String avatar;
  final DateTime joinedAt;
  final bool isModerator;
  final bool isMuted;

  RoomParticipant({
    required this.userId,
    required this.name,
    required this.avatar,
    required this.joinedAt,
    this.isModerator = false,
    this.isMuted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'avatar': avatar,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'isModerator': isModerator,
      'isMuted': isMuted,
    };
  }

  factory RoomParticipant.fromMap(Map<String, dynamic> map) {
    return RoomParticipant(
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      avatar: map['avatar'] ?? '',
      joinedAt: (map['joinedAt'] as Timestamp).toDate(),
      isModerator: map['isModerator'] ?? false,
      isMuted: map['isMuted'] ?? false,
    );
  }

  RoomParticipant copyWith({
    String? userId,
    String? name,
    String? avatar,
    DateTime? joinedAt,
    bool? isModerator,
    bool? isMuted,
  }) {
    return RoomParticipant(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      joinedAt: joinedAt ?? this.joinedAt,
      isModerator: isModerator ?? this.isModerator,
      isMuted: isMuted ?? this.isMuted,
    );
  }
}

class RoomMessage {
  final String id;
  final String roomId;
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final String message;
  final DateTime timestamp;
  final MessageType type;

  RoomMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    required this.senderAvatar,
    required this.message,
    required this.timestamp,
    this.type = MessageType.Text,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'roomId': roomId,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'type': type.name,
    };
  }

  factory RoomMessage.fromMap(Map<String, dynamic> map) {
    return RoomMessage(
      id: map['id'] ?? '',
      roomId: map['roomId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderAvatar: map['senderAvatar'] ?? '',
      message: map['message'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      type: MessageType.values.firstWhere((e) => e.name == map['type'], orElse: () => MessageType.Text),
    );
  }
}
