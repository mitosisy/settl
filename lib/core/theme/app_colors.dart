import 'dart:ui';

/// Design tokens for ChainPay's dark-mode fintech aesthetic.
///
/// Premium dark-mode fintech for Bharat — Zerodha Kite's clarity
/// meets cyber-saffron energy. Not Western crypto-bro. Not bland banking.
class AppColors {
  AppColors._();

  // ─── Backgrounds ───────────────────────────────────────────────
  /// Near-black blue — primary app background
  static const Color bgDeep = Color(0xFF080B14);

  /// Card surfaces
  static const Color bgCard = Color(0xFF111827);

  /// Modals, bottom sheets, elevated surfaces
  static const Color bgElevated = Color(0xFF1C2535);

  // ─── Brand ─────────────────────────────────────────────────────
  /// Primary CTA, action buttons
  static const Color brandSaffron = Color(0xFFFF6B1A);

  /// Glow/accent effects
  static const Color brandGlow = Color(0xFFFF9A4D);

  /// Success states, trusted score ≥70
  static const Color brandGreen = Color(0xFF10B981);

  /// Warning states, neutral score 40–69
  static const Color brandAmber = Color(0xFFF59E0B);

  /// Danger states, untrusted score <40
  static const Color brandRed = Color(0xFFEF4444);

  // ─── Text ──────────────────────────────────────────────────────
  /// Headings, primary content
  static const Color textPrimary = Color(0xFFF9FAFB);

  /// Subtitles, labels
  static const Color textSecondary = Color(0xFF9CA3AF);

  /// Disabled text, hints
  static const Color textMuted = Color(0xFF4B5563);

  // ─── Solana Accent ─────────────────────────────────────────────
  /// Network badge, subtle accent
  static const Color solanaPurple = Color(0xFF9945FF);

  /// Solana brand accent
  static const Color solanaGreen = Color(0xFF14F195);
}
