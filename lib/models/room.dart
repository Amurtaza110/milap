import 'package:cloud_firestore/cloud_firestore.dart';

enum RoomCategory { Dating, Friendship, Events, General }

class RoomParticipant {
  final String userId;
  final String name;
  final String avatar;
  final DateTime joinedAt;
  final bool isModerator;

  RoomParticipant({
    required this.userId,
    required this.name,
    required this.avatar,
    required this.joinedAt,
    this.isModerator = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'avatar': avatar,
      'joinedAt': joinedAt.millisecondsSinceEpoch,
      'isModerator': isModerator,
    };
  }

  factory RoomParticipant.fromMap(Map<String, dynamic> map) {
    return RoomParticipant(
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      avatar: map['avatar'] ?? '',
      joinedAt: DateTime.fromMillisecondsSinceEpoch(map['joinedAt'] ?? 0),
      isModerator: map['isModerator'] ?? false,
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

  RoomMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    required this.senderAvatar,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'roomId': roomId,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'message': message,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory RoomMessage.fromMap(Map<String, dynamic> map, String docId) {
    return RoomMessage(
      id: docId,
      roomId: map['roomId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderAvatar: map['senderAvatar'] ?? '',
      message: map['message'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
    );
  }
}

class Room {
  final String id;
  final String name;
  final String description;
  final String creatorId; // Also known as hostId in some UI code
  final List<String> members; // Basic list of UIDs
  final List<RoomParticipant> participants; // Detailed participant info
  final Timestamp createdAt;
  final String? lastMessage;
  final Timestamp? lastMessageTimestamp;
  final String? imageUrl;
  final RoomCategory category;
  final int maxParticipants;
  final bool isPublic;
  final String? pinCode;

  Room({
    required this.id,
    required this.name,
    required this.description,
    required this.creatorId,
    required this.members,
    this.participants = const [],
    required this.createdAt,
    this.lastMessage,
    this.lastMessageTimestamp,
    this.imageUrl,
    this.category = RoomCategory.General,
    this.maxParticipants = 50,
    this.isPublic = true,
    this.pinCode,
  });

  // Aliases for UI compatibility
  String get hostId => creatorId;
  String get hostName => participants.isNotEmpty ? participants.firstWhere((p) => p.userId == creatorId, orElse: () => RoomParticipant(userId: '', name: 'Host', avatar: '', joinedAt: DateTime.now())).name : 'Host';
  String? get coverImage => imageUrl;
  bool get requiresPin => pinCode != null && pinCode!.isNotEmpty;
  int get participantCount => members.length;

  factory Room.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Room(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      creatorId: data['creatorId'] ?? data['hostId'] ?? '',
      members: List<String>.from(data['members'] ?? []),
      participants: (data['participants'] as List?)
              ?.map((p) => RoomParticipant.fromMap(p as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: data['createdAt'] ?? Timestamp.now(),
      lastMessage: data['lastMessage'],
      lastMessageTimestamp: data['lastMessageTimestamp'],
      imageUrl: data['imageUrl'] ?? data['coverImage'],
      category: RoomCategory.values[data['category'] ?? RoomCategory.General.index],
      maxParticipants: data['maxParticipants'] ?? 50,
      isPublic: data['isPublic'] ?? true,
      pinCode: data['pinCode'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'creatorId': creatorId,
      'members': members,
      'participants': participants.map((p) => p.toMap()).toList(),
      'createdAt': createdAt,
      'lastMessage': lastMessage,
      'lastMessageTimestamp': lastMessageTimestamp,
      'imageUrl': imageUrl,
      'category': category.index,
      'maxParticipants': maxParticipants,
      'isPublic': isPublic,
      'pinCode': pinCode,
    };
  }
}
