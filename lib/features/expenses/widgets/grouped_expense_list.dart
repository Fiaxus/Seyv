// Harcamaları tarih başlıkları (BUGÜN, ÖNCEKİ GÜNLER, ay adı) altında
// gruplayarak listeler. Satır sola kaydırılınca onay alıp harcamayı siler,
// dokununca düzenleme ekranını açar.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:harcama_takip_uygulamasi/core/widgets/app_confirm_dialog.dart';
import 'package:harcama_takip_uygulamasi/core/widgets/transaction_tile.dart';
import '../cubit/expense_cubit.dart';
import '../expense.dart';
import '../expense_transaction_data.dart';

class GroupedExpenseList extends StatelessWidget {
  final List<Expense> expenses;

  const GroupedExpenseList({super.key, required this.expenses});

  String _groupLabel(DateTime date, DateTime now) {
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    if (isToday) return 'BUGÜN';
    final isCurrentMonth = date.year == now.year && date.month == now.month;
    if (isCurrentMonth) return 'ÖNCEKİ GÜNLER';
    return DateFormat('MMMM yyyy', 'tr_TR').format(date).toUpperCase();
  }

  Widget _buildTile(BuildContext context, Expense expense) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey(expense.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => showAppConfirmDialog(
        context,
        icon: Icons.delete_outline,
        title: 'Harcamayı Sil',
        message:
            'Bu harcamayı silmek istediğinize emin misiniz? Bu işlem geri alınamaz.',
        confirmLabel: 'Sil',
      ),
      onDismissed: (_) async {
        try {
          await context.read<ExpenseCubit>().deleteExpense(expense.id);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Silinemedi: $e')));
          }
        }
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TransactionTile(
          transaction: expense.toTransactionData(context),
          onTap: () {
            context.push('/expense-add', extra: expense);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();

    final Map<String, List<Expense>> grouped = {};
    for (final expense in expenses) {
      grouped.putIfAbsent(_groupLabel(expense.date, now), () => []).add(expense);
    }
    final groupEntries = grouped.entries.toList();

    return ListView.builder(
      itemCount: groupEntries.length,
      itemBuilder: (_, index) {
        final entry = groupEntries[index];
        return Padding(
          padding: EdgeInsets.only(
            bottom: index == groupEntries.length - 1 ? 0 : 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              for (final expense in entry.value) _buildTile(context, expense),
            ],
          ),
        );
      },
    );
  }
}
