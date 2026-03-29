import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:milap/providers/user_provider.dart';
import 'package:milap/screens/auth/login_screen.dart';
import 'package:milap/screens/auth/otp_screen.dart';
import 'package:milap/screens/onboarding/onboarding_screen.dart';
import 'package:milap/screens/onboarding/splash_screen.dart';
import 'package:milap/screens/home/root_screen.dart';
import 'package:milap/theme/app_theme.dart';
import 'package:milap/services/push_notification_service.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // SECURE & FAST OTP FIX:
  // Use Debug Provider for testing, Play Integrity for production
  await FirebaseAppCheck.instance.activate(
    androidProvider: kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.deviceCheck,
  );

  final pushService = PushNotificationService();
  await pushService.initialize();
  
  runApp(const MilapApp());
}

class MilapApp extends StatelessWidget {
  const MilapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'Milap',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    if (_showSplash || !userProvider.isInitialLoadDone) {
      return const SplashScreen();
    }

    if (userProvider.firebaseUser == null) {
      return LoginScreen(
        onLogin: (phoneNumber) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => OTPScreen(
                phoneNumber: phoneNumber,
                onVerify: (success) {
                  if (success) {
                    Navigator.of(context).pop();
                  }
                },
                onBack: () => Navigator.of(context).pop(),
              ),
            ),
          );
        },
      );
    }

    if (userProvider.user == null) {
      return OnboardingScreen(
        phoneNumber: userProvider.firebaseUser?.phoneNumber ?? '',
        uid: userProvider.firebaseUser!.uid,
        onComplete: (profile) async {
          await userProvider.updateProfile(profile);
        },
      );
    }

    PushNotificationService().updateToken(userProvider.user!.id);
    return const RootScreen();
  }
}
