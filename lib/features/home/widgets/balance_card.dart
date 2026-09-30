// Ana ekrandaki gradyan özet kartı: bu ayın toplam harcaması, geçen aya
// göre değişim, aylık bütçe, kalan tutar ve bütçe kullanım çubuğu.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:harcama_takip_uygulamasi/core/theme/app_theme.dart';

class BalanceCard extends StatelessWidget {
  final double totalAmount;
  final double budgetAmount;
  // Geçen aya göre yüzde değişim; geçen ay harcama yoksa null.
  final double? trendPercent;

  const BalanceCard({
    super.key,
    required this.totalAmount,
    required this.budgetAmount,
    required this.trendPercent,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    final monthYear = DateFormat('MMMM yyyy', 'tr_TR').format(DateTime.now());
    final trend = trendPercent;
    final remaining = budgetAmount - totalAmount;
    final progress = budgetAmount > 0
        ? (totalAmount / budgetAmount).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.balanceGradient(context),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$monthYear · Toplam harcama',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'TRY',
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            currency.format(totalAmount),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (trend != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  trend >= 0 ? Icons.trending_up : Icons.trending_down,
                  color: Colors.greenAccent[100],
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Geçen aya göre %${trend.abs().round()} '
                  '${trend >= 0 ? 'daha fazla' : 'daha az'}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Aylık bütçe ${currency.format(budgetAmount)}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
              Text(
                'Kalan ${currency.format(remaining)}',
                style: TextStyle(
                  color: remaining < 0
                      ? Theme.of(context).colorScheme.error
                      : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
