import 'package:go_router/go_router.dart';
import 'package:harcama_takip_uygulamasi/screens/auth/login_screen.dart';
import 'package:harcama_takip_uygulamasi/screens/auth/register_screen.dart';

import '../models/expense.dart';
import '../screens/main_shell.dart';
import '../screens/expense_add_screen.dart';
import '../screens/category_detail_screen.dart';
import '../screens/exchange_rates_screen.dart';
import '../screens/splash_screen.dart';

final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(path: '/home', builder: (context, state) => const MainShell()),
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/expense-add',
      builder: (context, state) => ExpenseAddScreen(
        existingExpense: state.extra as Expense?,
      ),
    ),
    GoRoute(
      path: '/category-detail/:categoryName',
      builder: (context, state) => CategoryDetailScreen(
        categoryName: state.pathParameters['categoryName']!,
      ),
    ),
    GoRoute(
      path: '/exchange-rates',
      builder: (context, state) => const ExchangeRatesScreen(),
    ),
  ],
);