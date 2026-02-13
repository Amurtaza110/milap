import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_profile.dart';
import '../models/social_event.dart';
import '../services/user_service.dart';
import '../services/event_service.dart';
import '../services/hearts_service.dart';
import '../services/auth_service.dart';

class UserProvider with ChangeNotifier {
  UserProfile? _currentUser;
  final UserService _userService = UserService();
  final EventService _eventService = EventService();
  final HeartsService _heartsService = HeartsService();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _verificationId;

  UserProfile? get user => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get verificationId => _verificationId;

  UserProvider() {
    _initAuthListener();
  }

  void _initAuthListener() {
    _authService.userStream.listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        _isLoading = true;
        notifyListeners();

        final profile = await _userService.fetchProfile(firebaseUser.uid);
        _currentUser = profile;
        _isLoading = false;
      } else {
        _currentUser = null;
      }
      notifyListeners();
    });
  }

  Future<void> sendOTP(String phone,
      {required Function(String) onCodeSent,
      required Function(String) onError}) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.sendOTP(
        phoneNumber: '+92$phone',
        codeSent: (verificationId, resendToken) {
          _verificationId = verificationId;
          _isLoading = false;
          notifyListeners();
          onCodeSent(verificationId);
        },
        verificationFailed: (e) {
          _isLoading = false;
          notifyListeners();
          onError(e.message ?? 'Verification failed');
        },
      );
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      onError(e.toString());
    }
  }

  Future<bool> verifyOTP(String smsCode) async {
    if (_verificationId == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      await _authService.verifyOTP(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Create or update profile in Firestore
  Future<void> updateProfile(UserProfile profile) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _userService.updateProfile(profile);
      _currentUser = profile;
    } catch (e) {
      debugPrint('Error updating profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Purchase hearts and sync with Firestore
  Future<bool> buyHearts(HeartPackage package) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final success = await _heartsService.purchaseHearts(
        _currentUser!.id,
        _currentUser!.heartsBalance,
        package,
      );

      if (success) {
        // Optimistic update locally
        _currentUser = _currentUser!.copyWith(
          heartsBalance: _currentUser!.heartsBalance + package.hearts,
          lastHeartRefill: DateTime.now().toIso8601String(),
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error buying hearts: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Book an event
  Future<bool> bookEvent(SocialEvent event, EventPackage package) async {
    if (_currentUser == null) return false;

    try {
      final success = await _eventService.bookEvent(
        userId: _currentUser!.id,
        eventId: event.id,
        packageId: package.id,
        price: package.price,
      );
      return success;
    } catch (e) {
      debugPrint('Error booking event: $e');
      return false;
    }
  }

  /// Alias for updateProfile to support existing UI code
  void updateUser(UserProfile profile) {
    updateProfile(profile);
  }

  /// Alias for setting current user, used during onboarding/login
  void setCurrentUser(UserProfile? profile) {
    if (profile != null) {
      updateProfile(profile);
    } else {
      _currentUser = null;
      notifyListeners();
    }
  }

  /// Required for some legacy navigation guards
  Future<void> checkSession() async {
    // Current user is already managed by _initAuthListener
    // This exists to prevent breaking existing calls
    notifyListeners();
  }

  void logout() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }
}
