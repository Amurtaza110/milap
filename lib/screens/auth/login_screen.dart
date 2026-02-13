import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_button_styles.dart';

class LoginScreen extends StatefulWidget {
  final Function(String)
      onLogin; // phoneNumber is still passed for legacy RootScreen sync if needed

  const LoginScreen({Key? key, required this.onLogin}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();

  void _handleContinue() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.sendOTP(
      phone,
      onCodeSent: (vid) {
        widget.onLogin(phone);
      },
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 80),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'M',
                  style: AppTextStyles.h1
                      .copyWith(color: Colors.white, fontSize: 40),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Welcome to Milap',
              style: AppTextStyles.h1.copyWith(
                color: AppColors.textMain,
                letterSpacing: -1.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'PREMIUM PAKISTANI SOCIAL HUB',
              style: AppTextStyles.label.copyWith(
                color: AppColors.textLight,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 64),
            Text(
              'PHONE NUMBER',
              style: AppTextStyles.label.copyWith(
                color: AppColors.textExtraLight,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.transparent, width: 2),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    child: Text(
                      '+92',
                      style:
                          AppTextStyles.h3.copyWith(color: AppColors.primary),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style:
                          AppTextStyles.h3.copyWith(color: AppColors.textMain),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '336xxxxxxx',
                        hintStyle: TextStyle(color: AppColors.textExtraLight),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: userProvider.isLoading ? null : _handleContinue,
                style: AppButtonStyles.primary,
                child: userProvider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('CONTINUE'),
              ),
            ),
            const SizedBox(height: 48),
            Center(
              child: Text(
                'SECURED BY MILAP PRIVACY PROTOCOL',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textExtraLight,
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
