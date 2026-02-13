import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _showLogo = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _showLogo = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 1000),
              opacity: _showLogo ? 1.0 : 0.0,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 1000),
                offset: _showLogo ? Offset.zero : const Offset(0, 0.1),
                curve: Curves.easeOutCubic,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 128,
                      height: 128,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(35),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'M',
                          style: AppTextStyles.h1.copyWith(
                            color: Colors.white,
                            fontSize: 72,
                            letterSpacing: -5.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'Milap',
                      style: AppTextStyles.h1.copyWith(
                        fontSize: 48,
                        color: AppColors.textMain,
                        letterSpacing: -2.0,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'DIL SE DIL TAK',
                      style: AppTextStyles.label.copyWith(
                        fontSize: 14,
                        color: AppColors.primary,
                        letterSpacing: 2.8,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 64,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < 3; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        )
                            .animate(
                                onPlay: (controller) => controller.repeat())
                            .moveY(
                                begin: 0,
                                end: -8,
                                duration: 600.ms,
                                delay: (200 * i).ms,
                                curve: Curves.easeInOut)
                            .then()
                            .moveY(begin: -8, end: 0, duration: 600.ms),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'PREMIUM PAKISTANI CONNECTIONS',
                  style: AppTextStyles.label.copyWith(
                    fontSize: 10,
                    color: AppColors.textExtraLight,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
