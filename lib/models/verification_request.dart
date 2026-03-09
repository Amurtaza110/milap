import 'package:cloud_firestore/cloud_firestore.dart';

enum VerificationStatus { pending, approved, rejected }

class VerificationRequest {
  final String id;
  final String userId;
  final String userName;
  final String userPhoto;
  final String idFrontUrl;
  final String idBackUrl;
  final String selfieUrl;
  final VerificationStatus status;
  final DateTime createdAt;
  final String? adminComment;

  VerificationRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhoto,
    required this.idFrontUrl,
    required this.idBackUrl,
    required this.selfieUrl,
    this.status = VerificationStatus.pending,
    required this.createdAt,
    this.adminComment,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userPhoto': userPhoto,
      'idFrontUrl': idFrontUrl,
      'idBackUrl': idBackUrl,
      'selfieUrl': selfieUrl,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'adminComment': adminComment,
    };
  }

  factory VerificationRequest.fromMap(Map<String, dynamic> map) {
    return VerificationRequest(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhoto: map['userPhoto'] ?? '',
      idFrontUrl: map['idFrontUrl'] ?? '',
      idBackUrl: map['idBackUrl'] ?? '',
      selfieUrl: map['selfieUrl'] ?? '',
      status: VerificationStatus.values.firstWhere(
        (e) => e.name == (map['status'] ?? 'pending'),
        orElse: () => VerificationStatus.pending,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      adminComment: map['adminComment'],
    );
  }
}
