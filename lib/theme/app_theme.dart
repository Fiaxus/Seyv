import 'package:flutter/material.dart';

class AppTheme {
  static LinearGradient balanceGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomRight,
      colors: isDark
          ? const [Color(0xFF215450), Color(0xFF17383D), Color(0xFF142C35)]
          : const [Color(0xFF1E4A46), Color(0xFF14332F), Color(0xFF10282B)],
      stops: isDark ? const [0.0, 0.6, 1.0] : const [0.0, 0.55, 1.0],
    );
  }

  static LinearGradient brandGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? const [Color(0xFF4FE3C1), Color(0xFF54C9DE)]
          : const [Color(0xFF08A88A), Color(0xFF23B7B0)],
    );
  }

  static Color onBrandGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
  }

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