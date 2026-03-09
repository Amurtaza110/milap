import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_button_styles.dart';
import '../../services/auth_service.dart';

class OTPScreen extends StatefulWidget {
  final String phoneNumber;
  final Function(bool) onVerify; // Success callback
  final VoidCallback onBack;

  const OTPScreen({
    Key? key,
    required this.phoneNumber,
    required this.onVerify,
    required this.onBack,
  }) : super(key: key);

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  int _timerValue = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerValue > 0) {
        setState(() => _timerValue--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onOtpChanged(int index, String value) {
    if (value.length > 1) {
      _controllers[index].text = value.substring(value.length - 1);
    }
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    // Automatically verify when last digit is entered
    if (value.isNotEmpty && index == 5) {
      _handleVerify();
    }
  }

  Future<void> _handleVerify() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length < 6) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    try {
      final AuthResult result = await userProvider.verifyOTP(otp);

      if (result.user != null) {
        widget.onVerify(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Verification failed. Please try again.'),
              backgroundColor: Colors.redAccent),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 48),
            GestureDetector(
              onTap: widget.onBack,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              ),
            ),
            const SizedBox(height: 48),
            Text(
              'Verify Phone',
              style: AppTextStyles.h1.copyWith(
                fontSize: 32,
                color: AppColors.textMain,
                letterSpacing: -1.0,
              ),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: AppTextStyles.body.copyWith(
                    fontSize: 16, color: AppColors.textLight, height: 1.5),
                children: [
                  const TextSpan(text: 'Enter the 6-digit code sent to \n'),
                  TextSpan(
                    text: '+92 ${widget.phoneNumber}',
                    style: AppTextStyles.h4.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: (MediaQuery.of(context).size.width - 64 - 40) / 6,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      onChanged: (v) => _onOtpChanged(index, v),
                      style: AppTextStyles.h2
                          .copyWith(fontSize: 24, color: AppColors.textMain),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: AppColors.background,
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              BorderSide(color: AppColors.background, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: userProvider.isLoading ? null : _handleVerify,
                style: AppButtonStyles.primary,
                child: userProvider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('VERIFY CODE'),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: RichText(
                text: TextSpan(
                  style: AppTextStyles.label.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textExtraLight),
                  children: [
                    const TextSpan(text: 'Resend code in '),
                    TextSpan(
                      text: '${_timerValue}s',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
