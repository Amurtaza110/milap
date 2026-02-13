import 'user_profile.dart';

enum MessageReadStatus { sent, delivered, read }

enum MessageType {
  text,
  image,
  audio
} // Inferred from backend guide, though not in types.ts explicitly but good to have. Sticking to types.ts for now logic.

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
    return Message(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      timestamp: map['timestamp'] ?? 0,
      isEncrypted: map['isEncrypted'] ?? false,
      readStatus: MessageReadStatus.values[map['readStatus'] ?? 0],
      reactions:
          map['reactions'] != null ? List<String>.from(map['reactions']) : null,
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

  Chat({
    required this.id,
    required this.participants,
    this.lastMessage,
    required this.unreadCount,
    this.sharedVaultId,
    required this.autoDeleteHours,
    this.isPartnerTyping,
    this.isArchived = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participants': participants.map((x) => x.toMap()).toList(),
      'lastMessage': lastMessage,
      'unreadCount': unreadCount,
      'sharedVaultId': sharedVaultId,
      'autoDeleteHours': autoDeleteHours,
      'isPartnerTyping': isPartnerTyping,
      'isArchived': isArchived,
    };
  }

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      id: map['id'] ?? '',
      participants: List<UserProfile>.from(
          map['participants']?.map((x) => UserProfile.fromMap(x)) ?? []),
      lastMessage: map['lastMessage'],
      unreadCount: map['unreadCount'] ?? 0,
      sharedVaultId: map['sharedVaultId'],
      autoDeleteHours: map['autoDeleteHours'] ?? 24,
      isPartnerTyping: map['isPartnerTyping'],
      isArchived: map['isArchived'] ?? false,
    );
  }

  Chat copyWith({
    String? id,
    List<UserProfile>? participants,
    String? lastMessage,
    int? unreadCount,
    String? sharedVaultId,
    int? autoDeleteHours,
    bool? isPartnerTyping,
    bool? isArchived,
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
    );
  }
}
