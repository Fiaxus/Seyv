// Ay, kategori ve para birimi filtrelerinin tek yerden seçildiği alt sayfa.
// "Uygula"ya basılırsa seçimleri döner, sayfa kapatılırsa null döner.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:harcama_takip_uygulamasi/core/utils/category_style.dart';
import 'package:harcama_takip_uygulamasi/core/widgets/app_gradient_button.dart';

typedef ExpenseFilterSelection = ({
  DateTime? month,
  String? category,
  String? currency,
});

Future<ExpenseFilterSelection?> showExpenseFilterSheet(
  BuildContext context, {
  required ExpenseFilterSelection current,
  required List<DateTime> months,
  required List<String> currencies,
}) {
  DateTime? tempMonth = current.month;
  String? tempCategory = current.category;
  String? tempCurrency = current.currency;

  return showModalBottomSheet<ExpenseFilterSelection>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filtrele',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setSheetState(() {
                              tempMonth = null;
                              tempCategory = null;
                              tempCurrency = null;
                            });
                          },
                          child: const Text('Temizle'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const _SectionLabel('Ay'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _SheetChip(
                          label: 'Tüm zamanlar',
                          selected: tempMonth == null,
                          onTap: () => setSheetState(() => tempMonth = null),
                        ),
                        for (final month in months)
                          _SheetChip(
                            label: DateFormat(
                              'MMMM yyyy',
                              'tr_TR',
                            ).format(month),
                            selected:
                                tempMonth != null &&
                                tempMonth!.year == month.year &&
                                tempMonth!.month == month.month,
                            onTap: () => setSheetState(() => tempMonth = month),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const _SectionLabel('Kategori'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _SheetChip(
                          label: 'Tümü',
                          selected: tempCategory == null,
                          onTap: () => setSheetState(() => tempCategory = null),
                        ),
                        for (final category in CategoryStyles.all.keys)
                          _SheetChip(
                            label: category,
                            selected: tempCategory == category,
                            onTap: () =>
                                setSheetState(() => tempCategory = category),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const _SectionLabel('Para birimi'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _SheetChip(
                          label: 'Tümü',
                          selected: tempCurrency == null,
                          onTap: () => setSheetState(() => tempCurrency = null),
                        ),
                        for (final currency in currencies)
                          _SheetChip(
                            label: currency,
                            selected: tempCurrency == currency,
                            onTap: () =>
                                setSheetState(() => tempCurrency = currency),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    AppGradientButton(
                      label: 'Uygula',
                      onPressed: () {
                        Navigator.of(sheetContext).pop((
                          month: tempMonth,
                          category: tempCategory,
                          currency: tempCurrency,
                        ));
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 13,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _SheetChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SheetChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primary.withValues(alpha: 0.12)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? colorScheme.primary : colorScheme.outline,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              Icon(Icons.check, size: 14, color: colorScheme.primary),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
