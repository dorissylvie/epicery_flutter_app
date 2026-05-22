import 'package:flutter/material.dart';

class AppColors {
  // Base surfaces (beige + white)
  static const bg = Color(0xFFF5F0E6);
  static const surface = Color(0xFFFFFBF3);
  static const border = Color(0xFFE6DCCB);
  static const divider = Color(0xFFE0D5C3);

  // Mustard accent (dark)
  static const accent = Color.fromARGB(255, 206, 157, 11);
  static const accentSoft = Color(0xFFF2E2B0);
  static const onAccent = Color(0xFFFFF6E8);
  static const onAccentMuted = Color(0xB3FFF6E8);

  // Text colors
  static const textPrimary = Color(0xFF2B2415);
  static const textSecondary = Color(0xFF6B5B3E);

  // Aliases for legacy palettes
  static const ink = textPrimary;
  static const muted = textSecondary;

  // Status
  static const danger = Color(0xFFC44536);
  static const dangerSoft = Color(0xFFF2D9D4);
  static const success = Color(0xFF2D7A46);
  static const successSoft = Color(0xFFDCEFE2);
  static const warning = Color(0xFFB07100);
  static const warningSoft = Color(0xFFF2E3C8);

  // Tables
  static const tableHeader = Color(0xFFF0E5D1);
}
