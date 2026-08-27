import 'package:flutter/material.dart';

import 'routes/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final lightColorScheme = ColorScheme.light(
      primary: const Color(0xFF08A88A),
      surface: const Color(0xFFFFFFFF), // card
      onSurface: const Color(0xFF10312D), // foreground
      secondary: const Color(0xFFE0912F), // accent
      error: const Color(0xFFDC4A38), // destructive
    );
    final darkColorScheme = ColorScheme.dark(
      primary: const Color(0xFF4FE3C1),
      surface: const Color(0xFF1B232B), // card
      onSurface: const Color(0xFFEEF6F4), // foreground
      secondary: const Color(0xFFF0AE4C), // accent
      error: const Color(0xFFF2745F), // destructive
    );
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Harcama Takip Uygulaması',
      theme: ThemeData(
        colorScheme: lightColorScheme,
        scaffoldBackgroundColor: const Color(0xFFF7FAF8),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: lightColorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: darkColorScheme,
        scaffoldBackgroundColor: const Color(0xFF12181E),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: darkColorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
