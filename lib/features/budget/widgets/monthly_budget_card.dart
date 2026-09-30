// Bütçe planı ekranının üstündeki gradyan kart: aylık toplam bütçe,
// artır/azalt butonları ve kategorilere dağıtılan tutarın ilerleme çubuğu.
import 'package:flutter/material.dart';

import 'package:harcama_takip_uygulamasi/core/theme/app_theme.dart';
import '../budget_formatters.dart';
import '../budget_plan.dart';

class MonthlyBudgetCard extends StatelessWidget {
  final BudgetPlan plan;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;
  final VoidCallback onTapAmount;

  const MonthlyBudgetCard({
    super.key,
    required this.plan,
    required this.onIncrease,
    required this.onDecrease,
    required this.onTapAmount,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final double progress = plan.hasMonthly
        ? (plan.allocated / plan.monthly).clamp(0.0, 1.0)
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
          Text(
            'AYLIK TOPLAM BÜTÇE',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _HeroStepButton(icon: Icons.remove, onTap: onDecrease),
              Expanded(
                child: GestureDetector(
                  onTap: onTapAmount,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        plainAmount(plan.monthly),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₺',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _HeroStepButton(icon: Icons.add, onTap: onIncrease),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                plan.isValid ? colorScheme.primary : colorScheme.error,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dağıtılan ${groupedAmount(plan.allocated)} ₺',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
              Text(
                plan.isValid
                    ? 'Boşta ${groupedAmount(plan.unallocated)} ₺'
                    : 'Fazla ${groupedAmount(-plan.unallocated)} ₺',
                style: TextStyle(
                  color: plan.isValid ? Colors.white : colorScheme.error,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _HeroStepButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.12),
        ),
        child: Icon(
          icon,
          size: 20,
          color: Colors.white.withValues(alpha: enabled ? 1 : 0.3),
        ),
      ),
    );
  }
}
