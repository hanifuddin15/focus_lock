import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Backgrounds
  static const Color background = Color(0xFF0A0E21);
  static const Color backgroundLight = Color(0xFF0F1429);
  static const Color surface = Color(0xFF1A1F36);
  static const Color surfaceLight = Color(0xFF242942);
  static const Color cardBackground = Color(0xFF1E2340);

  // Neon Accents
  static const Color neonCyan = Color(0xFF00F5FF);
  static const Color neonPurple = Color(0xFF8B5CF6);
  static const Color neonPink = Color(0xFFFF006E);
  static const Color neonBlue = Color(0xFF3B82F6);
  static const Color neonGreen = Color(0xFF10B981);
  static const Color neonOrange = Color(0xFFFF8C00);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [neonCyan, neonPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lockGradient = LinearGradient(
    colors: [Color(0xFF0A0E21), Color(0xFF1A0A2E), Color(0xFF0A0E21)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [neonPink, Color(0xFFFF4444)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [neonGreen, neonCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B8D1);
  static const Color textMuted = Color(0xFF6B7394);

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = neonCyan;

  // Glass
  static const Color glassWhite = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassHighlight = Color(0x0DFFFFFF);

  // Shadows
  static const Color neonCyanGlow = Color(0x4D00F5FF);
  static const Color neonPurpleGlow = Color(0x4D8B5CF6);
  static const Color neonPinkGlow = Color(0x4DFF006E);
}
