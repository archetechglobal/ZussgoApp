import 'package:flutter/material.dart';

@immutable
class ZussGoColors extends ThemeExtension<ZussGoColors> {
  final Color bgPrimary;
  final Color bgSecondary;
  final Color bgCard;
  final Color bgMuted;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  
  // Greens
  final Color green;
  final Color greenDark;
  final Color greenLight;

  // Accents
  final Color amber;
  final Color rose;
  final Color sky;
  final Color lavender;
  final Color mint;
  final Color sage;

  const ZussGoColors({
    required this.bgPrimary,
    required this.bgSecondary,
    required this.bgCard,
    required this.bgMuted,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.green,
    required this.greenDark,
    required this.greenLight,
    required this.amber,
    required this.rose,
    required this.sky,
    required this.lavender,
    required this.mint,
    required this.sage,
  });

  @override
  ZussGoColors copyWith({
    Color? bgPrimary, Color? bgSecondary, Color? bgCard, Color? bgMuted,
    Color? border, Color? textPrimary, Color? textSecondary, Color? textMuted,
    Color? green, Color? greenDark, Color? greenLight,
    Color? amber, Color? rose, Color? sky, Color? lavender, Color? mint, Color? sage,
  }) {
    return ZussGoColors(
      bgPrimary: bgPrimary ?? this.bgPrimary,
      bgSecondary: bgSecondary ?? this.bgSecondary,
      bgCard: bgCard ?? this.bgCard,
      bgMuted: bgMuted ?? this.bgMuted,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      green: green ?? this.green,
      greenDark: greenDark ?? this.greenDark,
      greenLight: greenLight ?? this.greenLight,
      amber: amber ?? this.amber,
      rose: rose ?? this.rose,
      sky: sky ?? this.sky,
      lavender: lavender ?? this.lavender,
      mint: mint ?? this.mint,
      sage: sage ?? this.sage,
    );
  }

  @override
  ZussGoColors lerp(ThemeExtension<ZussGoColors>? other, double t) {
    if (other is! ZussGoColors) return this;
    return ZussGoColors(
      bgPrimary: Color.lerp(bgPrimary, other.bgPrimary, t)!,
      bgSecondary: Color.lerp(bgSecondary, other.bgSecondary, t)!,
      bgCard: Color.lerp(bgCard, other.bgCard, t)!,
      bgMuted: Color.lerp(bgMuted, other.bgMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      green: Color.lerp(green, other.green, t)!,
      greenDark: Color.lerp(greenDark, other.greenDark, t)!,
      greenLight: Color.lerp(greenLight, other.greenLight, t)!,
      amber: Color.lerp(amber, other.amber, t)!,
      rose: Color.lerp(rose, other.rose, t)!,
      sky: Color.lerp(sky, other.sky, t)!,
      lavender: Color.lerp(lavender, other.lavender, t)!,
      mint: Color.lerp(mint, other.mint, t)!,
      sage: Color.lerp(sage, other.sage, t)!,
    );
  }

  static const ZussGoColors light = ZussGoColors(
    bgPrimary: Color(0xFFFAFAF8),
    bgSecondary: Color(0xFFFFFFFF),
    bgCard: Color(0xFFFFFFFF),
    bgMuted: Color(0xFFF3F4F1),
    border: Color(0xFFE8E8E4),
    textPrimary: Color(0xFF1A1A1A),
    textSecondary: Color(0xFF6B7280),
    textMuted: Color(0xFF9CA3AF),
    green: Color(0xFF2D9F6F),
    greenDark: Color(0xFF1B7A5A),
    greenLight: Color(0xFFE6F5EE),
    amber: Color(0xFFE8A849),
    rose: Color(0xFFE85D75),
    sky: Color(0xFF4AADE8),
    lavender: Color(0xFF8B7EC8),
    mint: Color(0xFF2ECDA7),
    sage: Color(0xFF7CB69A),
  );

  static const ZussGoColors dark = ZussGoColors(
    bgPrimary: Color(0xFF111111),
    bgSecondary: Color(0xFF1E1E1E),
    bgCard: Color(0xFF1E1E1E),
    bgMuted: Color(0xFF2C2C2E),
    border: Color(0xFF333333),
    textPrimary: Color(0xFFF2F2F2),
    textSecondary: Color(0xFFBBBBBB),
    textMuted: Color(0xFF8A8A8A),
    green: Color(0xFF2D9F6F),
    greenDark: Color(0xFF1B7A5A),
    greenLight: Color(0xFF183B2E), // Adjusted for dark mode background contrasts
    amber: Color(0xFFE8A849),
    rose: Color(0xFFE85D75),
    sky: Color(0xFF4AADE8),
    lavender: Color(0xFF8B7EC8),
    mint: Color(0xFF2ECDA7),
    sage: Color(0xFF7CB69A),
  );
}

class ZussGoTheme {
  // ─── STATIC GRADIENTS ───
  static const LinearGradient gradientPrimary = LinearGradient(
    colors: [Color(0xFF2D9F6F), Color(0xFF1B7A5A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientWarm = LinearGradient(
    colors: [Color(0xFFE8A849), Color(0xFFE85D75)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── CONSTS FOR BACKWARD COMPATIBILITY ───
  static const Color green = Color(0xFF2D9F6F);
  static const Color greenDark = Color(0xFF1B7A5A);
  static const Color greenLight = Color(0xFFE6F5EE);
  static const Color amber = Color(0xFFE8A849);
  static const Color rose = Color(0xFFE85D75);
  static const Color sky = Color(0xFF4AADE8);
  static const Color lavender = Color(0xFF8B7EC8);
  static const Color mint = Color(0xFF2ECDA7);
  static const Color sage = Color(0xFF7CB69A);

  static const Color bgPrimary = Color(0xFFFAFAF8);
  static const Color bgSecondary = Color(0xFFFFFFFF);
  static const Color bgMuted = Color(0xFFF3F4F1);
  static const Color borderDefault = Color(0xFFE8E8E4);
  
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  static const Color darkBgPrimary = Color(0xFF111111);
  static const Color darkBgSecondary = Color(0xFF1E1E1E);
  static const Color darkBgMuted = Color(0xFF2C2C2E);
  static const Color darkBorder = Color(0xFF333333);
  static const Color darkTextPrimary = Color(0xFFF2F2F2);
  static const Color darkTextSecondary = Color(0xFFBBBBBB);
  static const Color darkTextMuted = Color(0xFF8A8A8A);

  // ─── THEME ACCESSOR ───
  static ZussGoColors colors(BuildContext context) => Theme.of(context).extension<ZussGoColors>()!;
  
  // Backward compatibility alias for 'colors'
  static ZussGoColors of(BuildContext context) => colors(context);

  // ─── CONTEXT-AWARE HELPERS (REFACTORED TO USE EXTENSION) ───
  static Color scaffoldBg(BuildContext context) => colors(context).bgPrimary;
  static Color cardBg(BuildContext context) => colors(context).bgCard;
  static Color mutedBg(BuildContext context) => colors(context).bgMuted;
  static Color border(BuildContext context) => colors(context).border;
  static Color primaryText(BuildContext context) => colors(context).textPrimary;
  static Color secondaryText(BuildContext context) => colors(context).textSecondary;
  static Color mutedText(BuildContext context) => colors(context).textMuted;
  static Color dividerColor(BuildContext context) => colors(context).border;

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

  static TextTheme _buildTextTheme(ZussGoColors colorTheme) {
    return TextTheme(
      displayLarge: TextStyle(fontFamily: 'Playfair Display', fontSize: 32, fontWeight: FontWeight.w700, color: colorTheme.textPrimary, height: 1.15),
      displayMedium: TextStyle(fontFamily: 'Playfair Display', fontSize: 24, fontWeight: FontWeight.w700, color: colorTheme.textPrimary, height: 1.2),
      displaySmall: TextStyle(fontFamily: 'Playfair Display', fontSize: 18, fontWeight: FontWeight.w600, color: colorTheme.textPrimary, height: 1.3),
      bodyLarge: TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.w400, color: colorTheme.textSecondary, height: 1.5),
      bodyMedium: TextStyle(fontFamily: 'Outfit', fontSize: 14, fontWeight: FontWeight.w400, color: colorTheme.textSecondary, height: 1.5),
      bodySmall: TextStyle(fontFamily: 'Outfit', fontSize: 12, fontWeight: FontWeight.w400, color: colorTheme.textMuted, height: 1.4),
      labelLarge: TextStyle(fontFamily: 'Outfit', fontSize: 14, fontWeight: FontWeight.w600, color: colorTheme.textPrimary, height: 1.3),
    );
  }

  // ─── LIGHT THEME ───
  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: ZussGoColors.light.bgPrimary,
    fontFamily: 'Outfit',
    extensions: const <ThemeExtension<dynamic>>[ZussGoColors.light],
    textTheme: _buildTextTheme(ZussGoColors.light),
    colorScheme: ColorScheme.light(
      primary: ZussGoColors.light.green, 
      secondary: ZussGoColors.light.amber, 
      surface: ZussGoColors.light.bgSecondary, 
      error: ZussGoColors.light.rose,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: ZussGoColors.light.bgPrimary, elevation: 0,
      iconTheme: IconThemeData(color: ZussGoColors.light.textPrimary),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? ZussGoColors.light.green : Colors.grey),
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? ZussGoColors.light.greenLight : Colors.grey.shade300),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: ZussGoColors.light.bgMuted,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: ZussGoColors.light.green.withValues(alpha: 0.4), width: 1.5)),
      hintStyle: bodyMedium.copyWith(color: ZussGoColors.light.textMuted),
    ),
  );

  // ─── DARK THEME ───
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: ZussGoColors.dark.bgPrimary,
    fontFamily: 'Outfit',
    extensions: const <ThemeExtension<dynamic>>[ZussGoColors.dark],
    textTheme: _buildTextTheme(ZussGoColors.dark),
    colorScheme: ColorScheme.dark(
      primary: ZussGoColors.dark.green, 
      secondary: ZussGoColors.dark.amber, 
      surface: ZussGoColors.dark.bgSecondary, 
      error: ZussGoColors.dark.rose,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: ZussGoColors.dark.bgPrimary, elevation: 0,
      iconTheme: IconThemeData(color: ZussGoColors.dark.textPrimary),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? ZussGoColors.dark.green : Colors.grey),
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? ZussGoColors.dark.greenLight : Colors.grey.shade700),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: ZussGoColors.dark.bgMuted,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: ZussGoColors.dark.border, width: 1)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: ZussGoColors.dark.green.withValues(alpha: 0.5), width: 1.5)),
      hintStyle: bodyMedium.copyWith(color: ZussGoColors.dark.textMuted),
      labelStyle: bodyMedium.copyWith(color: ZussGoColors.dark.textSecondary),
      prefixIconColor: ZussGoColors.dark.textMuted,
      suffixIconColor: ZussGoColors.dark.textMuted,
    ),
    dividerColor: ZussGoColors.dark.border,
    cardColor: ZussGoColors.dark.bgSecondary,
  );

  // ─── CARD DECORATIONS (context-aware) ───
  static BoxDecoration cardDecoration(BuildContext context) {
    final colors = ZussGoTheme.colors(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: colors.bgCard,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.0 : 0.06), blurRadius: 16, offset: const Offset(0, 4))],
    );
  }

  static BoxDecoration glassCardDecoration(BuildContext context) {
    final colors = ZussGoTheme.colors(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: colors.bgCard,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.0 : 0.04), blurRadius: 10, offset: const Offset(0, 2))],
    );
  }

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

  static InputDecoration inputDecorationOf(BuildContext context, {String? hint, Widget? prefix, Widget? suffix}) {
    final colors = ZussGoTheme.colors(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      hintText: hint,
      hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.textMuted),
      prefixIcon: prefix,
      suffixIcon: suffix,
      filled: true,
      fillColor: colors.bgMuted,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: isDark ? BorderSide(color: colors.border, width: 1) : BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: isDark ? BorderSide(color: colors.border, width: 1) : BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: colors.green.withValues(alpha: 0.5), width: 1.5)),
    );
  }

  // Legacy (backward compat)
  static ThemeData get themeData => lightTheme;
}

// Extension to make static TextStyles context-aware
extension ZussTextStyleExt on TextStyle {
  TextStyle adaptive(BuildContext context) {
    final colors = ZussGoTheme.colors(context);
    // Preserving mapping behavior via the extension
    if (color == ZussGoTheme.textPrimary) return copyWith(color: colors.textPrimary);
    if (color == ZussGoTheme.textSecondary) return copyWith(color: colors.textSecondary);
    if (color == ZussGoTheme.textMuted) return copyWith(color: colors.textMuted);
    return this;
  }
}

// Extension to allow easy context-aware access to theme properties
extension ThemeExt on BuildContext {
  ZussGoColors get colors => Theme.of(this).extension<ZussGoColors>()!;
  TextTheme get textTheme => Theme.of(this).textTheme;
}
