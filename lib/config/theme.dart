import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

@immutable
class ZussGoColors extends ThemeExtension<ZussGoColors> {
  final Color bg;
  final Color surface;
  final Color card;
  final Color card2;
  final Color cardWarm;
  final Color primary;
  final Color primarySoft;
  final Color primaryMid;
  final Color gold;
  final Color goldSoft;
  final Color goldMid;
  final Color sage;
  final Color sageSoft;
  final Color sageMid;
  final Color lavender;
  final Color lavenderSoft;
  final Color lavenderMid;
  final Color rose;
  final Color roseSoft;
  final Color text;
  final Color textSecondary;
  final Color muted;
  final Color border;
  final Color borderWarm;

  // Legacy aliases
  Color get bgPrimary => bg;
  Color get bgSecondary => surface;
  Color get bgCard => card;
  Color get bgMuted => card2;
  Color get textPrimary => text;
  Color get textMuted => muted;
  Color get green => primary;
  Color get greenDark => primary;
  Color get greenLight => primarySoft;
  Color get amber => gold;
  Color get sky => lavender;
  Color get mint => sage;

  const ZussGoColors({
    required this.bg, required this.surface, required this.card, required this.card2, required this.cardWarm,
    required this.primary, required this.primarySoft, required this.primaryMid,
    required this.gold, required this.goldSoft, required this.goldMid,
    required this.sage, required this.sageSoft, required this.sageMid,
    required this.lavender, required this.lavenderSoft, required this.lavenderMid,
    required this.rose, required this.roseSoft,
    required this.text, required this.textSecondary, required this.muted,
    required this.border, required this.borderWarm,
  });

  @override
  ZussGoColors copyWith({
    Color? bg, Color? surface, Color? card, Color? card2, Color? cardWarm,
    Color? primary, Color? primarySoft, Color? primaryMid,
    Color? gold, Color? goldSoft, Color? goldMid,
    Color? sage, Color? sageSoft, Color? sageMid,
    Color? lavender, Color? lavenderSoft, Color? lavenderMid,
    Color? rose, Color? roseSoft,
    Color? text, Color? textSecondary, Color? muted,
    Color? border, Color? borderWarm,
  }) {
    return ZussGoColors(
      bg: bg ?? this.bg, surface: surface ?? this.surface, card: card ?? this.card,
      card2: card2 ?? this.card2, cardWarm: cardWarm ?? this.cardWarm,
      primary: primary ?? this.primary, primarySoft: primarySoft ?? this.primarySoft, primaryMid: primaryMid ?? this.primaryMid,
      gold: gold ?? this.gold, goldSoft: goldSoft ?? this.goldSoft, goldMid: goldMid ?? this.goldMid,
      sage: sage ?? this.sage, sageSoft: sageSoft ?? this.sageSoft, sageMid: sageMid ?? this.sageMid,
      lavender: lavender ?? this.lavender, lavenderSoft: lavenderSoft ?? this.lavenderSoft, lavenderMid: lavenderMid ?? this.lavenderMid,
      rose: rose ?? this.rose, roseSoft: roseSoft ?? this.roseSoft,
      text: text ?? this.text, textSecondary: textSecondary ?? this.textSecondary, muted: muted ?? this.muted,
      border: border ?? this.border, borderWarm: borderWarm ?? this.borderWarm,
    );
  }

  @override
  ZussGoColors lerp(ThemeExtension<ZussGoColors>? other, double t) {
    if (other is! ZussGoColors) return this;
    return ZussGoColors(
      bg: Color.lerp(bg, other.bg, t)!, surface: Color.lerp(surface, other.surface, t)!,
      card: Color.lerp(card, other.card, t)!, card2: Color.lerp(card2, other.card2, t)!,
      cardWarm: Color.lerp(cardWarm, other.cardWarm, t)!,
      primary: Color.lerp(primary, other.primary, t)!, primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      primaryMid: Color.lerp(primaryMid, other.primaryMid, t)!,
      gold: Color.lerp(gold, other.gold, t)!, goldSoft: Color.lerp(goldSoft, other.goldSoft, t)!,
      goldMid: Color.lerp(goldMid, other.goldMid, t)!,
      sage: Color.lerp(sage, other.sage, t)!, sageSoft: Color.lerp(sageSoft, other.sageSoft, t)!,
      sageMid: Color.lerp(sageMid, other.sageMid, t)!,
      lavender: Color.lerp(lavender, other.lavender, t)!, lavenderSoft: Color.lerp(lavenderSoft, other.lavenderSoft, t)!,
      lavenderMid: Color.lerp(lavenderMid, other.lavenderMid, t)!,
      rose: Color.lerp(rose, other.rose, t)!, roseSoft: Color.lerp(roseSoft, other.roseSoft, t)!,
      text: Color.lerp(text, other.text, t)!, textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      border: Color.lerp(border, other.border, t)!, borderWarm: Color.lerp(borderWarm, other.borderWarm, t)!,
    );
  }

  static const ZussGoColors dark = ZussGoColors(
    bg: Color(0xFF0D0B0E), surface: Color(0xFF14121A), card: Color(0xFF1C1924),
    card2: Color(0xFF231F2E), cardWarm: Color(0xFF1E1A16),
    primary: Color(0xFFFF6B4A), primarySoft: Color(0x20FF6B4A), primaryMid: Color(0x40FF6B4A),
    gold: Color(0xFFFFBD3D), goldSoft: Color(0x18FFBD3D), goldMid: Color(0x35FFBD3D),
    sage: Color(0xFF4ECBA0), sageSoft: Color(0x184ECBA0), sageMid: Color(0x354ECBA0),
    lavender: Color(0xFFA78BFA), lavenderSoft: Color(0x18A78BFA), lavenderMid: Color(0x35A78BFA),
    rose: Color(0xFFFF6B8A), roseSoft: Color(0x18FF6B8A),
    text: Color(0xFFF5F0EB), textSecondary: Color(0xFFB8AFA6), muted: Color(0xFF7D7573),
    border: Color(0xFF2A2530), borderWarm: Color(0xFF332D28),
  );

  static const ZussGoColors light = dark;
}

class ZussGoTheme {
  static const Color primary = Color(0xFFFF6B4A);
  static const Color gold = Color(0xFFFFBD3D);
  static const Color sage = Color(0xFF4ECBA0);
  static const Color lavender = Color(0xFFA78BFA);
  static const Color rose = Color(0xFFFF6B8A);

  // Legacy aliases
  static const Color green = Color(0xFFFF6B4A);
  static const Color greenDark = Color(0xFFFF6B4A);
  static const Color greenLight = Color(0x20FF6B4A);
  static const Color amber = Color(0xFFFFBD3D);
  static const Color sky = Color(0xFFA78BFA);
  static const Color mint = Color(0xFF4ECBA0);

  static const Color bgPrimary = Color(0xFF0D0B0E);
  static const Color bgSecondary = Color(0xFF14121A);
  static const Color bgMuted = Color(0xFF231F2E);
  static const Color borderDefault = Color(0xFF2A2530);
  static const Color textPrimary = Color(0xFFF5F0EB);
  static const Color textSecondary = Color(0xFFB8AFA6);
  static const Color textMuted = Color(0xFF7D7573);

  static const LinearGradient gradientPrimary = LinearGradient(
    colors: [Color(0xFFFF6B4A), Color(0xFFFF8A65)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );

  static const LinearGradient gradientWarm = LinearGradient(
    colors: [Color(0xFFFFBD3D), Color(0xFFFF6B4A)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );

  static const LinearGradient gradientHero = LinearGradient(
    colors: [Color(0xFF2A1810), Color(0xFF1E1420), Color(0xFF1A1628)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );

  static ZussGoColors colors(BuildContext context) => Theme.of(context).extension<ZussGoColors>()!;
  static ZussGoColors of(BuildContext context) => colors(context);

  static Color scaffoldBg(BuildContext context) => colors(context).bg;
  static Color cardBg(BuildContext context) => colors(context).card;
  static Color mutedBg(BuildContext context) => colors(context).card2;
  static Color border(BuildContext context) => colors(context).border;
  static Color primaryText(BuildContext context) => colors(context).text;
  static Color secondaryText(BuildContext context) => colors(context).textSecondary;
  static Color mutedText(BuildContext context) => colors(context).muted;
  static Color dividerColor(BuildContext context) => colors(context).border;

  static TextStyle get displayLarge => GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w800, color: textPrimary, height: 1.15, letterSpacing: -1.5);
  static TextStyle get displayMedium => GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: textPrimary, height: 1.2, letterSpacing: -1);
  static TextStyle get displaySmall => GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary, height: 1.3);
  static TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w400, color: textSecondary, height: 1.5);
  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w400, color: textSecondary, height: 1.5);
  static TextStyle get bodySmall => GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w400, color: textMuted, height: 1.4);
  static TextStyle get labelBold => GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary, height: 1.3);

  static TextTheme _buildTextTheme(ZussGoColors c) {
    return TextTheme(
      displayLarge: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w800, color: c.text, height: 1.15, letterSpacing: -1.5),
      displayMedium: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: c.text, height: 1.2, letterSpacing: -1),
      displaySmall: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: c.text, height: 1.3),
      headlineMedium: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: c.text, height: 1.25),
      bodyLarge: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w400, color: c.textSecondary, height: 1.5),
      bodyMedium: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w400, color: c.textSecondary, height: 1.5),
      bodySmall: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w400, color: c.muted, height: 1.4),
      labelLarge: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: c.text, height: 1.3),
      labelSmall: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: c.primary, letterSpacing: 1),
    );
  }

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: ZussGoColors.dark.bg,
    fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
    extensions: const <ThemeExtension<dynamic>>[ZussGoColors.dark],
    textTheme: _buildTextTheme(ZussGoColors.dark),
    colorScheme: ColorScheme.dark(
      primary: ZussGoColors.dark.primary, secondary: ZussGoColors.dark.gold,
      surface: ZussGoColors.dark.surface, error: ZussGoColors.dark.rose,
    ),
    appBarTheme: AppBarTheme(backgroundColor: ZussGoColors.dark.bg, elevation: 0, iconTheme: IconThemeData(color: ZussGoColors.dark.text)),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: ZussGoColors.dark.card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: ZussGoColors.dark.border, width: 1)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: ZussGoColors.dark.border, width: 1)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: ZussGoColors.dark.primary.withValues(alpha: 0.5), width: 1.5)),
      hintStyle: GoogleFonts.plusJakartaSans(color: ZussGoColors.dark.muted, fontSize: 14),
    ),
    dividerColor: ZussGoColors.dark.border,
    cardColor: ZussGoColors.dark.card,
  );

  static ThemeData get lightTheme => darkTheme;

  // ── CARD DECORATIONS ──────────────────────────────────────────────────────

  /// Default card — border, no shadow
  static BoxDecoration cardDecoration(BuildContext context) {
    final c = colors(context);
    return BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: c.border, width: 1));
  }

  static BoxDecoration glassCardDecoration(BuildContext context) {
    final c = colors(context);
    return BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: c.border, width: 1));
  }

  /// Hero gradient — for featured/highlighted content
  static BoxDecoration heroCardDecoration(BuildContext context) {
    final c = colors(context);
    return BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: gradientHero,
      border: Border.all(color: c.borderWarm, width: 1),
    );
  }

  /// Warm elevated — for companion requests, important actions
  static BoxDecoration warmCardDecoration(BuildContext context) {
    final c = colors(context);
    return BoxDecoration(
      color: c.cardWarm,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: c.borderWarm, width: 1),
      boxShadow: [BoxShadow(color: c.primary.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, 8))],
    );
  }

  /// Floating — shadow-elevated, no border (traveler cards, about sections)
  static BoxDecoration floatingCardDecoration(BuildContext context) {
    final c = colors(context);
    return BoxDecoration(
      color: c.card,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8)),
        BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 4, offset: const Offset(0, 2)),
      ],
    );
  }

  /// Accent-bordered — subtle color tint (companion rows, trust cards)
  static BoxDecoration accentCardDecoration(BuildContext context, Color accent) {
    final c = colors(context);
    return BoxDecoration(
      color: c.card,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: accent.withValues(alpha: 0.25), width: 1),
      boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 4))],
    );
  }

  /// Frosted — translucent with shadow (overlapping stats row)
  static BoxDecoration frostedCardDecoration(BuildContext context) {
    final c = colors(context);
    return BoxDecoration(
      color: c.card.withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: c.border.withValues(alpha: 0.5), width: 1),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 16, offset: const Offset(0, 6))],
    );
  }

  // ── INPUT DECORATIONS ─────────────────────────────────────────────────────

  static InputDecoration inputDecoration({String? hint, Widget? prefix, Widget? suffix}) {
    return InputDecoration(
      hintText: hint, hintStyle: GoogleFonts.plusJakartaSans(color: textMuted, fontSize: 14),
      prefixIcon: prefix, suffixIcon: suffix, filled: true, fillColor: const Color(0xFF1C1924),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF2A2530), width: 1)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF2A2530), width: 1)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: primary.withValues(alpha: 0.5), width: 1.5)),
    );
  }

  static InputDecoration inputDecorationOf(BuildContext context, {String? hint, Widget? prefix, Widget? suffix}) {
    final c = colors(context);
    return InputDecoration(
      hintText: hint, hintStyle: GoogleFonts.plusJakartaSans(color: c.muted, fontSize: 14),
      prefixIcon: prefix, suffixIcon: suffix, filled: true, fillColor: c.card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: c.border, width: 1)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: c.border, width: 1)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: c.primary.withValues(alpha: 0.5), width: 1.5)),
    );
  }

  static ThemeData get themeData => darkTheme;
}

extension ZussTextStyleExt on TextStyle {
  TextStyle adaptive(BuildContext context) {
    final c = ZussGoTheme.colors(context);
    if (color == ZussGoTheme.textPrimary) return copyWith(color: c.text);
    if (color == ZussGoTheme.textSecondary) return copyWith(color: c.textSecondary);
    if (color == ZussGoTheme.textMuted) return copyWith(color: c.muted);
    return this;
  }
}

extension ThemeExt on BuildContext {
  ZussGoColors get colors => Theme.of(this).extension<ZussGoColors>()!;
  TextTheme get textTheme => Theme.of(this).textTheme;
}