import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2C5E35);
  static const Color primaryLight = Color(0xFF4A7C3F);
  static const Color primaryDark = Color(0xFF1E3F24);
  static const Color secondary = Color(0xFFA0784A);
  static const Color accent = Color(0xFFE8B86D);
  static const Color background = Color(0xFFFAF7F2);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1E1E1E);
  static const Color textMedium = Color(0xFF5C5248);
  static const Color textLight = Color(0xFF9E9488);
  static const Color border = Color(0xFFE2D9CC);
  static const Color success = Color(0xFF52A447);
  static const Color warning = Color(0xFFE89B2F);
  static const Color error = Color(0xFFD94F4F);
  static const Color successLight = Color(0xFFEDF7EC);
  static const Color warningLight = Color(0xFFFDF4E3);
  static const Color errorLight = Color(0xFFFDEDED);
  static const Color bannerGreen = Color(0xFF2C5E35);
}

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    fontFamily: 'Poppins',
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    fontFamily: 'Poppins',
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    fontFamily: 'Poppins',
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textMedium,
    fontFamily: 'Poppins',
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
    fontFamily: 'Poppins',
  );

  static const TextStyle label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    fontFamily: 'Poppins',
  );
}
