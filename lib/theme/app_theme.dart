import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  // Surfaces
  static const bg = Color(0xFF0A090D);
  static const bg2 = Color(0xFF0E0D12);
  static const surface = Color(0xFF16151C);
  static const surface2 = Color(0xFF1C1B24);
  static const surface3 = Color(0xFF24222D);
  static const border = Color(0x12FFFFFF);
  static const borderStrong = Color(0x1FFFFFFF);

  // Text
  static const text = Color(0xFFF4F3F7);
  static const muted = Color(0x94F4F3F7);
  static const subtle = Color(0x5CF4F3F7);
  static const faint = Color(0x2EF4F3F7);

  // Brand
  static const violet = Color(0xFF8B6CF6);
  static const violetBright = Color(0xFFA18BFF);
  static const violetSoft = Color(0x298B6CF6);
  static const violetGlow = Color(0x528B6CF6);

  // Semantic
  static const success = Color(0xFF6CE4A3);
  static const successSoft = Color(0x246CE4A3);
  static const warm = Color(0xFFF5B67A);
  static const warmSoft = Color(0x24F5B67A);
  static const hot = Color(0xFFFF8A6B);
  static const hotSoft = Color(0x24FF8A6B);
}

class BeatColors {
  BeatColors._();

  static const morningColor = Color(0xFFF5B67A);
  static const morningBg = Color(0x1FF5B67A);
  static const deepColor = Color(0xFFA18BFF);
  static const deepBg = Color(0x24A18BFF);
  static const middayColor = Color(0xFF7AD1F5);
  static const middayBg = Color(0x1F7AD1F5);
  static const eveningColor = Color(0xFFF57AA3);
  static const eveningBg = Color(0x1FF57AA3);
  static const customColor = Color(0xFFFFC857);
  static const customBg = Color(0x1FFFC857);
}

TextStyle displayText(double size, {Color color = AppColors.text, String? letterSpacing}) {
  return GoogleFonts.instrumentSerif(
    fontSize: size,
    color: color,
    letterSpacing: -0.5,
  );
}

ThemeData buildAppTheme() {
  return ThemeData.dark().copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    primaryColor: AppColors.violet,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.violet,
      brightness: Brightness.dark,
      surface: AppColors.surface,
    ).copyWith(
      primary: AppColors.violet,
      onPrimary: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.text,
    ),
    textTheme: ThemeData.dark().textTheme.apply(
      bodyColor: AppColors.text,
      displayColor: AppColors.text,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.violet),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.hot),
      ),
      labelStyle: const TextStyle(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w500),
      hintStyle: const TextStyle(color: AppColors.subtle, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.violet,
        foregroundColor: Colors.white,
        elevation: 0,
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.violetBright,
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      foregroundColor: AppColors.text,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    dividerColor: AppColors.border,
    dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1, space: 1),
  );
}
