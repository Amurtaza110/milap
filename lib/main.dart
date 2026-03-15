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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Activate App Check for security and faster OTP
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
  );

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

    // Initial Loading State
    if (_showSplash || !userProvider.isInitialLoadDone) {
      return const SplashScreen();
    }

    // Step 1: User is not logged in
    if (userProvider.firebaseUser == null) {
      return LoginScreen(
        onLogin: (phoneNumber) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => OTPScreen(
                phoneNumber: phoneNumber,
                onVerify: (success) {
                  if (success) {
                    Navigator.of(context).pop(); // Back to AuthWrapper
                  }
                },
                onBack: () => Navigator.of(context).pop(),
              ),
            ),
          );
        },
      );
    }

    // Step 2: User is logged in but has no Firestore profile
    if (userProvider.user == null) {
      return OnboardingScreen(
        phoneNumber: userProvider.firebaseUser?.phoneNumber ?? '',
        uid: userProvider.firebaseUser!.uid,
        onComplete: (profile) async {
          await userProvider.updateProfile(profile);
        },
      );
    }

    // Step 3: Fully Authenticated
    return const RootScreen();
  }
}
