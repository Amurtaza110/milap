import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:milap/providers/user_provider.dart';
import 'package:milap/screens/auth/login_screen.dart';
import 'package:milap/screens/auth/otp_screen.dart';
import 'package:milap/screens/onboarding/onboarding_screen.dart';
import 'package:milap/screens/home/root_screen.dart';
import 'package:milap/theme/app_theme.dart';
import 'package:milap/services/push_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase using native configuration (google-services.json)
  await Firebase.initializeApp();

  // Initialize Push Notifications
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

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final firebaseUser = snapshot.data;

        if (firebaseUser == null) {
          return LoginScreen(
            onLogin: (phoneNumber) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => OTPScreen(
                    phoneNumber: phoneNumber,
                    onVerify: (success) {
                      if (success) Navigator.of(context).pop();
                    },
                    onBack: () => Navigator.of(context).pop(),
                  ),
                ),
              );
            },
          );
        }

        if (!userProvider.isInitialLoadDone) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (userProvider.user == null) {
          return OnboardingScreen(
            phoneNumber: firebaseUser.phoneNumber ?? '',
            uid: firebaseUser.uid,
            onComplete: (profile) async {
              await userProvider.updateProfile(profile);
            },
          );
        }

        // Successfully authenticated and profile loaded
        // Update the FCM token for push notifications
        PushNotificationService().updateToken(userProvider.user!.id);

        return const RootScreen();
      },
    );
  }
}
