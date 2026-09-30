// Son 6 ayın toplam harcamalarını çubuk grafik olarak gösteren kart.
// Sağ üstte geçen aya göre artış/azalış yüzdesi yer alır.
import 'package:flutter/material.dart';

import 'package:harcama_takip_uygulamasi/core/theme/app_theme.dart';

// Grafikteki tek bir çubuk: ayın kısa adı ve o ayın toplam harcaması.
class MonthlyTotal {
  final String label;
  final double total;

  const MonthlyTotal(this.label, this.total);
}

class SixMonthChartCard extends StatelessWidget {
  // Eskiden yeniye sıralı; son eleman içinde bulunulan aydır.
  final List<MonthlyTotal> monthlyTotals;
  final double? trendPercent;

  const SixMonthChartCard({
    super.key,
    required this.monthlyTotals,
    required this.trendPercent,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final trend = trendPercent;
    final maxMonthlyTotal = monthlyTotals
        .map((m) => m.total)
        .fold<double>(0, (a, b) => a > b ? a : b);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Son 6 ay',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              if (trend != null)
                Row(
                  children: [
                    Icon(
                      trend >= 0 ? Icons.trending_up : Icons.trending_down,
                      size: 16,
                      color: trend >= 0
                          ? colorScheme.error
                          : colorScheme.primary,
                    ),
                    Text(
                      '%${trend.abs().round()}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: trend >= 0
                            ? colorScheme.error
                            : colorScheme.primary,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < monthlyTotals.length; i++) ...[
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: maxMonthlyTotal == 0
                              ? 4
                              : (monthlyTotals[i].total / maxMonthlyTotal) *
                                    100,
                          decoration: BoxDecoration(
                            gradient: i == monthlyTotals.length - 1
                                ? AppTheme.brandGradient(context)
                                : null,
                            color: i == monthlyTotals.length - 1
                                ? null
                                : colorScheme.primary.withValues(alpha: 0.2),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          monthlyTotals[i].label,
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (i != monthlyTotals.length - 1) const SizedBox(width: 10),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
