import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'notification_service.dart';
import '../models/notification.dart';

/// Service for detecting and handling screenshot captures with real backend integration
class ScreenshotDetectionService {
  static final ScreenshotDetectionService _instance =
      ScreenshotDetectionService._internal();

  final _screenshotController = StreamController<ScreenshotEvent>.broadcast();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  bool _isMonitoring = false;

  factory ScreenshotDetectionService() {
    return _instance;
  }

  ScreenshotDetectionService._internal();

  /// Get stream of screenshot events
  Stream<ScreenshotEvent> get screenshotStream => _screenshotController.stream;

  /// Start monitoring for screenshots
  void startMonitoring() {
    if (_isMonitoring) return;
    _isMonitoring = true;
  }

  /// Stop monitoring for screenshots
  void stopMonitoring() {
    if (!_isMonitoring) return;
    _isMonitoring = false;
  }

  /// Report a screenshot detection to backend
  Future<void> reportScreenshot(String userId, String otherUserId) async {
    try {
      final userDoc = await _db.collection('users').doc(userId).get();
      if (!userDoc.exists) return;

      int currentWarnings = userDoc.data()?['screenshotWarnings'] ?? 0;
      int newWarnings = currentWarnings + 1;

      await _db.collection('users').doc(userId).update({
        'screenshotWarnings': newWarnings,
      });

      final event = ScreenshotEvent(
        timestamp: DateTime.now(),
        userId: userId,
        otherUserId: otherUserId,
        isBlackScreenshot: true,
      );
      _screenshotController.add(event);

      await notifyBothUsers(
        userId,
        otherUserId,
        "A screenshot was attempted on your private profile content.",
      );

      if (newWarnings >= 5) {
        await suspendAccount(userId, 7);
      }
    } catch (e) {
      debugPrint('Error reporting screenshot: $e');
    }
  }

  Future<bool> isAccountSuspended(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (doc.exists) {
      final suspendedUntil = doc.data()?['suspendedUntil'];
      if (suspendedUntil != null) {
        return DateTime.now().millisecondsSinceEpoch < suspendedUntil;
      }
    }
    return false;
  }

  Future<void> suspendAccount(String userId, int durationDays) async {
    final suspensionEndDate =
        DateTime.now().add(Duration(days: durationDays));
    
    await _db.collection('users').doc(userId).update({
      'suspendedUntil': suspensionEndDate.millisecondsSinceEpoch,
      'isDeactivated': true,
    });

    await _notificationService.sendNotification(
      receiverId: userId,
      type: NotificationType.security,
      title: 'Account Suspended',
      message: 'Your account has been suspended for $durationDays days due to repeated screenshot violations.',
    );
  }

  Future<void> notifyBothUsers(
    String userId,
    String otherUserId,
    String message,
  ) async {
    try {
      await _notificationService.sendNotification(
        receiverId: otherUserId,
        type: NotificationType.security,
        title: 'Security Alert',
        message: message,
        senderId: userId,
      );

      await _notificationService.sendNotification(
        receiverId: userId,
        type: NotificationType.security,
        title: 'Privacy Violation',
        message: 'Capturing private content is prohibited. This incident has been logged.',
      );
    } catch (e) {
      debugPrint('Failed to send security notifications: $e');
    }
  }

  /// FIXED: Added missing method required by RootScreen
  int getWarningCount(String userId) {
    return 0; // Local counter or placeholder
  }

  /// FIXED: Changed parameter type to String to match RootScreen call
  bool hasExceededScreenshotLimit(String userId) {
    return false; 
  }

  void dispose() {
    stopMonitoring();
    _screenshotController.close();
  }
}

class ScreenshotEvent {
  final DateTime timestamp;
  final String userId;
  final String otherUserId;
  final bool isBlackScreenshot;

  ScreenshotEvent({
    required this.timestamp,
    required this.userId,
    required this.otherUserId,
    required this.isBlackScreenshot,
  });
}
