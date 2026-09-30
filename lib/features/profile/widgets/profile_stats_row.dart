// Profil ekranındaki iki istatistik kartı: toplam harcama kaydı sayısı ve
// harcama girilmiş farklı ay sayısı.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:harcama_takip_uygulamasi/features/expenses/cubit/expense_cubit.dart';
import 'package:harcama_takip_uygulamasi/features/expenses/cubit/expense_state.dart';

class ProfileStatsRow extends StatelessWidget {
  const ProfileStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseCubit, ExpenseState>(
      builder: (context, state) {
        int totalCount = 0;
        int activeMonths = 0;

        if (state is ExpenseLoaded) {
          totalCount = state.expenses.length;
          final months = <String>{};
          for (final expense in state.expenses) {
            months.add('${expense.date.year}-${expense.date.month}');
          }
          activeMonths = months.length;
        }

        return Row(
          children: [
            Expanded(
              child: _StatCard(label: 'Toplam kayıt', value: '$totalCount'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(label: 'Aktif ay', value: '$activeMonths'),
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
        ],
      ),
    );
  }
}
