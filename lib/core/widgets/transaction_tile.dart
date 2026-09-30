import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'package:harcama_takip_uygulamasi/core/models/transaction_data.dart';

class TransactionTile extends StatelessWidget {
  final TransactionData transaction;
  final VoidCallback? onTap;

  const TransactionTile({super.key, required this.transaction, this.onTap});

  @override
  Widget build(BuildContext context) {
    final showsOriginal =
        transaction.originalCurrency != null &&
        transaction.originalCurrency != 'TRY' &&
        transaction.originalAmount != null;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: transaction.accentColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                transaction.icon,
                color: transaction.accentColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.categoryName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${transaction.description} · ${transaction.location} · '
                    '${DateFormat('d MMM', 'tr_TR').format(transaction.date)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '-${NumberFormat.currency(locale: 'tr_TR', symbol: '₺').format(transaction.amount)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (showsOriginal)
                  Text(
                    '${transaction.originalAmount!.toStringAsFixed(2)} '
                    '${transaction.originalCurrency}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}