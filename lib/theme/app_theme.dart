import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_constants.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: AppTextStyles.base.fontFamily,
      textTheme: TextTheme(
        headlineMedium: AppTextStyles.h1,
        headlineSmall: AppTextStyles.h2,
        titleLarge: AppTextStyles.h3,
        bodyMedium: AppTextStyles.body,
        labelSmall: AppTextStyles.label,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 10,
          shadowColor: AppColors.primary.withOpacity(0.2),
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          ),
          textStyle: AppTextStyles.buttonLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.secondary,
        contentPadding: const EdgeInsets.all(20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        hintStyle: AppTextStyles.base.copyWith(
          color: AppColors.textExtraLight,
          fontWeight: FontWeight.w900,
        ),
      ),
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
        surface: AppColors.surface,
      ),
    );
  }

  static ThemeData get milapPlusTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.milapPlusPrimary,
      scaffoldBackgroundColor: AppColors.milapPlusSecondary,
      fontFamily: AppTextStyles.base.fontFamily,
      textTheme: TextTheme(
        headlineMedium:
            AppTextStyles.h1.copyWith(color: Colors.white, letterSpacing: -0.5),
        headlineSmall:
            AppTextStyles.h2.copyWith(color: Colors.white, letterSpacing: -0.5),
        titleLarge: AppTextStyles.h3.copyWith(color: Colors.white),
        titleMedium: AppTextStyles.h4.copyWith(color: Colors.white),
        bodyMedium:
            AppTextStyles.body.copyWith(color: Colors.white.withOpacity(0.9)),
        bodySmall:
            AppTextStyles.body.copyWith(color: Colors.white70, fontSize: 12),
        labelSmall:
            AppTextStyles.label.copyWith(color: AppColors.milapPlusPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.milapPlusPrimary,
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
          textStyle: AppTextStyles.buttonLarge.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.milapPlusSurface,
        contentPadding: const EdgeInsets.all(20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          borderSide:
              const BorderSide(color: AppColors.milapPlusPrimary, width: 1.5),
        ),
        hintStyle: AppTextStyles.base.copyWith(
          color: Colors.white30,
        ),
        labelStyle: AppTextStyles.body.copyWith(color: Colors.white54),
      ),
      colorScheme: const ColorScheme.dark().copyWith(
        primary: AppColors.milapPlusPrimary,
        secondary: AppColors.milapPlusPrimary,
        error: AppColors.error,
        surface: AppColors.milapPlusSurface,
        onSurface: Colors.white,
      ),
      cardTheme: CardTheme(
        color: AppColors.milapPlusSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        elevation: 0,
      ),
    );
  }

  static BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppConstants.radiusLarge + 5),
    border: Border.all(color: AppColors.border),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  );

  static const Color primary = AppColors.primary;
  static const Color success = AppColors.success;
}
