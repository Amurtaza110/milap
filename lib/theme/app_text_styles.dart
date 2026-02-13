import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle get base => GoogleFonts.plusJakartaSans();

  static TextStyle get h1 => base.copyWith(
    fontSize: 36,
    fontWeight: FontWeight.w900,
    color: AppColors.textMain,
    letterSpacing: -1.0,
  );

  static TextStyle get h2 => base.copyWith(
    fontSize: 30,
    fontWeight: FontWeight.w900,
    color: AppColors.textMain,
    letterSpacing: -1.0,
  );

  static TextStyle get h3 => base.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w900,
    color: AppColors.textMain,
  );

  static TextStyle get h4 => base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w900,
    color: AppColors.textMain,
  );

  static TextStyle get body => base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.textLight,
    height: 1.6,
  );

  static TextStyle get label => base.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w900,
    color: AppColors.textMuted,
    letterSpacing: 2.0,
  );

  static TextStyle get buttonLarge => base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w900,
    letterSpacing: 3.2,
  );

  static TextStyle get buttonSmall => base.copyWith(
    fontSize: 9,
    fontWeight: FontWeight.w900,
    letterSpacing: 1.0,
  );
}
