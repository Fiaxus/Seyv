import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:harcama_takip_uygulamasi/core/models/category_data.dart';
import 'package:harcama_takip_uygulamasi/core/utils/category_style.dart';
import 'package:harcama_takip_uygulamasi/features/budget/budget_plan.dart';
import 'package:harcama_takip_uygulamasi/features/budget/cubit/budget_cubit.dart';
import 'package:harcama_takip_uygulamasi/features/budget/cubit/budget_state.dart';
import 'package:harcama_takip_uygulamasi/features/expenses/cubit/expense_cubit.dart';
import 'package:harcama_takip_uygulamasi/features/expenses/cubit/expense_state.dart';
import 'package:harcama_takip_uygulamasi/features/expenses/expense.dart';
import 'package:harcama_takip_uygulamasi/features/profile/user_repository.dart';
import 'widgets/balance_card.dart';
import 'widgets/category_summary_row.dart';
import 'widgets/greeting_header.dart';
import 'widgets/recent_expenses_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Future<String?> _nameFuture;
  bool _sortByAmount = false;

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    _nameFuture = userId != null
        ? UserRepository().getName(userId)
        : Future.value(null);

    if (userId != null) {
      context.read<ExpenseCubit>().loadExpenses(userId);
      context.read<BudgetCubit>().loadBudget(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<BudgetCubit, BudgetState>(
          builder: (context, budgetState) {
            BudgetPlan plan = BudgetPlan.empty;
            if (budgetState is BudgetLoaded) {
              plan = budgetState.plan;
            }

            return BlocBuilder<ExpenseCubit, ExpenseState>(
              builder: (context, state) {
                List<CategoryData> categories = [];
                List<Expense> recentExpenses = [];
                double totalAmount = 0;
                double? trendPercent;

                if (state is ExpenseLoaded) {
                  final now = DateTime.now();

                  final currentMonthExpenses = state.expenses
                      .where(
                        (e) =>
                            e.date.year == now.year &&
                            e.date.month == now.month,
                      )
                      .toList();

                  for (final expense in currentMonthExpenses) {
                    totalAmount += expense.amount;
                  }

                  final previousMonthDate = DateTime(
                    now.year,
                    now.month - 1,
                    1,
                  );
                  final previousMonthTotal = state.expenses
                      .where(
                        (e) =>
                            e.date.year == previousMonthDate.year &&
                            e.date.month == previousMonthDate.month,
                      )
                      .fold<double>(0, (sum, e) => sum + e.amount);

                  if (previousMonthTotal > 0) {
                    trendPercent =
                        ((totalAmount - previousMonthTotal) /
                            previousMonthTotal) *
                        100;
                  }

                  final Map<String, double> categoryTotals = {};
                  for (final expense in currentMonthExpenses) {
                    categoryTotals.update(
                      expense.categoryName,
                      (value) => value + expense.amount,
                      ifAbsent: () => expense.amount,
                    );
                  }

                  categories = categoryTotals.entries.map((entry) {
                    final style = CategoryStyles.of(entry.key);
                    return CategoryData(
                      icon: style.icon,
                      categoryName: entry.key,
                      amount: entry.value,
                      accentColor: style.color(context),
                      limit: plan.limitFor(entry.key),
                    );
                  }).toList();

                  if (_sortByAmount) {
                    categories.sort((a, b) => b.amount.compareTo(a.amount));
                  }

                  recentExpenses = state.expenses.take(3).toList();
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GreetingHeader(nameFuture: _nameFuture),
                      const SizedBox(height: 24),
                      BalanceCard(
                        totalAmount: totalAmount,
                        budgetAmount: plan.monthly,
                        trendPercent: trendPercent,
                      ),
                      const SizedBox(height: 24),
                      CategorySummaryRow(
                        categories: categories,
                        onSortTap: () {
                          setState(() {
                            _sortByAmount = !_sortByAmount;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      RecentExpensesSection(expenses: recentExpenses),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
