import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:harcama_takip_uygulamasi/features/auth/screens/login_screen.dart';
import 'package:harcama_takip_uygulamasi/features/auth/screens/register_screen.dart';

import 'package:harcama_takip_uygulamasi/features/budget/cubit/budget_cubit.dart';
import 'package:harcama_takip_uygulamasi/features/budget/cubit/budget_state.dart';
import 'package:harcama_takip_uygulamasi/features/budget/cubit/budget_plan_cubit.dart';
import 'package:harcama_takip_uygulamasi/features/budget/budget_plan.dart';
import 'package:harcama_takip_uygulamasi/features/expenses/expense.dart';
import 'package:harcama_takip_uygulamasi/features/budget/screens/budget_plan_screen.dart';
import 'package:harcama_takip_uygulamasi/app/main_shell.dart';
import 'package:harcama_takip_uygulamasi/features/expenses/screens/expense_add_screen.dart';
import 'package:harcama_takip_uygulamasi/features/budget/screens/category_detail_screen.dart';
import 'package:harcama_takip_uygulamasi/features/exchange_rates/exchange_rates_screen.dart';
import 'package:harcama_takip_uygulamasi/features/auth/screens/splash_screen.dart';

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