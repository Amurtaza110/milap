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
}
