import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user_profile.dart';

class UserProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  User? _firebaseUser;
  UserProfile? _currentUser;
  bool _isLoading = false;
  String? _verificationId;

  // Getters
  User? get firebaseUser => _firebaseUser;
  UserProfile? get user => _currentUser;
  bool get isLoading => _isLoading;
  bool get isInitialLoadDone => _isInitialLoadDone;
  bool _isInitialLoadDone = false;

  UserProvider() {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _authService.userStream.listen((User? user) async {
      _firebaseUser = user;
      if (user != null) {
        // If logged in, fetch profile
        _currentUser = await _userService.fetchProfile(user.uid);
      } else {
        _currentUser = null;
      }
      _isInitialLoadDone = true;
      notifyListeners();
    });
  }

  /// Step 1: Request OTP
  Future<void> sendOTP(String phoneNumber, {required Function(String) onSuccess, required Function(String) onError}) async {
    _isLoading = true;
    notifyListeners();

    await _authService.verifyPhone(
      phoneNumber: '+92$phoneNumber',
      onCodeSent: (verificationId, resendToken) {
        _verificationId = verificationId;
        _isLoading = false;
        notifyListeners();
        onSuccess(verificationId);
      },
      onVerificationFailed: (e) {
        _isLoading = false;
        notifyListeners();
        onError(e.message ?? "Verification failed");
      },
    );
  }

  /// Step 2: Verify OTP
  Future<bool> verifyOTP(String smsCode) async {
    if (_verificationId == null) return false;
    
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signInWithOTP(
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

  Future<void> updateProfile(UserProfile profile) async {
    await _userService.updateProfile(profile);
    _currentUser = profile;
    notifyListeners();
  }

  void logout() async {
    await _authService.signOut();
  }
}
