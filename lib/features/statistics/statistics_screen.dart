import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'package:harcama_takip_uygulamasi/features/expenses/cubit/expense_cubit.dart';
import 'package:harcama_takip_uygulamasi/features/expenses/cubit/expense_state.dart';
import 'widgets/category_distribution_card.dart';
import 'widgets/daily_average_card.dart';
import 'widgets/six_month_chart_card.dart';
import 'widgets/top_category_card.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      context.read<ExpenseCubit>().loadExpenses(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<ExpenseCubit, ExpenseState>(
          builder: (context, state) {
            if (state is! ExpenseLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            final currentMonthExpenses = state.expenses
                .where(
                  (e) => e.date.year == now.year && e.date.month == now.month,
                )
                .toList();

            final monthTotal = currentMonthExpenses.fold<double>(
              0,
              (sum, e) => sum + e.amount,
            );

            final Map<String, double> categoryTotals = {};
            for (final e in currentMonthExpenses) {
              categoryTotals.update(
                e.categoryName,
                (v) => v + e.amount,
                ifAbsent: () => e.amount,
              );
            }
            final sortedCategories = categoryTotals.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

            final List<MonthlyTotal> monthlyTotals = [];
            for (int i = 5; i >= 0; i--) {
              final monthDate = DateTime(now.year, now.month - i, 1);
              final total = state.expenses
                  .where(
                    (e) =>
                        e.date.year == monthDate.year &&
                        e.date.month == monthDate.month,
                  )
                  .fold<double>(0, (sum, e) => sum + e.amount);
              monthlyTotals.add(
                MonthlyTotal(
                  DateFormat('MMM', 'tr_TR').format(monthDate),
                  total,
                ),
              );
            }

            final previousMonthDate = DateTime(now.year, now.month - 1, 1);
            final previousMonthTotal = state.expenses
                .where(
                  (e) =>
                      e.date.year == previousMonthDate.year &&
                      e.date.month == previousMonthDate.month,
                )
                .fold<double>(0, (sum, e) => sum + e.amount);
            final double? trendPercent = previousMonthTotal > 0
                ? ((monthTotal - previousMonthTotal) / previousMonthTotal) * 100
                : null;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'İstatistikler',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                  Text(
                    DateFormat('MMMM yyyy', 'tr_TR').format(now),
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  CategoryDistributionCard(
                    categoryTotals: sortedCategories,
                    monthTotal: monthTotal,
                  ),
                  const SizedBox(height: 16),
                  SixMonthChartCard(
                    monthlyTotals: monthlyTotals,
                    trendPercent: trendPercent,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TopCategoryCard(
                          topCategory: sortedCategories.isNotEmpty
                              ? sortedCategories.first
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DailyAverageCard(
                          monthTotal: monthTotal,
                          dayCount: now.day,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
