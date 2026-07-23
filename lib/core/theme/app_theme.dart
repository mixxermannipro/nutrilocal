import 'package:flutter/material.dart';

class AppColors {
  // Vibrant Apple Palette
  static const fudPink = Color(0xFFFF375F);
  static const emeraldGreen = Color(0xFF2FA36B);
  static const darkEmerald = Color(0xFF1E3A2D);

  // Light Mode Glass Colors
  static const lightBackground = Color(0xFFF4F6F9);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceGlass = Color(0xE6FFFFFF);
  static const lightTextPrimary = Color(0xFF0F172A);
  static const lightTextSecondary = Color(0xFF64748B);
  static const lightAccent = Color(0xFF2FA36B);
  static const lightAccentSoft = Color(0xFFE8F5E9);

  // Dark Mode Glass Colors
  static const darkBackground = Color(0xFF0B0D12);
  static const darkSurface = Color(0xFF161A23);
  static const darkSurfaceGlass = Color(0xCC161A23);
  static const darkTextPrimary = Color(0xFFF8FAFC);
  static const darkTextSecondary = Color(0xFF94A3B8);
  static const darkAccent = Color(0xFF4CC38A);
  static const darkAccentSoft = Color(0xFF1A3326);

  // Nutrient Colors
  static const protein = Color(0xFF3B82F6); // Apple Blue
  static const carbs = Color(0xFFF59E0B);   // Amber Gold
  static const fat = Color(0xFF8B5CF6);     // Purple
  static const fiber = Color(0xFF10B981);   // Mint Green
  static const sugar = Color(0xFFEC4899);   // Rose Pink
  static const water = Color(0xFF06B6D4);   // Cyan Water

  static const danger = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);

  // Apple Gradient Presets
  static const LinearGradient calorieRingGradient = LinearGradient(
    colors: [Color(0xFFFF375F), Color(0xFF4CC38A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassHeaderGradient = LinearGradient(
    colors: [Color(0x1F4CC38A), Color(0x053B82F6)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.lightAccent,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
        secondary: AppColors.protein,
      ),
      cardTheme: CardTheme(
        color: AppColors.lightSurface,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.04),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.black.withOpacity(0.05), width: 1),
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
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkAccent,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        secondary: AppColors.protein,
      ),
      cardTheme: CardTheme(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
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
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}
