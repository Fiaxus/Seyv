// Ana ekrandaki "Son Harcamalar" bölümü: en son eklenen birkaç harcama.
// Satıra dokununca harcama düzenleme ekranı açılır.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:harcama_takip_uygulamasi/core/widgets/transaction_tile.dart';
import 'package:harcama_takip_uygulamasi/features/expenses/expense.dart';
import 'package:harcama_takip_uygulamasi/features/expenses/expense_transaction_data.dart';

class RecentExpensesSection extends StatelessWidget {
  final List<Expense> expenses;

  const RecentExpensesSection({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Son Harcamalar',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        if (expenses.isEmpty)
          const Text('Henüz harcama eklenmedi.')
        else
          for (final expense in expenses)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TransactionTile(
                transaction: expense.toTransactionData(context),
                onTap: () {
                  context.push('/expense-add', extra: expense);
                },
              ),
            ),
      ],
    );
  }
}
