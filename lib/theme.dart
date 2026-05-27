import 'package:flutter/material.dart';

// ── Light Theme Colors ────────────────────────────────────────────────────────

class LightColors {
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
  static const Color navBarBg = Color(0xFFFFFFFF);
}

// ── Dark Theme Colors ─────────────────────────────────────────────────────────

class DarkColors {
  static const Color primary = Color(0xFF6BAA6B);
  static const Color primaryLight = Color(0xFF8BC34A);
  static const Color primaryDark = Color(0xFF2E7D32);
  static const Color secondary = Color(0xFFC0A060);
  static const Color accent = Color(0xFFE8B86D);
  static const Color background = Color(0xFF121212);
  static const Color cardBackground = Color(0xFF1E1E1E);
  static const Color textDark = Color(0xFFF5F0EB);
  static const Color textMedium = Color(0xFFB0A898);
  static const Color textLight = Color(0xFF7A7268);
  static const Color border = Color(0xFF333333);
  static const Color success = Color(0xFF66BB6A);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFEF5350);
  static const Color successLight = Color(0xFF1B3A1B);
  static const Color warningLight = Color(0xFF3A2E1B);
  static const Color errorLight = Color(0xFF3A1B1B);
  static const Color bannerGreen = Color(0xFF1A3A1A);
  static const Color navBarBg = Color(0xFF1E1E1E);
}

// ── Theme Colors Provider ─────────────────────────────────────────────────────

class ThemeColors {
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color secondary;
  final Color accent;
  final Color background;
  final Color cardBackground;
  final Color textDark;
  final Color textMedium;
  final Color textLight;
  final Color border;
  final Color success;
  final Color warning;
  final Color error;
  final Color successLight;
  final Color warningLight;
  final Color errorLight;
  final Color bannerGreen;
  final Color navBarBg;

  const ThemeColors({
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.cardBackground,
    required this.textDark,
    required this.textMedium,
    required this.textLight,
    required this.border,
    required this.success,
    required this.warning,
    required this.error,
    required this.successLight,
    required this.warningLight,
    required this.errorLight,
    required this.bannerGreen,
    required this.navBarBg,
  });

  static const light = ThemeColors(
    primary: LightColors.primary,
    primaryLight: LightColors.primaryLight,
    primaryDark: LightColors.primaryDark,
    secondary: LightColors.secondary,
    accent: LightColors.accent,
    background: LightColors.background,
    cardBackground: LightColors.cardBackground,
    textDark: LightColors.textDark,
    textMedium: LightColors.textMedium,
    textLight: LightColors.textLight,
    border: LightColors.border,
    success: LightColors.success,
    warning: LightColors.warning,
    error: LightColors.error,
    successLight: LightColors.successLight,
    warningLight: LightColors.warningLight,
    errorLight: LightColors.errorLight,
    bannerGreen: LightColors.bannerGreen,
    navBarBg: LightColors.navBarBg,
  );

  static const dark = ThemeColors(
    primary: DarkColors.primary,
    primaryLight: DarkColors.primaryLight,
    primaryDark: DarkColors.primaryDark,
    secondary: DarkColors.secondary,
    accent: DarkColors.accent,
    background: DarkColors.background,
    cardBackground: DarkColors.cardBackground,
    textDark: DarkColors.textDark,
    textMedium: DarkColors.textMedium,
    textLight: DarkColors.textLight,
    border: DarkColors.border,
    success: DarkColors.success,
    warning: DarkColors.warning,
    error: DarkColors.error,
    successLight: DarkColors.successLight,
    warningLight: DarkColors.warningLight,
    errorLight: DarkColors.errorLight,
    bannerGreen: DarkColors.bannerGreen,
    navBarBg: DarkColors.navBarBg,
  );
}

// ── Context Extension ─────────────────────────────────────────────────────────

extension ThemeColorsContext on BuildContext {
  ThemeColors get colors {
    return Theme.of(this).brightness == Brightness.dark
        ? ThemeColors.dark
        : ThemeColors.light;
  }
}

// ── Text Styles ───────────────────────────────────────────────────────────────

class AppTextStyles {
  static const heading1 = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: LightColors.primary,
    fontFamily: 'Poppins',
  );

  static const heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: LightColors.primary,
    fontFamily: 'Poppins',
  );

  static const heading3 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: LightColors.textDark,
    fontFamily: 'Poppins',
  );

  static const body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: LightColors.textMedium,
    fontFamily: 'Poppins',
  );

  static const bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: LightColors.textLight,
    fontFamily: 'Poppins',
  );

  static const label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    fontFamily: 'Poppins',
  );
}

// ── Backward compatibility alias ──────────────────────────────────────────────

class AppColors extends LightColors {}
