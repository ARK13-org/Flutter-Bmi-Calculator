import 'package:flutter/material.dart';

class AppTheme {
  // Professional health-tech palette
  static const background = Color(0xFF101820);
  static const surface = Color(0xFF1B2733);
  static const primary = Color(0xFF36B37E);
  static const secondary = Color(0xFF8FA99B);

  static const textPrimary = Color(0xFFF4F7F5);
  static const textSecondary = Color(0xFF9AA8B4);
  static const border = Color(0xFF34424E);

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,

    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      surface: surface,
      onSurface: textPrimary,
      onPrimary: background,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),

    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: border, width: 0.7),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      labelStyle: const TextStyle(color: textSecondary),
      hintStyle: const TextStyle(color: textSecondary),
      suffixStyle: const TextStyle(color: textSecondary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: background,
        elevation: 0,
        minimumSize: const Size.fromHeight(54),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),

    navigationDrawerTheme: const NavigationDrawerThemeData(
      backgroundColor: surface,
      indicatorColor: Color(0xFF294438),
    ),

    dividerTheme: const DividerThemeData(color: border, thickness: 0.8),

    chipTheme: ChipThemeData(
      backgroundColor: surface,
      side: const BorderSide(color: border),
      labelStyle: const TextStyle(color: textPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),

    iconTheme: const IconThemeData(color: secondary),
  );
}
