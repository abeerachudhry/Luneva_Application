import 'package:flutter/material.dart';

class AppTheme {
  // Primary purple used across the app (only purple & white)
  static const Color purple = Color(0xFF6A39FF); // professional purple

  static final ColorScheme _colorScheme = ColorScheme.fromSeed(
    seedColor: purple,
    brightness: Brightness.light,
    background: Colors.white,
    primary: purple,
    onPrimary: Colors.white,
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: _colorScheme,
    scaffoldBackgroundColor: Colors.white,
    primaryColor: purple,
    // Elevated button styling: consistent purple buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: purple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
        elevation: 4,
        shadowColor: purple.withOpacity(0.25),
      ),
    ),
    // Input decoration: rounded, subtle shadow via filled color and borderless
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      hintStyle: TextStyle(color: Colors.grey[600]),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: purple, width: 1.5),
      ),
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(fontSize: 14.0),
    ),
  );
}