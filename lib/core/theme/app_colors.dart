import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Main brand colors used across buttons, highlights, and active states.
  static const Color primary = Color(0xFF0B6B43);
  static const Color primaryLight = Color(0xFFEAF7F0);

  // Core neutrals for text, borders, and page backgrounds.
  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);

  // Useful state colors we’ll reuse later in badges and alerts.
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFDC2626);

  // Bottom nav inactive/icon helper color.
  static const Color muted = Color(0xFF9CA3AF);
}