import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_service.dart';
import '../models/notification.dart';

class VaultSharingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  static final VaultSharingService _instance = VaultSharingService._internal();
  factory VaultSharingService() => _instance;
  VaultSharingService._internal();

  /// Share vault asset with user
  Future<bool> shareVaultAsset({
    required String assetId,
    required String senderId,
    required String senderName,
    required String recipientId,
  }) async {
    try {
      final shareId = '${senderId}_${recipientId}_$assetId';
      
      // 1. Create share record in Firestore
      await _db.collection('vault_shares').doc(shareId).set({
        'id': shareId,
        'assetId': assetId,
        'senderId': senderId,
        'recipientId': recipientId,
        'timestamp': FieldValue.serverTimestamp(),
        'isActive': true,
        'screenshotCount': 0,
      });

      // 2. Notify recipient
      await _notificationService.sendNotification(
        receiverId: recipientId,
        type: NotificationType.system,
        title: 'Private Access Granted',
        message: '$senderName shared a private vault asset with you.',
        senderId: senderId,
      );

      return true;
    } catch (e) {
      print('VaultShare Error: $e');
      return false;
    }
  }

  /// Revoke access to shared vault content
  Future<void> revokeVaultAccess(String senderId, String recipientId, String assetId) async {
    final shareId = '${senderId}_${recipientId}_$assetId';
    await _db.collection('vault_shares').doc(shareId).update({
      'isActive': false,
    });
  }

  /// Check if a user has active access to an asset
  Future<bool> hasAccess(String userId, String assetId) async {
    final snapshot = await _db
        .collection('vault_shares')
        .where('recipientId', isEqualTo: userId)
        .where('assetId', isEqualTo: assetId)
        .where('isActive', isEqualTo: true)
        .get();
    
    return snapshot.docs.isNotEmpty;
  }

  /// Report a screenshot attempt on shared content
  Future<void> reportScreenshot(String shareId, String takerId, String ownerId) async {
    await _db.collection('vault_shares').doc(shareId).update({
      'screenshotCount': FieldValue.increment(1),
    });

    await _notificationService.sendNotification(
      receiverId: ownerId,
      type: NotificationType.security,
      title: 'Security Alert!',
      message: 'Someone attempted a screenshot of your private content.',
      senderId: takerId,
    );
  }
}
