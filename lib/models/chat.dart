import 'user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageReadStatus { sent, delivered, read }

enum MessageType {
  text,
  image,
  audio
}

class Message {
  final String id;
  final String senderId;
  final String text;
  final int timestamp;
  final bool isEncrypted;
  final MessageReadStatus readStatus;
  final List<String>? reactions;

  Message({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.isEncrypted,
    required this.readStatus,
    this.reactions,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp,
      'isEncrypted': isEncrypted,
      'readStatus': readStatus.index,
      'reactions': reactions,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    int ts = 0;
    if (map['timestamp'] is Timestamp) {
      ts = (map['timestamp'] as Timestamp).millisecondsSinceEpoch;
    } else if (map['timestamp'] is int) {
      ts = map['timestamp'];
    }

    return Message(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      timestamp: ts,
      isEncrypted: map['isEncrypted'] ?? false,
      readStatus: MessageReadStatus.values[map['readStatus'] ?? 0],
      reactions:
          map['reactions'] != null ? List<String>.from(map['reactions']) : null,
    );
  }

  Message copyWith({
    String? id,
    String? senderId,
    String? text,
    int? timestamp,
    bool? isEncrypted,
    MessageReadStatus? readStatus,
    List<String>? reactions,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      readStatus: readStatus ?? this.readStatus,
      reactions: reactions ?? this.reactions,
    );
  }
}

class Chat {
  final String id;
  final List<UserProfile> participants;
  final String? lastMessage;
  final int unreadCount;
  final String? sharedVaultId;
  final int autoDeleteHours;
  final bool? isPartnerTyping;
  final bool isArchived;
  final int timestamp;

  Chat({
    required this.id,
    required this.participants,
    this.lastMessage,
    required this.unreadCount,
    this.sharedVaultId,
    required this.autoDeleteHours,
    this.isPartnerTyping,
    this.isArchived = false,
    this.timestamp = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participants_ids': participants.map((x) => x.id).toList(), // Store IDs for queries
      'lastMessage': lastMessage,
      'unreadCount': unreadCount,
      'sharedVaultId': sharedVaultId,
      'autoDeleteHours': autoDeleteHours,
      'isPartnerTyping': isPartnerTyping,
      'isArchived': isArchived,
      'timestamp': timestamp == 0 ? FieldValue.serverTimestamp() : timestamp,
    };
  }

  factory Chat.fromMap(Map<String, dynamic> map, List<UserProfile> resolvedParticipants) {
    int ts = 0;
    if (map['timestamp'] is Timestamp) {
      ts = (map['timestamp'] as Timestamp).millisecondsSinceEpoch;
    } else if (map['timestamp'] is int) {
      ts = map['timestamp'];
    }

    return Chat(
      id: map['id'] ?? '',
      participants: resolvedParticipants,
      lastMessage: map['lastMessage'],
      unreadCount: map['unreadCount'] ?? 0,
      sharedVaultId: map['sharedVaultId'],
      autoDeleteHours: map['autoDeleteHours'] ?? 24,
      isPartnerTyping: map['isPartnerTyping'],
      isArchived: map['isArchived'] ?? false,
      timestamp: ts,
    );
  }

  Chat copyWith({
    String? id,
    List<UserProfile>? participants,
    String? lastMessage,    int? unreadCount,
    String? sharedVaultId,
    int? autoDeleteHours,
    bool? isPartnerTyping,
    bool? isArchived,
    int? timestamp,
  }) {
    return Chat(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      sharedVaultId: sharedVaultId ?? this.sharedVaultId,
      autoDeleteHours: autoDeleteHours ?? this.autoDeleteHours,
      isPartnerTyping: isPartnerTyping ?? this.isPartnerTyping,
      isArchived: isArchived ?? this.isArchived,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
