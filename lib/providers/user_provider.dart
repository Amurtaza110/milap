import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/match_service.dart';
import '../services/hearts_service.dart';

class AuthResult {
  final User? user;
  final bool isNewUser;
  AuthResult(this.user, this.isNewUser);
}

class UserProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final MatchService _matchService = MatchService();
  final HeartsService _heartsService = HeartsService();

  User? _firebaseUser;
  UserProfile? _currentUser;
  bool _isLoading = false;
  String? _verificationId;
  bool _isInitialLoadDone = false;

  // Getters
  User? get firebaseUser => _firebaseUser;
  UserProfile? get user => _currentUser;
  bool get isLoading => _isLoading;
  bool get isInitialLoadDone => _isInitialLoadDone;

  UserProvider() {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _authService.userStream.listen((User? user) async {
      _firebaseUser = user;
      if (user != null) {
        _currentUser = await _userService.fetchProfile(user.uid);
      } else {
        _currentUser = null;
      }
      _isInitialLoadDone = true;
      notifyListeners();
    });
  }

  /// Step 1: Request OTP
  Future<void> sendOTP(String phoneNumber, {required Function(String) onCodeSent, required Function(String) onError}) async {
    _isLoading = true;
    notifyListeners();

    await _authService.verifyPhone(
      phoneNumber: '+92$phoneNumber',
      onCodeSent: (verificationId, resendToken) {
        _verificationId = verificationId;
        _isLoading = false;
        notifyListeners();
        onCodeSent(verificationId);
      },
      onVerificationFailed: (e) {
        _isLoading = false;
        notifyListeners();
        onError(e.message ?? "Verification failed");
      },
    );
  }

  /// Step 2: Verify OTP
  Future<AuthResult> verifyOTP(String smsCode) async {
    if (_verificationId == null) throw Exception("No verification ID");
    
    _isLoading = true;
    notifyListeners();

    try {
      final credential = await _authService.signInWithOTP(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );
      
      bool isNew = false;
      if (credential.user != null) {
        final profile = await _userService.fetchProfile(credential.user!.uid);
        isNew = profile == null;
      }

      _isLoading = false;
      notifyListeners();
      return AuthResult(credential.user, isNew);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateProfile(UserProfile profile) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _userService.updateProfile(profile);
      _currentUser = profile;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Alias for compatibility
  void updateUser(UserProfile profile) => updateProfile(profile);

  Future<bool> sendMatchRequest(UserProfile targetUser) async {
    if (_currentUser == null) return false;
    return await _matchService.sendMatchRequest(sender: _currentUser!, receiver: targetUser);
  }

  Future<void> earnHeartByAd() async {
    if (_currentUser == null) return;
    await _heartsService.earnHeartByAd(_currentUser!.id, _currentUser!.heartsBalance);
  }

  Future<bool> processHeartPurchase(HeartPackage package, String method) async {
    if (_currentUser == null) return false;
    return await _heartsService.processPurchase(
      uid: _currentUser!.id,
      currentBalance: _currentUser!.heartsBalance,
      package: package,
      method: method
    );
  }

  void logout() async {
    await _authService.signOut();
  }
}
