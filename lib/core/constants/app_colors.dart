import 'package:flutter/material.dart';

class AppColors {
  // Brand Primary: Vibrant Swap Emerald Green (Renewal, Value Exchange)
  static const Color primary = Color(0xFF00A86B);
  static const Color primaryDark = Color(0xFF007A4D);
  static const Color primaryLight = Color(0xFFE6F7F0);

  // Brand Secondary: Electric Royal Indigo (Trust, Technology, Intelligence)
  static const Color secondary = Color(0xFF4F46E5);
  static const Color secondaryDark = Color(0xFF3730A3);
  static const Color secondaryLight = Color(0xFFEEF2FF);

  // Accent: Warm Amber Gold (High Match Deals, Highlights, Star Ratings)
  static const Color accent = Color(0xFFF59E0B);
  static const Color accentLight = Color(0xFFFEF3C7);

  // Success, Warning, Error
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Neutrals (Dark & Light)
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color card = Colors.white;
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);

  // Dark Theme Palette
  static const Color darkBackground = Color(0xFF0B0F19);
  static const Color darkSurface = Color(0xFF131B2E);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0xFF334155);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00A86B), Color(0xFF00875A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient brandHeroGradient = LinearGradient(
    colors: [Color(0xFF00A86B), Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient matchBadgeGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
