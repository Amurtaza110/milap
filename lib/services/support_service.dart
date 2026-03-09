import 'package:cloud_firestore/cloud_firestore.dart';

class SupportService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static final SupportService _instance = SupportService._internal();
  factory SupportService() => _instance;
  SupportService._internal();

  /// Submit a support ticket to Firestore
  Future<void> submitTicket({
    required String userId,
    required String userName,
    required String category,
    required String message,
    required bool isGold,
  }) async {
    final docRef = _db.collection('support_tickets').doc();
    await docRef.set({
      'id': docRef.id,
      'userId': userId,
      'userName': userName,
      'category': category,
      'issue': message,
      'status': 'OPEN',
      'isGold': isGold,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
}
