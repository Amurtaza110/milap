import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import '../models/user_profile.dart';
import '../services/user_service.dart';
import '../services/event_service.dart';
import '../services/hearts_service.dart';
import '../services/auth_service.dart';
import '../services/match_service.dart';

class UserProvider with ChangeNotifier {
  UserProfile? _currentUser;
  User? _firebaseUser;
  final UserService _userService = UserService();
  final EventService _eventService = EventService();
  final HeartsService _heartsService = HeartsService();
  final AuthService _authService = AuthService();
  final MatchService _matchService = MatchService();

  StreamSubscription? _profileSubscription;
  bool _isLoading = false;
  bool _isInitialLoadDone = false;
  String? _verificationId;
  bool _hasCheckedRefillThisSession = false;

  UserProfile? get user => _currentUser;
  User? get firebaseUser => _firebaseUser;
  bool get isFirebaseAuthenticated => _firebaseUser != null;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  bool get isInitialLoadDone => _isInitialLoadDone;
  String? get verificationId => _verificationId;

  UserProvider() {
    _initAuthListener();
  }

  void _initAuthListener() {
    _authService.userStream.listen((User? user) {
      _firebaseUser = user;
      _profileSubscription?.cancel();

      if (user != null) {
        _isLoading = true;
        notifyListeners();
        
        _profileSubscription = _userService.streamProfile(user.uid).listen((profile) {
          _currentUser = profile;
          _isLoading = false;
          _isInitialLoadDone = true;
          
          if (profile != null && !_hasCheckedRefillThisSession) {
            _hasCheckedRefillThisSession = true;
            _checkDailyRefill(profile);
          }
          
          notifyListeners();
        });
      } else {
        _currentUser = null;
        _isLoading = false;
        _isInitialLoadDone = true;
        _hasCheckedRefillThisSession = false;
        notifyListeners();
      }
    });
  }

  Future<void> _checkDailyRefill(UserProfile profile) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    if (profile.lastHeartRefill != today) {
      await _heartsService.checkDailyRefill(profile.id, profile.heartsBalance, profile.lastHeartRefill);
    }
  }

  Future<void> updateProfile(UserProfile profile) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _userService.updateProfile(profile);
    } catch (e) {
      debugPrint('Error updating profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Alias for updateProfile to maintain compatibility with existing screens
  void updateUser(UserProfile profile) => updateProfile(profile);

  Future<bool> processHeartPurchase(HeartPackage package, String method) async {
    if (_currentUser == null) return false;
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _heartsService.processPurchase(
        uid: _currentUser!.id,
        currentBalance: _currentUser!.heartsBalance,
        package: package,
        method: method,
      );
      return success;
    } catch (e) {
      debugPrint('Error purchasing hearts: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> earnHeartByAd() async {
    if (_currentUser == null) return;
    await _heartsService.earnHeartByAd(_currentUser!.id, _currentUser!.heartsBalance);
  }

  Future<bool> sendMatchRequest(UserProfile targetUser) async {
    if (_currentUser == null) return false;
    
    try {
      final canSpend = await _heartsService.spendHeart(_currentUser!.id, _currentUser!.heartsBalance, _currentUser!.isMilapGold);
      if (!canSpend) return false;

      final isMutualMatch = await _matchService.sendMatchRequest(
        sender: _currentUser!,
        receiver: targetUser,
      );

      return isMutualMatch;
    } catch (e) {
      debugPrint('Error sending match request: $e');
      return false;
    }
  }

  void logout() async {
    await _authService.signOut();
    _profileSubscription?.cancel();
    _currentUser = null;
    _firebaseUser = null;
    _isInitialLoadDone = false;
    _hasCheckedRefillThisSession = false;
    notifyListeners();
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

  Future<AuthResult> verifyOTP(String smsCode) async {
    if (_verificationId == null) throw Exception('No verification ID');
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _authService.verifyOTP(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );
      return result;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    super.dispose();
  }
}
