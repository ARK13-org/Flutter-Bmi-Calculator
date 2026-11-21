import 'package:flutter/material.dart';

class AppTheme {
  static const background = Color(0xFF101820);
  static const surface = Color(0xFF1B2733);
  static const primary = Color(0xFF36B37E);
  static const secondary = Color(0xFF8FA99B);
  static const textPrimary = Color(0xFFF4F7F5);
  static const textSecondary = Color(0xFF9AA8B4);
  static const border = Color(0xFF34424E);

  static ThemeData get dark => _build(Brightness.dark);
  static ThemeData get light => _build(Brightness.light);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final bg = dark ? background : const Color(0xFFF4F7F5);
    final card = dark ? surface : Colors.white;
    final fg = dark ? textPrimary : const Color(0xFF17232D);
    final muted = dark ? textSecondary : const Color(0xFF65737E);
    final outline = dark ? border : const Color(0xFFDCE5E0);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: brightness,
        primary: primary,
        secondary: secondary,
        surface: card,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: fg,
        elevation: 0,
        centerTitle: true,
        titleTextStyle:
            TextStyle(color: fg, fontSize: 20, fontWeight: FontWeight.w600),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: outline, width: .7),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        labelStyle: TextStyle(color: muted),
        hintStyle: TextStyle(color: muted),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: outline)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: outline)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: primary, width: 1.5)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: const Color(0xFF081B13),
          minimumSize: const Size.fromHeight(52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      navigationDrawerTheme: NavigationDrawerThemeData(
          backgroundColor: card,
          indicatorColor: primary.withValues(alpha: .18)),
      dividerTheme: DividerThemeData(color: outline),
      textTheme: ThemeData(
        brightness: brightness,
      ).textTheme.apply(
            bodyColor: fg,
            displayColor: fg,
          ),
    );
  }
}
