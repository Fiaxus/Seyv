// Bu ay en çok harcama yapılan kategoriyi ve tutarını gösteren küçük kart.
// Harcama yoksa tire gösterir.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:harcama_takip_uygulamasi/core/utils/category_style.dart';

class TopCategoryCard extends StatelessWidget {
  // Kategori adı -> bu ayki toplam tutar.
  final MapEntry<String, double>? topCategory;

  const TopCategoryCard({super.key, required this.topCategory});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final top = topCategory;
    final style = top != null ? CategoryStyles.of(top.key) : null;

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
            'En çok harcanan',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          if (top == null || style == null)
            const Text('—')
          else
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: style.color(context).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    style.icon,
                    color: style.color(context),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        top.key,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        NumberFormat.currency(
                          locale: 'tr_TR',
                          symbol: '₺',
                        ).format(top.value),
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
