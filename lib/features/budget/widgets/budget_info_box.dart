// Planın durumuna göre renk ve mesaj değiştiren bilgi kutusu: limit aşımı
// (hata), aylık bütçe girilmemiş (uyarı) veya her şey yolunda (bilgi).
import 'package:flutter/material.dart';

import '../budget_formatters.dart';
import '../budget_plan.dart';

class BudgetInfoBox extends StatelessWidget {
  final BudgetPlan plan;

  const BudgetInfoBox({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final Color color;
    final IconData icon;
    final String text;

    if (!plan.isValid) {
      color = colorScheme.error;
      icon = Icons.error_outline;
      text =
          'Kategori limitlerinin toplamı aylık bütçeyi aşamaz. '
          '${groupedAmount(-plan.unallocated)} ₺ fazla dağıtıldı.';
    } else if (!plan.hasMonthly) {
      color = colorScheme.secondary;
      icon = Icons.info_outline;
      text = 'Kategori limiti belirlemek için önce aylık bütçeni belirle.';
    } else {
      color = colorScheme.primary;
      icon = Icons.check_circle_outline;
      text = 'Kategori limitlerinin toplamı aylık bütçeyi aşamaz.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
