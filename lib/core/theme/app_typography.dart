import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Typography: [Vazirmatn] for Persian (RTL), [Poppins] for English content.
/// English content is ALWAYS rendered LTR via [En] widget in ui_kit.dart.
class AppTypography {
  AppTypography._();

  static const String faFamily = 'Vazirmatn';
  static const String enFamily = 'Poppins';

  /// Dark theme text styles.
  static TextTheme dark() => const TextTheme(
        displaySmall: TextStyle(
          fontFamily: faFamily,
          fontSize: 32,
          height: 1.35,
          fontWeight: FontWeight.w700,
          color: AppColors.textDarkMode,
        ),
        headlineMedium: TextStyle(
          fontFamily: faFamily,
          fontSize: 26,
          height: 1.4,
          fontWeight: FontWeight.w700,
          color: AppColors.textDarkMode,
        ),
        headlineSmall: TextStyle(
          fontFamily: faFamily,
          fontSize: 22,
          height: 1.4,
          fontWeight: FontWeight.w700,
          color: AppColors.textDarkMode,
        ),
        titleLarge: TextStyle(
          fontFamily: faFamily,
          fontSize: 19,
          height: 1.45,
          fontWeight: FontWeight.w600,
          color: AppColors.textDarkMode,
        ),
        titleMedium: TextStyle(
          fontFamily: faFamily,
          fontSize: 16,
          height: 1.45,
          fontWeight: FontWeight.w600,
          color: AppColors.textDarkMode,
        ),
        titleSmall: TextStyle(
          fontFamily: faFamily,
          fontSize: 14,
          height: 1.5,
          fontWeight: FontWeight.w600,
          color: AppColors.textDarkMode,
        ),
        bodyLarge: TextStyle(
          fontFamily: faFamily,
          fontSize: 16,
          height: 1.8,
          fontWeight: FontWeight.w400,
          color: AppColors.textDarkMode,
        ),
        bodyMedium: TextStyle(
          fontFamily: faFamily,
          fontSize: 14,
          height: 1.75,
          fontWeight: FontWeight.w400,
          color: AppColors.textDarkMode,
        ),
        bodySmall: TextStyle(
          fontFamily: faFamily,
          fontSize: 12.5,
          height: 1.7,
          fontWeight: FontWeight.w400,
          color: AppColors.mutedDark,
        ),
        labelLarge: TextStyle(
          fontFamily: faFamily,
          fontSize: 15,
          height: 1.4,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        labelMedium: TextStyle(
          fontFamily: faFamily,
          fontSize: 13,
          height: 1.4,
          fontWeight: FontWeight.w500,
          color: AppColors.textDarkMode,
        ),
        labelSmall: TextStyle(
          fontFamily: faFamily,
          fontSize: 11,
          height: 1.4,
          fontWeight: FontWeight.w500,
          color: AppColors.mutedDark,
        ),
      );

  /// Light theme text styles.
  static TextTheme light() => const TextTheme(
        displaySmall: TextStyle(
          fontFamily: faFamily,
          fontSize: 32,
          height: 1.35,
          fontWeight: FontWeight.w700,
          color: AppColors.textLightMode,
        ),
        headlineMedium: TextStyle(
          fontFamily: faFamily,
          fontSize: 26,
          height: 1.4,
          fontWeight: FontWeight.w700,
          color: AppColors.textLightMode,
        ),
        headlineSmall: TextStyle(
          fontFamily: faFamily,
          fontSize: 22,
          height: 1.4,
          fontWeight: FontWeight.w700,
          color: AppColors.textLightMode,
        ),
        titleLarge: TextStyle(
          fontFamily: faFamily,
          fontSize: 19,
          height: 1.45,
          fontWeight: FontWeight.w600,
          color: AppColors.textLightMode,
        ),
        titleMedium: TextStyle(
          fontFamily: faFamily,
          fontSize: 16,
          height: 1.45,
          fontWeight: FontWeight.w600,
          color: AppColors.textLightMode,
        ),
        titleSmall: TextStyle(
          fontFamily: faFamily,
          fontSize: 14,
          height: 1.5,
          fontWeight: FontWeight.w600,
          color: AppColors.textLightMode,
        ),
        bodyLarge: TextStyle(
          fontFamily: faFamily,
          fontSize: 16,
          height: 1.8,
          fontWeight: FontWeight.w400,
          color: AppColors.textLightMode,
        ),
        bodyMedium: TextStyle(
          fontFamily: faFamily,
          fontSize: 14,
          height: 1.75,
          fontWeight: FontWeight.w400,
          color: AppColors.textLightMode,
        ),
        bodySmall: TextStyle(
          fontFamily: faFamily,
          fontSize: 12.5,
          height: 1.7,
          fontWeight: FontWeight.w400,
          color: AppColors.mutedLight,
        ),
        labelLarge: TextStyle(
          fontFamily: faFamily,
          fontSize: 15,
          height: 1.4,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        labelMedium: TextStyle(
          fontFamily: faFamily,
          fontSize: 13,
          height: 1.4,
          fontWeight: FontWeight.w500,
          color: AppColors.textLightMode,
        ),
        labelSmall: TextStyle(
          fontFamily: faFamily,
          fontSize: 11,
          height: 1.4,
          fontWeight: FontWeight.w500,
          color: AppColors.mutedLight,
        ),
      );

  /// English (Poppins) style override — use inside an [En] LTR context.
  static TextStyle en({
    double fontSize = 16,
    FontWeight weight = FontWeight.w500,
    Color? color,
    double height = 1.5,
  }) {
    return TextStyle(
      fontFamily: enFamily,
      fontSize: fontSize,
      height: height,
      fontWeight: weight,
      color: color,
      letterSpacing: 0.1,
    );
  }
}
