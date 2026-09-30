// Arama kutusunun altındaki yatay filtre çipleri (ay, kategori, para birimi)
// ve varsayılandan farklı bir filtre varken görünen sıfırlama butonu.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpenseFilterBar extends StatelessWidget {
  final DateTime? selectedMonth;
  final String? selectedCategory;
  final String? selectedCurrency;
  final VoidCallback onMonthTap;
  final VoidCallback onCategoryTap;
  final VoidCallback onCurrencyTap;
  final VoidCallback? onReset;

  const ExpenseFilterBar({
    super.key,
    required this.selectedMonth,
    required this.selectedCategory,
    required this.selectedCurrency,
    required this.onMonthTap,
    required this.onCategoryTap,
    required this.onCurrencyTap,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterPill(
            label: selectedMonth != null
                ? DateFormat('MMMM yyyy', 'tr_TR').format(selectedMonth!)
                : 'Tüm zamanlar',
            isActive: true,
            onTap: onMonthTap,
          ),
          const SizedBox(width: 8),
          _FilterPill(
            label: selectedCategory ?? 'Kategori',
            isActive: selectedCategory != null,
            onTap: onCategoryTap,
          ),
          const SizedBox(width: 8),
          _FilterPill(
            label: selectedCurrency ?? 'Para birimi',
            isActive: selectedCurrency != null,
            onTap: onCurrencyTap,
          ),
          if (onReset != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onReset,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.error.withValues(alpha: 0.12),
                ),
                child: Icon(Icons.close, size: 16, color: colorScheme.error),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? colorScheme.primary.withValues(alpha: 0.12)
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: isActive
              ? Border.all(color: colorScheme.primary.withValues(alpha: 0.4))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: isActive
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
