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
      surface: const Color(0xFFFFFFFF),
      onSurface: const Color(0xFF12181E),
    );
    final darkColorScheme = ColorScheme.dark(
      primary: const Color(0xFF4FE3C1),
      surface: const Color(0xFF1B232B),
      onSurface: const Color(0xFFEEF6F4),
    );
    return MaterialApp.router(
      title: 'Harcama Takip Uygulaması',
      theme: ThemeData(colorScheme: lightColorScheme, useMaterial3: true),
      darkTheme: ThemeData(colorScheme: darkColorScheme, useMaterial3: true),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
