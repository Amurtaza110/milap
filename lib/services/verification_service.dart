import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/verification_request.dart';

class VerificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static final VerificationService _instance = VerificationService._internal();
  factory VerificationService() => _instance;
  VerificationService._internal();

  /// Submit a new verification request
  Future<void> submitRequest(VerificationRequest request) async {
    await _db.collection('verification_requests').doc(request.userId).set(request.toMap());
  }

  /// Stream verification request for a specific user
  Stream<VerificationRequest?> streamUserRequest(String userId) {
    return _db.collection('verification_requests').doc(userId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return VerificationRequest.fromMap(doc.data()!);
      }
      return null;
    });
  }
}
