import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:harcama_takip_uygulamasi/screens/auth/login_screen.dart';
import 'package:harcama_takip_uygulamasi/screens/auth/register_screen.dart';

import '../blocs/budget/budget_cubit.dart';
import '../blocs/budget/budget_state.dart';
import '../blocs/budget_plan/budget_plan_cubit.dart';
import '../models/budget_plan.dart';
import '../models/expense.dart';
import '../screens/budget_plan_screen.dart';
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
    GoRoute(
      path: '/budget-plan',
      builder: (context, state) {
        // Taslak, kayıtlı planın o anki kopyasıyla başlar.
        final budgetState = context.read<BudgetCubit>().state;
        final initial = budgetState is BudgetLoaded
            ? budgetState.plan
            : BudgetPlan.empty;

        return BlocProvider(
          create: (_) => BudgetPlanCubit(initial),
          child: const BudgetPlanScreen(),
        );
      },
    ),
  ],
);