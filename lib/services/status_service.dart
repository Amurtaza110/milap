import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/status.dart';

class StatusService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static final StatusService _instance = StatusService._internal();
  factory StatusService() => _instance;
  StatusService._internal();

  /// Stream all fresh statuses (last 24 hours) from all users
  Stream<List<Status>> streamFreshStatuses() {
    final twentyFourHoursAgo = DateTime.now()
        .subtract(const Duration(hours: 24))
        .millisecondsSinceEpoch;

    return _db
        .collection('statuses')
        .where('timestamp', isGreaterThanOrEqualTo: twentyFourHoursAgo)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Status.fromMap(doc.data())).toList());
  }

  /// Upload a new status
  Future<void> uploadStatus(Status status) async {
    await _db.collection('statuses').doc(status.id).set(status.toMap());
  }

  /// Mark status as seen by current user
  Future<void> markStatusSeen(String statusId, StatusViewer viewer) async {
    await _db.collection('statuses').doc(statusId).update({
      'viewers': FieldValue.arrayUnion([viewer.toMap()]),
    });
  }

  /// Delete a status
  Future<void> deleteStatus(String statusId) async {
    await _db.collection('statuses').doc(statusId).delete();
  }
}
