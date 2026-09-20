import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../blocs/expense/expense_cubit.dart';
import '../blocs/expense/expense_state.dart';
import '../models/transaction_data.dart';
import '../utils/category_style.dart';
import '../widgets/transaction_tile.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      context.read<ExpenseCubit>().loadExpenses(userId);
    }
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Harcamayı Sil'),
          content: const Text(
            'Bu harcamayı silmek istediğinize emin misiniz? Bu işlem geri alınamaz.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Vazgeç'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Sil',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Harcamalar',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: BlocBuilder<ExpenseCubit, ExpenseState>(
                  builder: (context, state) {
                    if (state is ExpenseLoading || state is ExpenseInitial) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is ExpenseError) {
                      return Center(child: Text('Hata: ${state.message}'));
                    }

                    if (state is ExpenseLoaded) {
                      if (state.expenses.isEmpty) {
                        return const Center(
                          child: Text('Henüz harcama eklenmedi.'),
                        );
                      }

                      return ListView.builder(
                        itemCount: state.expenses.length,
                        itemBuilder: (context, index) {
                          final expense = state.expenses[index];
                          final style = CategoryStyles.of(expense.categoryName);

                          final data = TransactionData(
                            icon: style.icon,
                            categoryName: expense.categoryName,
                            description: expense.description,
                            location: expense.location,
                            date: expense.date,
                            amount: expense.amount,
                            accentColor: style.color,
                          );

                          return Dismissible(
                            key: ValueKey(expense.id),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (_) => _confirmDelete(context),
                            onDismissed: (_) {
                              context.read<ExpenseCubit>().deleteExpense(
                                expense.id,
                              );
                            },
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.error,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.delete_outline,
                                color: Colors.white,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: TransactionTile(transaction: data),
                            ),
                          );
                        },
                      );
                    }

                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}