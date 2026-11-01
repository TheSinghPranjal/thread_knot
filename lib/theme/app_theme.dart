import 'package:flutter/material.dart';

class AppTheme {
  static const ink = Color(0xFF2A2140);
  static const navy = ink;
  static const coral = Color(0xFFE85D4C);
  static const sky = coral;
  static const skySoft = Color(0xFFFF8A76);
  static const teal = Color(0xFF2BB3A8);
  static const gold = Color(0xFFF4C45A);
  static const cream = Color(0xFFFFF6EE);
  static const peach = Color(0xFFFFE4D6);
  static const mist = Color(0xFFFFF1E8);
  static const heart = Color(0xFFFF5D73);
  static const heartEmpty = Color(0xFFE8D5CC);
  static const muted = Color(0xFF8A7A90);

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: coral,
        primary: coral,
        onPrimary: Colors.white,
        secondary: teal,
        surface: cream,
      ),
      scaffoldBackgroundColor: cream,
      canvasColor: cream,
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: ink,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: coral,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: coral,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 0,
        height: 72,
        indicatorColor: peach,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            fontSize: 12,
            color: selected ? coral : const Color(0xFF6E4E86),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? coral : const Color(0xFF6E4E86),
            size: 28,
          );
        }),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontWeight: FontWeight.w800,
          color: ink,
          letterSpacing: -0.8,
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.w800,
          color: ink,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: cream,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
