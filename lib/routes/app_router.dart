import 'package:go_router/go_router.dart';
import 'package:harcama_takip_uygulamasi/screens/auth/login_screen.dart';
import 'package:harcama_takip_uygulamasi/screens/auth/register_screen.dart';
import 'package:harcama_takip_uygulamasi/screens/home_screen.dart';

import '../screens/splash_screen.dart';

final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
  ],
);
