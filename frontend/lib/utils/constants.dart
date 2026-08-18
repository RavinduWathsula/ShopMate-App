import 'package:flutter/material.dart';

class AppConstants {
  // Brand Colors
  static const Color backgroundColor = Color(0xFF13102D);
  static const Color cardColor = Color(0xFF221F41);
  static const Color primaryColor = Color(0xFFA644FF);
  static const Color secondaryColor = Color(0xFF22E5B1);
  static const Color accentColor = Color(0xFFFFB800);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0ACCA);
  
  // Dimensions
  static const double defaultPadding = 16.0;
  static const double paddingSmall = 8.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  static const double defaultRadius = 12.0;
  static const double cardRadius = 24.0;
  
  // Legacy aliases to prevent compile errors
  static const double padding = 16.0;
  static const double borderRadius = 12.0;

  static const String appName = 'ShopMate';
}
