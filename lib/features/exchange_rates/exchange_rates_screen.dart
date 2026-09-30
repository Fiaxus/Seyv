import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:harcama_takip_uygulamasi/core/widgets/app_back_header.dart';
import 'cubit/exchange_rate_cubit.dart';
import 'cubit/exchange_rate_state.dart';
import 'currency_info.dart';
import 'widgets/quick_converter.dart';
import 'widgets/rate_tile.dart';

class ExchangeRatesScreen extends StatefulWidget {
  const ExchangeRatesScreen({super.key});

  @override
  State<ExchangeRatesScreen> createState() => _ExchangeRatesScreenState();
}

class _ExchangeRatesScreenState extends State<ExchangeRatesScreen> {
  DateTime? _lastUpdated;

  final _amountController = TextEditingController(text: '1');
  CurrencyInfo _selectedCurrency = supportedCurrencies.first;

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
      supportedCurrencies.map((c) => c.code).toList(),
    );
    setState(() {
      _lastUpdated = DateTime.now();
    });
  }

  Future<void> _pickCurrency() async {
    final selected = await showModalBottomSheet<CurrencyInfo>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final currency in supportedCurrencies)
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
              AppBackHeader(
                title: 'Döviz Kurları',
                subtitle: _lastUpdated != null
                    ? '${DateFormat('HH:mm').format(_lastUpdated!)} güncellendi'
                    : 'Güncelleniyor...',
                trailing: AppCircleIconButton(
                  icon: Icons.refresh,
                  onTap: _loadRates,
                ),
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
                      QuickConverter(
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
                      for (final currency in supportedCurrencies)
                        RateTile(
                          currency: currency,
                          rate: rates[currency.code],
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
