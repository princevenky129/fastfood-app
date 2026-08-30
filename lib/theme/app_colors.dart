import 'package:flutter/material.dart';

/// Zomato/Swiggy-inspired rich color palette.
class AppColors {
  AppColors._();

  // Brand Gradients & Primary
  static const brandRed = Color(0xFFE23744);      // Zomato red
  static const brandRedLight = Color(0xFFFF5252); // Vivid coral red
  static const brandOrange = Color(0xFFFC8019);   // Swiggy orange
  static const brandOrangeLight = Color(0xFFFF9E43);

  // Backgrounds & Surfaces (Warm Food App Theme)
  static const background = Color(0xFFFFF8F5);     // Soft warm cream-peach background
  static const surface = Color(0xFFFFFFFF);        // Card background
  static const surfaceWarm = Color(0xFFFFF0EB);    // Light orange tint container
  static const surfaceElevated = Color(0xFFFFE8E0); // Slightly darker warm container
  static const divider = Color(0xFFFFE0D6);        // Warm soft divider border

  // Text Colors
  static const textPrimary = Color(0xFF1C1E26);   // Rich dark charcoal
  static const textSecondary = Color(0xFF5E6272); // Charcoal grey
  static const textFaint = Color(0xFF9EA3B2);     // Soft text/muted

  // Status System Colors
  static const pending = Color(0xFFFF9800);       // Warm Amber
  static const pendingBg = Color(0xFFFFF3E0);     // Soft Amber Tint
  static const paid = Color(0xFF2E7D32);          // Fresh Emerald Green
  static const paidBg = Color(0xFFE8F5E9);        // Soft Green Tint
  static const cash = Color(0xFF1976D2);          // Steel Blue
  static const cashBg = Color(0xFFE3F2FD);        // Soft Blue Tint
  static const danger = Color(0xFFD32F2F);        // Deep Red
  static const dangerBg = Color(0xFFFFEBEE);      // Soft Red Tint

  static const brandAccent = brandOrange;
}
