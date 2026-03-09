import 'package:cloud_firestore/cloud_firestore.dart';

enum MatchStatus { pending, accepted, rejected }

class MatchRequest {
  final String id;
  final String senderId;
  final String receiverId;
  final String senderName;
  final String senderPhoto;
  final String receiverName;
  final String receiverPhoto;
  final MatchStatus status;
  final DateTime createdAt;

  MatchRequest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.senderName,
    required this.senderPhoto,
    required this.receiverName,
    required this.receiverPhoto,
    this.status = MatchStatus.pending,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'senderName': senderName,
      'senderPhoto': senderPhoto,
      'receiverName': receiverName,
      'receiverPhoto': receiverPhoto,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory MatchRequest.fromMap(Map<String, dynamic> map) {
    return MatchRequest(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderPhoto: map['senderPhoto'] ?? '',
      receiverName: map['receiverName'] ?? '',
      receiverPhoto: map['receiverPhoto'] ?? '',
      status: MatchStatus.values.firstWhere((e) => e.name == map['status'], orElse: () => MatchStatus.pending),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
