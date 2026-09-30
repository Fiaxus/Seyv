// Güncel kurlar listesindeki tek satır: para birimi kodu, adı ve 1 birimin
// TL karşılığı. Kur henüz yoksa tire gösterir.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:harcama_takip_uygulamasi/core/theme/app_theme.dart';
import '../currency_info.dart';

final _tryFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

class RateTile extends StatelessWidget {
  final CurrencyInfo currency;
  final double? rate;

  const RateTile({super.key, required this.currency, required this.rate});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow(context),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.mutedBackground(context),
            child: Text(
              currency.code,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currency.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '1 ${currency.code} karşılığı',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            rate != null ? _tryFormat.format(rate) : '—',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
