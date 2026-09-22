import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../blocs/exchange_rate/exchange_rate_cubit.dart';
import '../blocs/exchange_rate/exchange_rate_state.dart';

class _CurrencyInfo {
  final String code;
  final String name;

  const _CurrencyInfo(this.code, this.name);
}

class ExchangeRatesScreen extends StatefulWidget {
  const ExchangeRatesScreen({super.key});

  @override
  State<ExchangeRatesScreen> createState() => _ExchangeRatesScreenState();
}

class _ExchangeRatesScreenState extends State<ExchangeRatesScreen> {
  final List<_CurrencyInfo> _currencies = const [
    _CurrencyInfo('USD', 'Amerikan Doları'),
    _CurrencyInfo('EUR', 'Euro'),
    _CurrencyInfo('GBP', 'İngiliz Sterlini'),
    _CurrencyInfo('CHF', 'İsviçre Frangı'),
  ];

  DateTime? _lastUpdated;

  @override
  void initState() {
    super.initState();
    _loadRates();
  }

  void _loadRates() {
    context.read<ExchangeRateCubit>().loadRates(
      _currencies.map((c) => c.code).toList(),
    );
    setState(() {
      _lastUpdated = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
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
              Expanded(
                child: BlocBuilder<ExchangeRateCubit, ExchangeRateState>(
                  builder: (context, state) {
                    if (state is ExchangeRateLoading ||
                        state is ExchangeRateInitial) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is ExchangeRateError) {
                      return Center(child: Text('Hata: ${state.message}'));
                    }

                    if (state is ExchangeRateLoaded) {
                      return ListView.builder(
                        itemCount: _currencies.length,
                        itemBuilder: (context, index) {
                          final currency = _currencies[index];
                          final rate = state.rates[currency.code];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: colorScheme.outline),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: colorScheme.primary
                                      .withValues(alpha: 0.15),
                                  child: Text(
                                    currency.code,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                  rate != null
                                      ? NumberFormat.currency(
                                          locale: 'tr_TR',
                                          symbol: '₺',
                                        ).format(rate)
                                      : '—',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }

                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}