import 'package:flutter/material.dart';

// Smart Home color palette
class SmartHomeColors {
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color secondaryBlue = Color(0xFF64B5F6);
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
}

final ThemeData appTheme = ThemeData(
  primarySwatch: Colors.blue,
  primaryColor: SmartHomeColors.primaryBlue,
  colorScheme: ColorScheme.fromSeed(
    seedColor: SmartHomeColors.primaryBlue,
    brightness: Brightness.light,
    surface: SmartHomeColors.backgroundLight,
  ),
  scaffoldBackgroundColor: SmartHomeColors.backgroundLight,
  appBarTheme: const AppBarTheme(
    backgroundColor: SmartHomeColors.backgroundWhite,
    foregroundColor: SmartHomeColors.textPrimary,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: SmartHomeColors.textPrimary,
    ),
  ),
  cardTheme: CardThemeData(
    color: SmartHomeColors.cardBackground,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    shadowColor: Colors.black.withValues(alpha: 0.1),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: SmartHomeColors.primaryBlue,
    foregroundColor: Colors.white,
    elevation: 4,
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: SmartHomeColors.textPrimary,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: SmartHomeColors.textPrimary,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: SmartHomeColors.textPrimary,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: SmartHomeColors.textPrimary,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: SmartHomeColors.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: SmartHomeColors.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: SmartHomeColors.textSecondary,
    ),
  ),
  visualDensity: VisualDensity.adaptivePlatformDensity,
);
