import 'package:flutter/material.dart';

class AppColors {
  // Light Mode Colors
  static const lightBackground = Color(0xFFF6F7F9);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceGlass = Color(0xCCFFFFFF);
  static const lightTextPrimary = Color(0xFF101215);
  static const lightTextSecondary = Color(0xFF5B6470);
  static const lightAccent = Color(0xFF2FA36B);
  static const lightAccentSoft = Color(0xFFE7F5EE);

  // Dark Mode Colors
  static const darkBackground = Color(0xFF0B0D10);
  static const darkSurface = Color(0xFF1A1D22);
  static const darkSurfaceGlass = Color(0xAA1A1D22);
  static const darkTextPrimary = Color(0xFFF2F4F7);
  static const darkTextSecondary = Color(0xFFA0A8B3);
  static const darkAccent = Color(0xFF4CC38A);
  static const darkAccentSoft = Color(0xFF1E3A2D);

  // Nutrient Colors
  static const protein = Color(0xFF3B82F6); // Blue
  static const carbs = Color(0xFFF59E0B);   // Amber/Orange
  static const fat = Color(0xFF8B5CF6);     // Purple
  static const fiber = Color(0xFF22C55E);   // Green
  static const sugar = Color(0xFFEC4899);   // Pink
  static const water = Color(0xFF06B6D4);   // Cyan

  static const danger = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: ColorScheme.light(
        primary: AppColors.lightAccent,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
        secondary: AppColors.protein,
      ),
      cardTheme: CardTheme(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: ColorScheme.dark(
        primary: AppColors.darkAccent,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        secondary: AppColors.protein,
      ),
      cardTheme: CardTheme(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF2D3748), width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
