import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../blocs/expense/expense_cubit.dart';
import '../blocs/expense/expense_state.dart';
import '../blocs/budget/budget_cubit.dart';
import '../blocs/budget/budget_state.dart';
import '../models/budget_plan.dart';
import '../models/category_data.dart';
import '../models/expense.dart';
import '../models/transaction_data.dart';
import '../repositories/user_repository.dart';
import '../theme/app_theme.dart';
import '../utils/category_style.dart';
import '../widgets/category_card.dart';
import '../widgets/transaction_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Future<String?> _nameFuture;

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

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) {
      return 'İyi geceler';
    } else if (hour < 12) {
      return 'Günaydın';
    } else if (hour < 18) {
      return 'İyi günler';
    } else {
      return 'İyi akşamlar';
    }
  }

  String getCurrentMonthYear() {
    final now = DateTime.now();
    return DateFormat('MMMM yyyy', 'tr_TR').format(now);
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
            final budgetAmount = plan.monthly;

            return BlocBuilder<ExpenseCubit, ExpenseState>(
              builder: (context, state) {
                List<CategoryData> categories = [];
                List<Expense> recentExpenses = [];
                double totalAmount = 0;
                double? trendPercent;

                if (state is ExpenseLoaded) {
                  final now = DateTime.now();

                  // Sadece BU AYA ait harcamalar
                  final currentMonthExpenses = state.expenses
                      .where(
                        (e) =>
                            e.date.year == now.year &&
                            e.date.month == now.month,
                      )
                      .toList();

                  // 1) Aylık toplam tutar (sadece bu ay)
                  for (final expense in currentMonthExpenses) {
                    totalAmount += expense.amount;
                  }

                  // Geçen ayın toplamı (trend karşılaştırması için)
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

                  // 2) Kategoriye göre gruplama + toplama (sadece bu ay)
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
                      accentColor: style.color,
                      limit: plan.limitFor(entry.key),
                    );
                  }).toList();

                  // 3) Son harcamalar (tüm zamanlardan en yeni 3 tanesi)
                  recentExpenses = state.expenses.take(3).toList();
                }

                // Bütçe hesaplamaları
                final remaining = budgetAmount - totalAmount;
                final progress = budgetAmount > 0
                    ? (totalAmount / budgetAmount).clamp(0.0, 1.0)
                    : 0.0;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<String?>(
                        future: _nameFuture,
                        builder: (context, snapshot) {
                          final name = snapshot.data ?? '';
                          final initials = name.trim().isNotEmpty
                              ? name.trim()[0].toUpperCase()
                              : '?';

                          return Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                child: Text(
                                  initials,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    getGreeting(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.5),
                                        ),
                                  ),
                                  Text(
                                    name.isEmpty ? 'Kullanıcı' : name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.notifications_outlined,
                                  size: 20,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              AppTheme.heroDark,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${getCurrentMonthYear()} · Toplam harcama',
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(
                                      alpha: 0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'TRY',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              NumberFormat.currency(
                                locale: 'tr_TR',
                                symbol: '₺',
                              ).format(totalAmount),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (trendPercent != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    trendPercent >= 0
                                        ? Icons.trending_up
                                        : Icons.trending_down,
                                    color: Colors.greenAccent[100],
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Geçen aya göre %${trendPercent.abs().round()} '
                                    '${trendPercent >= 0 ? 'daha fazla' : 'daha az'}',
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Aylık bütçe ${NumberFormat.currency(locale: 'tr_TR', symbol: '₺').format(budgetAmount)}',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  'Kalan ${NumberFormat.currency(locale: 'tr_TR', symbol: '₺').format(remaining)}',
                                  style: TextStyle(
                                    color: remaining < 0
                                        ? Theme.of(context).colorScheme.error
                                        : Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 8,
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.2,
                                ),
                                valueColor:
                                    const AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Kategori özeti',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Tümü',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (categories.isEmpty)
                        const Text('Bu ay için kategori verisi yok.')
                      else
                        SizedBox(
                          height: 130,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              final data = categories[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: SizedBox(
                                  width: 110,
                                  child: CategoryCard(
                                    category: data,
                                    onTap: () {
                                      context.push(
                                        '/category-detail/${Uri.encodeComponent(data.categoryName)}',
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Son Harcamalar',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Tümü',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (recentExpenses.isEmpty)
                        const Text('Henüz harcama eklenmedi.')
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: recentExpenses.length,
                          itemBuilder: (context, index) {
                            final expense = recentExpenses[index];
                            final style = CategoryStyles.of(
                              expense.categoryName,
                            );
                            final data = TransactionData(
                              icon: style.icon,
                              categoryName: expense.categoryName,
                              description: expense.description,
                              location: expense.location,
                              date: expense.date,
                              amount: expense.amount,
                              accentColor: style.color,
                              originalCurrency: expense.currency,
                              originalAmount: expense.originalAmount,
                            );
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: TransactionTile(
                                transaction: data,
                                onTap: () {
                                  context.push(
                                    '/expense-add',
                                    extra: expense,
                                  );
                                },
                              ),
                            );
                          },
                        ),
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