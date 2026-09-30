// Tek bir kategorinin limit satırı: ikon, ad, bütçedeki payı, artır/azalt
// butonları, dokunulabilir tutar kutusu ve ilerleme çubuğu.
import 'package:flutter/material.dart';

import 'package:harcama_takip_uygulamasi/core/utils/category_style.dart';
import '../budget_formatters.dart';
import '../budget_plan.dart';

class CategoryLimitRow extends StatelessWidget {
  final String category;
  final BudgetPlan plan;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;
  final VoidCallback? onTapAmount;

  const CategoryLimitRow({
    super.key,
    required this.category,
    required this.plan,
    required this.onIncrease,
    required this.onDecrease,
    required this.onTapAmount,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final style = CategoryStyles.of(category);
    final color = style.color(context);
    final limit = plan.limitFor(category) ?? 0;
    final hasLimit = limit > 0;
    final double ratio = plan.hasMonthly
        ? (limit / plan.monthly).clamp(0.0, 1.0)
        : 0.0;
    final percent = (ratio * 100).round();

    return Opacity(
      opacity: plan.hasMonthly ? 1 : 0.5,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outline),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(style.icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasLimit ? budgetPercentText(percent) : 'Limit yok',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                _StepButton(icon: Icons.remove, onTap: onDecrease),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onTapAmount,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 76),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${plainAmount(limit)} ₺',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: hasLimit
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _StepButton(icon: Icons.add, onTap: onIncrease),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 6,
                backgroundColor: colorScheme.onSurface.withValues(alpha: 0.08),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final enabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: colorScheme.outline),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled
              ? colorScheme.onSurface
              : colorScheme.onSurface.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
