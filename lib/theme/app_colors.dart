import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1A73E8); // Trustworthy Blue
  static const Color primaryDark = Color(0xFF1557B0);
  static const Color accent = Color(0xFFFBBC04); // Yellow/Gold
  static const Color background = Color(0xFFF8F9FA); // Clean White/Grey
  static const Color surface = Colors.white;
  static const Color cardBg = Colors.white;
  static const Color border = Color(0xFFDADCE0);

  static const Color textPrimary = Color(0xFF202124);
  static const Color textSecondary = Color(0xFF5F6368);
  static const Color textMuted = Color(0xFF70757A);

  static const Color success = Color(0xFF1E8E3E);
  static const Color error = Color(0xFFD93025);
  static const Color warning = Color(0xFFF9AB00);
  static const Color info = Color(0xFF1A73E8);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
