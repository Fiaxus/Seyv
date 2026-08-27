import 'package:go_router/go_router.dart';
import 'package:harcama_takip_uygulamasi/screens/auth/login_screen.dart';
import 'package:harcama_takip_uygulamasi/screens/auth/register_screen.dart';

final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
  ],
);