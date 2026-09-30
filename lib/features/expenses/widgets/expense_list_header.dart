// Harcamalar ekranının başlığı: ekran adı, filtreye uyan kayıt sayısı,
// seçili dönem ve detaylı filtre sayfasını açan buton.
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:intl/intl.dart';

class ExpenseListHeader extends StatelessWidget {
  final int filteredCount;
  final DateTime? selectedMonth;
  final VoidCallback onFilterTap;

  const ExpenseListHeader({
    super.key,
    required this.filteredCount,
    required this.selectedMonth,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Harcamalar',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            Text(
              '$filteredCount kayıt · '
              '${selectedMonth != null ? DateFormat('MMMM yyyy', 'tr_TR').format(selectedMonth!) : 'Tüm zamanlar'}',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: onFilterTap,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.outline),
            ),
            child: Icon(LucideIcons.sliders_horizontal, size: 18),
          ),
        ),
      ],
    );
  }
}
