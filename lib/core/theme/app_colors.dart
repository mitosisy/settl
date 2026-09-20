import 'dart:ui';

class AppColors {
  AppColors._();

  // Primary Brand Accent
  static const Color brandBlack = Color(0xFF000000);
  static const Color brandWhite = Color(0xFFFFFFFF);

  // Light Theme Colors
  static const Color lightBgDeep = Color(0xFFE2E9E6); // Soft greenish-grey from reference
  static const Color lightBgCard = Color(0xFFF9FAFB);
  static const Color lightBgElevated = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF111827); // Very dark green-grey
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightTextMuted = Color(0xFF9CA3AF);
  
  // Dark Theme Colors
  static const Color darkBgDeep = Color(0xFF080B14);
  static const Color darkBgCard = Color(0xFF111827);
  static const Color darkBgElevated = Color(0xFF1C2535);
  static const Color darkTextPrimary = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkTextMuted = Color(0xFF4B5563);

  // Status
  static const Color greenSuccess = Color(0xFF10B981);
  static const Color amberWarning = Color(0xFFF59E0B);
  static const Color redError = Color(0xFFEF4444);
}
