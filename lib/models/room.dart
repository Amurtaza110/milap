import 'package:cloud_firestore/cloud_firestore.dart';

class Room {
  final String id;
  final String name;
  final String description;
  final String creatorId;
  final List<String> members;
  final Timestamp createdAt;
  final String? lastMessage;
  final Timestamp? lastMessageTimestamp;
  final String? imageUrl;

  Room({
    required this.id,
    required this.name,
    required this.description,
    required this.creatorId,
    required this.members,
    required this.createdAt,
    this.lastMessage,
    this.lastMessageTimestamp,
    this.imageUrl,
  });

  factory Room.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Room(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      creatorId: data['creatorId'] ?? '',
      members: List<String>.from(data['members'] ?? []),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      lastMessage: data['lastMessage'],
      lastMessageTimestamp: data['lastMessageTimestamp'],
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'creatorId': creatorId,
      'members': members,
      'createdAt': createdAt,
      'lastMessage': lastMessage,
      'lastMessageTimestamp': lastMessageTimestamp,
      'imageUrl': imageUrl,
    };
  }
}
