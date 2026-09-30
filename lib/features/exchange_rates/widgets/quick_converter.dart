// Hızlı çevirici kartı: seçili dövizde girilen tutarın güncel kurla TL
// karşılığını anlık gösterir. Döviz koduna dokununca para birimi seçilir.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:intl/intl.dart';

import 'package:harcama_takip_uygulamasi/core/theme/app_theme.dart';
import '../currency_info.dart';

final _amountFormat = NumberFormat.currency(
  locale: 'tr_TR',
  symbol: '',
  decimalDigits: 2,
);

class QuickConverter extends StatefulWidget {
  final TextEditingController amountController;
  final CurrencyInfo selectedCurrency;
  final double? rate;
  final VoidCallback onTapCurrency;

  const QuickConverter({
    super.key,
    required this.amountController,
    required this.selectedCurrency,
    required this.rate,
    required this.onTapCurrency,
  });

  @override
  State<QuickConverter> createState() => _QuickConverterState();
}

class _QuickConverterState extends State<QuickConverter> {
  @override
  void initState() {
    super.initState();
    widget.amountController.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(covariant QuickConverter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amountController != widget.amountController) {
      oldWidget.amountController.removeListener(_onChanged);
      widget.amountController.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    widget.amountController.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final amount =
        double.tryParse(widget.amountController.text.replaceAll(',', '.')) ?? 0;
    final result = widget.rate != null ? amount * widget.rate! : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hızlı çevirici',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.mutedBackground(context),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: widget.onTapCurrency,
                        child: Text(
                          widget.selectedCurrency.code,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: widget.amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                        ],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          filled: false,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.brandGradient(context),
                ),
                child: Icon(
                  LucideIcons.arrow_up_right,
                  color: AppTheme.onBrandGradient(context),
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TRY',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        result != null ? _amountFormat.format(result) : '—',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
