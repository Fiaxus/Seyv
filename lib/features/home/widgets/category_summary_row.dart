// Ana ekrandaki "Kategori özeti" bölümü: başlık, sıralama bağlantısı ve
// bu ayın kategori kartlarının yatay listesi.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:harcama_takip_uygulamasi/core/models/category_data.dart';
import 'package:harcama_takip_uygulamasi/core/widgets/category_card.dart';

class CategorySummaryRow extends StatelessWidget {
  final List<CategoryData> categories;
  final VoidCallback onSortTap;

  const CategorySummaryRow({
    super.key,
    required this.categories,
    required this.onSortTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Kategori özeti',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            GestureDetector(
              onTap: onSortTap,
              child: Text(
                'Sırala',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (categories.isEmpty)
          const Text('Bu ay için kategori verisi yok.')
        else
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final data = categories[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: SizedBox(
                    width: 110,
                    child: CategoryCard(
                      category: data,
                      onTap: () {
                        context.push(
                          '/category-detail/${Uri.encodeComponent(data.categoryName)}',
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
