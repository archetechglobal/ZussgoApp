import 'package:flutter/material.dart';

class ZussGoTheme {
  // ─── BACKGROUNDS ───
  static const Color bgPrimary = Color(0xFFFAFAF8);
  static const Color bgSecondary = Color(0xFFFFFFFF);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color bgMuted = Color(0xFFF3F4F1);

  // ─── GREENS ───
  static const Color green = Color(0xFF2D9F6F);
  static const Color greenDark = Color(0xFF1B7A5A);
  static const Color greenLight = Color(0xFFE6F5EE);

  // ─── ACCENTS ───
  static const Color amber = Color(0xFFE8A849);
  static const Color rose = Color(0xFFE85D75);
  static const Color sky = Color(0xFF4AADE8);
  static const Color lavender = Color(0xFF8B7EC8);
  static const Color mint = Color(0xFF2ECDA7);
  static const Color sage = Color(0xFF7CB69A);

  // ─── TEXT ───
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  // ─── BORDERS ───
  static const Color borderDefault = Color(0xFFE8E8E4);
  static const Color divider = Color(0xFFF0F0EC);

  // ─── GRADIENTS ───
  static const LinearGradient gradientPrimary = LinearGradient(
    colors: [Color(0xFF2D9F6F), Color(0xFF1B7A5A)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );

  static const LinearGradient gradientWarm = LinearGradient(
    colors: [Color(0xFFE8A849), Color(0xFFE85D75)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );

  // ─── TYPOGRAPHY ───
  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'Playfair Display', fontSize: 32, fontWeight: FontWeight.w700,
    color: textPrimary, height: 1.15,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: 'Playfair Display', fontSize: 24, fontWeight: FontWeight.w700,
    color: textPrimary, height: 1.2,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: 'Playfair Display', fontSize: 18, fontWeight: FontWeight.w600,
    color: textPrimary, height: 1.3,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.w400,
    color: textSecondary, height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Outfit', fontSize: 14, fontWeight: FontWeight.w400,
    color: textSecondary, height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Outfit', fontSize: 12, fontWeight: FontWeight.w400,
    color: textMuted, height: 1.4,
  );

  static const TextStyle labelBold = TextStyle(
    fontFamily: 'Outfit', fontSize: 14, fontWeight: FontWeight.w600,
    color: textPrimary, height: 1.3,
  );

  // ─── CARD DECORATIONS ───
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: bgSecondary,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4))],
  );

  static BoxDecoration get glassCard => BoxDecoration(
    color: bgSecondary,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 2))],
  );

  // ─── INPUT ───
  static InputDecoration inputDecoration({String? hint, Widget? prefix, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: bodyMedium.copyWith(color: textMuted),
      prefixIcon: prefix,
      suffixIcon: suffix,
      filled: true,
      fillColor: bgMuted,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: green.withValues(alpha: 0.4), width: 1.5)),
    );
  }

  // ─── THEME DATA ───
  static ThemeData get themeData => ThemeData(
    scaffoldBackgroundColor: bgPrimary,
    fontFamily: 'Outfit',
    colorScheme: const ColorScheme.light(primary: green, secondary: amber, surface: bgSecondary, error: rose),
    appBarTheme: const AppBarTheme(backgroundColor: bgPrimary, elevation: 0, iconTheme: IconThemeData(color: textPrimary)),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: bgMuted,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: green.withValues(alpha: 0.4), width: 1.5)),
      hintStyle: bodyMedium.copyWith(color: textMuted),
    ),
  );
}