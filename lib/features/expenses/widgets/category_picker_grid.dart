// Harcama ekleme ekranındaki kategori seçim ızgarası: her kategori renkli
// yuvarlak ikon ve adıyla gösterilir, seçili olan çerçeveyle vurgulanır.
import 'package:flutter/material.dart';

import 'package:harcama_takip_uygulamasi/core/utils/category_style.dart';

class CategoryPickerGrid extends StatelessWidget {
  final List<String> categoryNames;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const CategoryPickerGrid({
    super.key,
    required this.categoryNames,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categoryNames.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 12,
        crossAxisSpacing: 8,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        final name = categoryNames[index];
        final style = CategoryStyles.of(name);
        final color = style.color(context);
        final isSelected = index == selectedIndex;
        return GestureDetector(
          onTap: () => onSelected(index),
          child: Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? color : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Icon(style.icon, color: color, size: 22),
              ),
              const SizedBox(height: 6),
              Text(
                name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
