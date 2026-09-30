// Harcama ekleme ekranındaki tutar kartı: büyük tutar alanı, dövizde
// girilen tutarın yaklaşık TL karşılığı ve para birimi seçici.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:harcama_takip_uygulamasi/features/exchange_rates/cubit/exchange_rate_cubit.dart';
import 'package:harcama_takip_uygulamasi/features/exchange_rates/cubit/exchange_rate_state.dart';

class AmountCard extends StatelessWidget {
  final TextEditingController controller;
  final String selectedCurrency;
  final ValueChanged<String> onCurrencyChanged;
  final VoidCallback onAmountChanged;

  const AmountCard({
    super.key,
    required this.controller,
    required this.selectedCurrency,
    required this.onCurrencyChanged,
    required this.onAmountChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        children: [
          Text(
            'Tutar',
            style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          IntrinsicWidth(
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (_) => onAmountChanged(),
            ),
          ),
          if (selectedCurrency != 'TRY')
            BlocBuilder<ExchangeRateCubit, ExchangeRateState>(
              builder: (context, state) {
                if (state is! ExchangeRateLoaded) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      'Kur bilgisi yükleniyor...',
                      style: TextStyle(fontSize: 11),
                    ),
                  );
                }
                final rate = state.rates[selectedCurrency];
                if (rate == null) return const SizedBox();

                final amountText = controller.text.replaceAll(',', '.');
                final entered = double.tryParse(amountText) ?? 0;
                final converted = entered * rate;

                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '≈ ${NumberFormat.currency(locale: 'tr_TR', symbol: '₺').format(converted)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: ['TRY', 'USD', 'EUR'].map((currency) {
                final isSelected = currency == selectedCurrency;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onCurrencyChanged(currency),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.primary.withValues(alpha: 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isSelected
                              ? colorScheme.primary
                              : Colors.transparent,
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        currency,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
