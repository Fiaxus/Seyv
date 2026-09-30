import 'package:flutter/material.dart';

class AppTheme {
  static LinearGradient balanceGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      begin: const Alignment(-0.5, -0.87),
      end: const Alignment(0.5, 0.87),
      colors: isDark
          ? const [Color(0xFF00493D), Color(0xFF002D30), Color(0xFF052127)]
          : const [Color(0xFF004338), Color(0xFF002624), Color(0xFF001B1D)],
      stops: isDark ? const [0.0, 0.6, 1.0] : const [0.0, 0.55, 1.0],
    );
  }

  static LinearGradient brandGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? const [Color(0xFF36D4A6), Color(0xFF40BECF)]
          : const [Color(0xFF00A27A), Color(0xFF15BBBD)],
    );
  }

  static Color mutedBackground(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.06)
        : colorScheme.onSurface.withValues(alpha: 0.05);
  }

  static Color onBrandGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
  }

  static List<BoxShadow> cardShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
            BoxShadow(
              color: Color(0xCC000000),
              blurRadius: 32,
              offset: Offset(0, 16),
              spreadRadius: -20,
            ),
          ]
        : const [
            BoxShadow(
              color: Color(0x0D10312D),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
            BoxShadow(
              color: Color(0x1A10312D),
              blurRadius: 28,
              offset: Offset(0, 12),
              spreadRadius: -18,
            ),
          ];
  }

  static List<BoxShadow> floatShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? const [
            BoxShadow(
              color: Color(0x734FE3C1),
              blurRadius: 40,
              offset: Offset(0, 18),
              spreadRadius: -18,
            ),
          ]
        : const [
            BoxShadow(
              color: Color(0x8C08A88A),
              blurRadius: 40,
              offset: Offset(0, 18),
              spreadRadius: -18,
            ),
          ];
  }

  static final lightColorScheme = ColorScheme.light(
    primary: const Color(0xFF00A27A),
    tertiary: const Color(0xFF36D4A6),
    surface: const Color(0xFFFFFFFF),
    onSurface: const Color(0xFF0B1F1A),
    secondary: const Color(0xFFEA8A18),
    error: const Color(0xFFDB4144),
    outline: const Color(0xFFE2E8E6),
    onSurfaceVariant: const Color(0xFF5E7A74),
  );

  static final darkColorScheme = ColorScheme.dark(
    primary: const Color(0xFF36D4A6),
    tertiary: const Color(0xFF00A27A),
    surface: const Color(0xFF0F1F24),
    onSurface: const Color(0xFFEEF5F3),
    secondary: const Color(0xFFFAAA51),
    error: const Color(0xFFEF6567),
    outline: Colors.white.withValues(alpha: 0.09),
    onSurfaceVariant: const Color(0xFFA3B8B2),
  );

  static final lightTheme = ThemeData(
    colorScheme: lightColorScheme,
    scaffoldBackgroundColor: const Color(0xFFF6FAF7),
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
    scaffoldBackgroundColor: const Color(0xFF071519),
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
