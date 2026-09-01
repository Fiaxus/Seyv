import 'package:flutter/material.dart';
//import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final lightColorScheme = ColorScheme.light(
    primary: const Color(0xFF08A88A),
    tertiary: const Color(0xFF4FE3C1),
    surface: const Color(0xFFFFFFFF),
    onSurface: const Color(0xFF10312D),
    secondary: const Color(0xFFE0912F),
    error: const Color(0xFFDC4A38),
    outline: const Color(0xFFE2E8E6),
    onSurfaceVariant: const Color(0xFF5E7A74),
  );

  static final darkColorScheme = ColorScheme.dark(
    primary: const Color(0xFF4FE3C1),
    tertiary: const Color(0xFF08A88A),
    surface: const Color(0xFF1B232B),
    onSurface: const Color(0xFFEEF6F4),
    secondary: const Color(0xFFF0AE4C),
    error: const Color(0xFFF2745F),
    outline: Colors.white.withValues(alpha: 0.09),
    onSurfaceVariant: const Color(0xFFA3B8B2),
  );

  static final lightTheme = ThemeData(
    colorScheme: lightColorScheme,
    scaffoldBackgroundColor: const Color(0xFFF7FAF8),
    useMaterial3: true,
    //textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.light().textTheme,),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightColorScheme.surface.withValues(alpha: 0.6),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: lightColorScheme.outline),
      ),
    ),
  );

  static final darkTheme = ThemeData(
    colorScheme: darkColorScheme,
    scaffoldBackgroundColor: const Color(0xFF12181E),
    useMaterial3: true,
    //textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkColorScheme.surface.withValues(alpha: 0.6),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: darkColorScheme.outline),
      ),
    ),
  );
}
