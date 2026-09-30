// Bu ayın toplam harcamasını ayın geçen gün sayısına bölerek günlük
// ortalamayı gösteren küçük kart.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailyAverageCard extends StatelessWidget {
  final double monthTotal;
  final int dayCount;

  const DailyAverageCard({
    super.key,
    required this.monthTotal,
    required this.dayCount,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
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
            ).format(monthTotal / dayCount),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(
            '$dayCount gün üzerinden',
            style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
