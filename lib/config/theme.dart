import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ZussGoTheme {
  // ── Primary Colors (V2 Warm Sunset) ──
  static const Color amber = Color(0xFFF59E0B);
  static const Color rose = Color(0xFFF43F5E);
  static const Color mint = Color(0xFF00F5D4);       // accent from V1
  static const Color sky = Color(0xFF38BDF8);
  static const Color sage = Color(0xFF22C55E);
  static const Color lavender = Color(0xFFA78BFA);

  // Kept for backward compat in widgets that reference these
  static const Color coral = amber;
  static const Color violet = rose;
  static const Color orange = Color(0xFFFF8E53);
  static const Color violetSoft = lavender;

  // ── Backgrounds ──
  static const Color bgPrimary = Color(0xFF0C0A09);
  static const Color bgSecondary = Color(0xFF1C1917);
  static const Color bgCard = Color(0x08FFFFFF);
  static const Color bgInput = Color(0x0FFFFFFF);

  // ── Text ──
  static const Color textPrimary = Color(0xFFFAFAF9);
  static const Color textSecondary = Color(0x99FAFAF9);
  static const Color textMuted = Color(0x59FAFAF9);
  static const Color textSubtle = Color(0x40FAFAF9);

  // ── Borders ──
  static const Color borderDefault = Color(0x0FFFFFFF);
  static const Color borderHover = Color(0x33F59E0B);

  // ── Gradients ──
  static const LinearGradient gradientPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [amber, rose],
  );

  static const LinearGradient gradientHero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [amber, rose, lavender],
  );

  static const LinearGradient gradientMintViolet = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [mint, lavender],
  );

  static const LinearGradient gradientOcean = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [sky, sage],
  );

  static const LinearGradient gradientWarm = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [amber, rose],
  );

  // ── Text Styles (Playfair Display + Outfit) ──
  static TextStyle get displayLarge => GoogleFonts.playfairDisplay(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: textPrimary,
    letterSpacing: -1,
  );

  static TextStyle get displayMedium => GoogleFonts.playfairDisplay(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle get displaySmall => GoogleFonts.playfairDisplay(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: textPrimary,
  );

  static TextStyle get bodyLarge => GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.7,
  );

  static TextStyle get bodyMedium => GoogleFonts.outfit(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );

  static TextStyle get bodySmall => GoogleFonts.outfit(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textMuted,
  );

  static TextStyle get labelBold => GoogleFonts.outfit(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: textPrimary,
  );

  static TextStyle get buttonText => GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: 0.3,
  );

  static TextStyle get tagline => GoogleFonts.outfit(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textSubtle,
    letterSpacing: 4,
  );

  // ── Theme Data ──
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgPrimary,
    colorScheme: const ColorScheme.dark(
      primary: amber,
      secondary: rose,
      surface: bgCard,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimary,
    ),
    textTheme: TextTheme(
      displayLarge: displayLarge,
      displayMedium: displayMedium,
      displaySmall: displaySmall,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: labelBold,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: bgSecondary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: borderDefault),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: borderDefault),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: amber.withValues(alpha: 0.5), width: 2),
      ),
      hintStyle: GoogleFonts.outfit(color: textMuted, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: displaySmall,
    ),
  );

  // ── Decorations ──
  static BoxDecoration get glassCard => BoxDecoration(
    color: bgCard,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: borderDefault),
  );

  static BoxDecoration get glassCardHighlight => BoxDecoration(
    color: const Color(0x12FFFFFF),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: borderHover),
  );

  static BoxDecoration get pillBadge => BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    color: bgCard,
    border: Border.all(color: borderDefault),
  );
}
