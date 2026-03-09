import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';

class AuthResult {
  final User? user;
  final bool isNewUser;
  AuthResult(this.user, this.isNewUser);
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get userStream => _auth.authStateChanges();
  String? get currentUid => _auth.currentUser?.uid;

  Future<void> sendOTP({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) codeSent,
    required void Function(FirebaseAuthException e) verificationFailed,
  }) async {
    debugPrint('AuthService: Attempting to send OTP to $phoneNumber');
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint('AuthService: Auto-verification completed');
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          String errorMessage = 'Verification Failed';
          switch (e.code) {
            case 'invalid-phone-number':
              errorMessage = 'The provided phone number is not valid.';
              break;
            case 'quota-exceeded':
              errorMessage = 'SMS quota exceeded. Please try again later.';
              break;
            case 'captcha-check-failed':
              errorMessage = 'reCAPTCHA verification failed. Please try again.';
              break;
            case 'app-not-authorized':
              errorMessage =
                  'App not authorized. Check SHA-1/SHA-256 in Firebase Console.';
              break;
            default:
              errorMessage = e.message ?? 'An unknown error occurred.';
          }
          debugPrint('AuthService: $errorMessage (Code: ${e.code})');
          verificationFailed(e);
        },
        codeSent: (String verificationId, int? resendToken) {
          debugPrint('AuthService: OTP sent. Verification ID: $verificationId');
          codeSent(verificationId, resendToken);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint(
              'AuthService: Auto-retrieval timeout. ID: $verificationId');
        },
      );
    } catch (e) {
      debugPrint('AuthService: Unexpected error in sendOTP: $e');
      rethrow;
    }
  }

  Future<AuthResult> verifyOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    debugPrint('AuthService: Verifying OTP $smsCode for ID $verificationId');
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      bool isNewUser = false;
      if (userCredential.user != null) {
        final doc =
            await _db.collection('users').doc(userCredential.user!.uid).get();
        if (!doc.exists) {
          isNewUser = true;
          debugPrint(
              'AuthService: New user detected: ${userCredential.user!.uid}');
        } else {
          debugPrint(
              'AuthService: Returning user detected: ${userCredential.user!.uid}');
        }
      }

      return AuthResult(userCredential.user, isNewUser);
    } catch (e) {
      debugPrint('AuthService: Error in verifyOTP: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserProfile.fromMap(doc.data()!);
    }
    return null;
  }
}
