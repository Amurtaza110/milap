import 'package:flutter/material.dart';
import '../../models/app_screen.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final AppScreen? nextScreen;
  final Function(AppScreen)? onNavigate;

  const PlaceholderScreen({
    Key? key,
    required this.title,
    this.onBack,
    this.nextScreen,
    this.onNavigate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title,
            style: AppTextStyles.h3.copyWith(color: AppColors.textMain)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textMain),
                onPressed: onBack)
            : null,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction,
                size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text('$title Under Construction',
                style: AppTextStyles.h4.copyWith(color: AppColors.textMain)),
            if (onNavigate != null && nextScreen != null)
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: ElevatedButton(
                  onPressed: () => onNavigate!(nextScreen!),
                  child: Text("Go to ${nextScreen.toString().split('.').last}"),
                ),
              )
          ],
        ),
      ),
    );
  }
}
