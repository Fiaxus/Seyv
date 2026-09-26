import 'package:flutter/material.dart';

import '../models/category_data.dart';

import 'package:intl/intl.dart';

class CategoryCard extends StatelessWidget {
  final CategoryData category;
  final VoidCallback? onTap;

  const CategoryCard({super.key, required this.category, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Limit varsa bar = harcama / limit. Limit yoksa bar boş ve soluk.
    final limit = category.limit;
    final hasLimit = limit != null && limit > 0;
    final double progress = (limit != null && limit > 0)
        ? (category.amount / limit).clamp(0.0, 1.0)
        : 0.0;
    final isOver = limit != null && limit > 0 && category.amount > limit;
    final barColor = isOver ? colorScheme.error : category.accentColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: category.accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(category.icon, color: category.accentColor, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              category.categoryName,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              NumberFormat.currency(
                locale: 'tr_TR',
                symbol: '₺',
              ).format(category.amount),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: hasLimit
                    ? category.accentColor.withValues(alpha: 0.15)
                    : colorScheme.outline,
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}