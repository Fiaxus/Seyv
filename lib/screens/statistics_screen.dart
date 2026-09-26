import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../blocs/expense/expense_cubit.dart';
import '../blocs/expense/expense_state.dart';
import '../theme/app_theme.dart';
import '../utils/category_style.dart';

class _MonthlyTotal {
  final String label;
  final double total;

  const _MonthlyTotal(this.label, this.total);
}

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

            final topEntry = sortedCategories.isNotEmpty
                ? sortedCategories.first
                : null;
            final topStyle = topEntry != null
                ? CategoryStyles.of(topEntry.key)
                : null;

            final List<_MonthlyTotal> monthlyTotals = [];
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
                _MonthlyTotal(
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

            final maxMonthlyTotal = monthlyTotals
                .map((m) => m.total)
                .fold<double>(0, (a, b) => a > b ? a : b);

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
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colorScheme.outline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kategori dağılımı',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        if (sortedCategories.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text('Bu ay için harcama verisi yok.'),
                          )
                        else
                          Row(
                            children: [
                              SizedBox(
                                width: 130,
                                height: 130,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    PieChart(
                                      PieChartData(
                                        sections: sortedCategories.map((entry) {
                                          final style = CategoryStyles.of(
                                            entry.key,
                                          );
                                          return PieChartSectionData(
                                            value: entry.value,
                                            color: style.color(context),
                                            title: '',
                                            radius: 22,
                                          );
                                        }).toList(),
                                        centerSpaceRadius: 40,
                                        sectionsSpace: 2,
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          NumberFormat(
                                            '#,##0',
                                            'tr_TR',
                                          ).format(monthTotal),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          'toplam ₺',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: sortedCategories.map((entry) {
                                    final style = CategoryStyles.of(entry.key);
                                    final percent =
                                        (entry.value / monthTotal * 100)
                                            .round();
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: style.color(context),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              entry.key,
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '%$percent',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colorScheme.outline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Son 6 ay',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            if (trendPercent != null)
                              Row(
                                children: [
                                  Icon(
                                    trendPercent >= 0
                                        ? Icons.trending_up
                                        : Icons.trending_down,
                                    size: 16,
                                    color: trendPercent >= 0
                                        ? colorScheme.error
                                        : colorScheme.primary,
                                  ),
                                  Text(
                                    '%${trendPercent.abs().round()}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: trendPercent >= 0
                                          ? colorScheme.error
                                          : colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 140,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              for (
                                var i = 0;
                                i < monthlyTotals.length;
                                i++
                              ) ...[
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        height: maxMonthlyTotal == 0
                                            ? 4
                                            : (monthlyTotals[i].total /
                                                      maxMonthlyTotal) *
                                                  100,
                                        decoration: BoxDecoration(
                                          gradient:
                                              i == monthlyTotals.length - 1
                                              ? AppTheme.brandGradient(context)
                                              : null,
                                          color: i == monthlyTotals.length - 1
                                              ? null
                                              : colorScheme.primary.withValues(
                                                  alpha: 0.2,
                                                ),
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(20),
                                              ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        monthlyTotals[i].label,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (i != monthlyTotals.length - 1)
                                  const SizedBox(width: 10),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: colorScheme.outline),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'En çok harcanan',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (topEntry == null || topStyle == null)
                                const Text('—')
                              else
                                Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: topStyle
                                            .color(context)
                                            .withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        topStyle.icon,
                                        color: topStyle.color(context),
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            topEntry.key,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            NumberFormat.currency(
                                              locale: 'tr_TR',
                                              symbol: '₺',
                                            ).format(topEntry.value),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: colorScheme.outline),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Günlük ortalama',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                NumberFormat.currency(
                                  locale: 'tr_TR',
                                  symbol: '₺',
                                ).format(monthTotal / now.day),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                '${now.day} gün üzerinden',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
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
