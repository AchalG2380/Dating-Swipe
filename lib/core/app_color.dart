import 'package:flutter/material.dart';

/// Centralized color palette for the entire app.
/// Usage: AppColor.primary, AppColor.background, etc.
class AppColor {
  AppColor._(); // prevent instantiation

  // --- Brand Colors ---
  static const Color primary = Colors.pinkAccent;
  static const Color secondary = Colors.purpleAccent;

  // --- Background / Surface ---
  static const Color background = Color(0xFF0F0C20);
  static const Color surface = Color(0xFF1E1E2C);

  // --- Status Colors ---
  static const Color error = Colors.redAccent;
  static const Color success = Colors.greenAccent;
  static const Color info = Colors.blueAccent;

  // --- Text Colors ---
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color textHint = Colors.white54;
  static const Color textDisabled = Colors.white38;

  // --- Swipe Card Colors ---
  static const Color likeGreen = Colors.green;
  static const Color nopeRed = Colors.red;

  // --- Misc ---
  static const Color divider = Colors.white12;
  static const Color transparent = Colors.transparent;
}
