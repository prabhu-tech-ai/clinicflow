import 'package:flutter/material.dart';

class AppColors {
  static const teal = Color(0xFF009E95);
  static const tealDark = Color(0xFF007F78);
  static const navy = Color(0xFF14283D);
  static const ink = Color(0xFF1A2B3D);
  static const muted = Color(0xFF728194);
  static const background = Color(0xFFF7FAFC);
  static const border = Color(0xFFE3EAF0);
  static const lavender = Color(0xFFEDEBFF);
  static const mint = Color(0xFFE4F7F4);
}

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      primary: AppColors.teal,
      surface: Colors.white,
    ),
    fontFamily: 'Arial',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.ink,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
      ),
    ),
  );
}
