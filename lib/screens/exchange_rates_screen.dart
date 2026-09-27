import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../blocs/exchange_rate/exchange_rate_cubit.dart';
import '../blocs/exchange_rate/exchange_rate_state.dart';
import '../theme/app_theme.dart';

class _CurrencyInfo {
  final String code;
  final String name;

  const _CurrencyInfo(this.code, this.name);
}

const _currencies = [
  _CurrencyInfo('USD', 'Amerikan Doları'),
  _CurrencyInfo('EUR', 'Euro'),
  _CurrencyInfo('GBP', 'İngiliz Sterlini'),
  _CurrencyInfo('CHF', 'İsviçre Frangı'),
];

final _tryFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
final _amountFormat = NumberFormat.currency(
  locale: 'tr_TR',
  symbol: '',
  decimalDigits: 2,
);

class ExchangeRatesScreen extends StatefulWidget {
  const ExchangeRatesScreen({super.key});

  @override
  State<ExchangeRatesScreen> createState() => _ExchangeRatesScreenState();
}

class _ExchangeRatesScreenState extends State<ExchangeRatesScreen> {
  DateTime? _lastUpdated;

  final _amountController = TextEditingController(text: '1');
  _CurrencyInfo _selectedCurrency = _currencies.first;

  @override
  void initState() {
    super.initState();
    _loadRates();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _loadRates() {
    context.read<ExchangeRateCubit>().loadRates(
      _currencies.map((c) => c.code).toList(),
    );
    setState(() {
      _lastUpdated = DateTime.now();
    });
  }

  Future<void> _pickCurrency() async {
    final selected = await showModalBottomSheet<_CurrencyInfo>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final currency in _currencies)
                ListTile(
                  title: Text('${currency.code} · ${currency.name}'),
                  trailing: currency.code == _selectedCurrency.code
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () => Navigator.of(context).pop(currency),
                ),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      setState(() => _selectedCurrency = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: colorScheme.outline),
                      ),
                      child: const Icon(Icons.arrow_back, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Döviz Kurları',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          _lastUpdated != null
                              ? '${DateFormat('HH:mm').format(_lastUpdated!)} güncellendi'
                              : 'Güncelleniyor...',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _loadRates,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: colorScheme.outline),
                      ),
                      child: const Icon(Icons.refresh, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              BlocBuilder<ExchangeRateCubit, ExchangeRateState>(
                builder: (context, state) {
                  if (state is ExchangeRateLoading ||
                      state is ExchangeRateInitial) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (state is ExchangeRateError) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Center(child: Text('Hata: ${state.message}')),
                    );
                  }

                  final rates = state is ExchangeRateLoaded
                      ? state.rates
                      : <String, double>{};

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _QuickConverter(
                        amountController: _amountController,
                        selectedCurrency: _selectedCurrency,
                        rate: rates[_selectedCurrency.code],
                        onTapCurrency: _pickCurrency,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'GÜNCEL KURLAR',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      for (final currency in _currencies)
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppTheme.cardShadow(context),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: AppTheme.mutedBackground(
                                  context,
                                ),
                                child: Text(
                                  currency.code,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currency.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      '1 ${currency.code} karşılığı',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                rates[currency.code] != null
                                    ? _tryFormat.format(rates[currency.code])
                                    : '—',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickConverter extends StatefulWidget {
  final TextEditingController amountController;
  final _CurrencyInfo selectedCurrency;
  final double? rate;
  final VoidCallback onTapCurrency;

  const _QuickConverter({
    required this.amountController,
    required this.selectedCurrency,
    required this.rate,
    required this.onTapCurrency,
  });

  @override
  State<_QuickConverter> createState() => _QuickConverterState();
}

class _QuickConverterState extends State<_QuickConverter> {
  @override
  void initState() {
    super.initState();
    widget.amountController.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(covariant _QuickConverter oldWidget) {
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
