import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../blocs/expense/expense_cubit.dart';
import '../blocs/expense/expense_state.dart';
import '../models/expense.dart';
import '../models/transaction_data.dart';
import '../utils/category_style.dart';
import '../widgets/transaction_tile.dart';

class CategoryDetailScreen extends StatefulWidget {
  final String categoryName;

  const CategoryDetailScreen({super.key, required this.categoryName});

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  bool _sortByAmount = false;

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
    final style = CategoryStyles.of(widget.categoryName);
    final now = DateTime.now();

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<ExpenseCubit, ExpenseState>(
          builder: (context, state) {
            List<Expense> expenses = [];
            if (state is ExpenseLoaded) {
              expenses = state.expenses
                  .where(
                    (e) =>
                        e.categoryName == widget.categoryName &&
                        e.date.year == now.year &&
                        e.date.month == now.month,
                  )
                  .toList();
            }

            final sorted = [...expenses];
            if (_sortByAmount) {
              sorted.sort((a, b) => b.amount.compareTo(a.amount));
            } else {
              sorted.sort((a, b) => b.date.compareTo(a.date));
            }

            final total = expenses.fold<double>(0, (sum, e) => sum + e.amount);
            final average = expenses.isEmpty ? 0.0 : total / expenses.length;

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: colorScheme.outline),
                          ),
                          child: const Icon(Icons.arrow_back, size: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.categoryName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            DateFormat('MMMM yyyy', 'tr_TR').format(now),
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: style.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: style.color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(style.icon, color: style.color),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          NumberFormat.currency(
                            locale: 'tr_TR',
                            symbol: '₺',
                          ).format(total),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Bu ay ${expenses.length} harcama · ortalama '
                          '${NumberFormat.currency(locale: 'tr_TR', symbol: '₺').format(average)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Bu ayki harcamalar',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _sortByAmount = !_sortByAmount;
                          });
                        },
                        child: Text(
                          'Sırala',
                          style: TextStyle(color: colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: sorted.isEmpty
                        ? const Center(child: Text('Bu kategoride harcama yok.'))
                        : ListView.builder(
                            itemCount: sorted.length,
                            itemBuilder: (context, index) {
                              final expense = sorted[index];
                              final data = TransactionData(
                                icon: style.icon,
                                categoryName: expense.categoryName,
                                description: expense.description,
                                location: expense.location,
                                date: expense.date,
                                amount: expense.amount,
                                accentColor: style.color,
                              );
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: TransactionTile(transaction: data),
                              );
                            },
                          ),
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