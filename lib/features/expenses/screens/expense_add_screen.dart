import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:harcama_takip_uygulamasi/core/utils/category_style.dart';
import 'package:harcama_takip_uygulamasi/core/widgets/app_gradient_button.dart';
import 'package:harcama_takip_uygulamasi/core/widgets/app_snackbar.dart';
import '../cubit/expense_cubit.dart';
import 'package:harcama_takip_uygulamasi/features/exchange_rates/cubit/exchange_rate_cubit.dart';
import 'package:harcama_takip_uygulamasi/features/exchange_rates/cubit/exchange_rate_state.dart';
import '../expense.dart';

const Map<String, String> _descriptionHints = {
  'Yemek': 'Öğle yemeği · Ofis',
  'Market': 'Haftalık alışveriş · Migros',
  'Ulaşım': 'Metro + otobüs',
  'Fatura': 'Elektrik faturası',
  'Alışveriş': 'Spor ayakkabı',
  'Eğlence': 'Dijital abonelik',
  'Sağlık': 'Eczane',
  'Eğitim': 'Kurs ücreti',
  'Diğer': 'Açıklama girin',
};

class ExpenseAddScreen extends StatefulWidget {
  final Expense? existingExpense;

  const ExpenseAddScreen({super.key, this.existingExpense});

  @override
  State<ExpenseAddScreen> createState() => _ExpenseAddScreenState();
}

class _ExpenseAddScreenState extends State<ExpenseAddScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedCurrency = 'TRY';
  int _selectedCategoryIndex = 0;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  final List<String> _categoryNames = CategoryStyles.all.keys.toList();

  bool get _isEditing => widget.existingExpense != null;

  @override
  void initState() {
    super.initState();
    context.read<ExchangeRateCubit>().loadRates(['USD', 'EUR']);

    final existing = widget.existingExpense;
    if (existing != null) {
      if (existing.currency != 'TRY' && existing.originalAmount != null) {
        _amountController.text = existing.originalAmount!
            .toStringAsFixed(2)
            .replaceAll('.', ',');
        _selectedCurrency = existing.currency;
      } else {
        _amountController.text = existing.amount
            .toStringAsFixed(2)
            .replaceAll('.', ',');
      }
      _descriptionController.text = existing.description;
      _selectedDate = existing.date;
      final index = _categoryNames.indexOf(existing.categoryName);
      _selectedCategoryIndex = index != -1 ? index : 0;
    } else {
      _amountController.text = '0';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveExpense() async {
    if (_isSaving) return;

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final amountText = _amountController.text.replaceAll(',', '.');
    final enteredAmount = double.tryParse(amountText) ?? 0;

    if (enteredAmount <= 0) {
      AppSnackBar.show(
        context,
        message: 'Lütfen geçerli bir tutar girin.',
        icon: Icons.error_outline,
        color: Theme.of(context).colorScheme.error,
      );
      return;
    }

    double amountTRY = enteredAmount;
    double? exchangeRate;
    double? originalAmount;

    if (_selectedCurrency != 'TRY') {
      final rateState = context.read<ExchangeRateCubit>().state;
      if (rateState is! ExchangeRateLoaded ||
          rateState.rates[_selectedCurrency] == null) {
        AppSnackBar.show(
          context,
          message: 'Kur bilgisi alınamadı, tekrar deneyin.',
          icon: Icons.error_outline,
          color: Theme.of(context).colorScheme.error,
        );
        return;
      }
      exchangeRate = rateState.rates[_selectedCurrency]!;
      originalAmount = enteredAmount;
      amountTRY = enteredAmount * exchangeRate;
    }

    final selectedCategoryName = _categoryNames[_selectedCategoryIndex];

    final expense = Expense(
      id: widget.existingExpense?.id ?? '',
      userId: userId,
      categoryName: selectedCategoryName,
      description: _descriptionController.text,
      location: widget.existingExpense?.location ?? '',
      date: _selectedDate,
      amount: amountTRY,
      currency: _selectedCurrency,
      exchangeRate: exchangeRate,
      originalAmount: originalAmount,
    );

    final cubit = context.read<ExpenseCubit>();

    setState(() {
      _isSaving = true;
    });

    try {
      if (_isEditing) {
        await cubit.updateExpense(expense);
      } else {
        await cubit.addExpense(expense);
      }
      if (context.mounted) {
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        setState(() {
          _isSaving = false;
        });
        AppSnackBar.show(
          context,
          message: 'Kaydedilemedi: $e',
          icon: Icons.error_outline,
          color: Theme.of(context).colorScheme.error,
        );
      }
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
              // Üst bar
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isEditing ? 'Harcama Düzenle' : 'Harcama Ekle',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        _isEditing ? 'Kaydı güncelle' : 'Yeni kayıt oluştur',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Tutar kartı
              Container(
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
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    IntrinsicWidth(
                      child: TextField(
                        controller: _amountController,
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
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    if (_selectedCurrency != 'TRY')
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
                          final rate = state.rates[_selectedCurrency];
                          if (rate == null) return const SizedBox();

                          final amountText = _amountController.text
                              .replaceAll(',', '.');
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
                          final isSelected = currency == _selectedCurrency;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCurrency = currency;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? colorScheme.primary.withValues(
                                          alpha: 0.12,
                                        )
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
              ),
              const SizedBox(height: 24),

              // Kategori
              const Text(
                'Kategori',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _categoryNames.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  final name = _categoryNames[index];
                  final style = CategoryStyles.of(name);
                  final color = style.color(context);
                  final isSelected = index == _selectedCategoryIndex;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategoryIndex = index;
                      });
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? color
                                  : Colors.transparent,
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
              ),
              const SizedBox(height: 24),

              // Tarih
              const Text(
                'Tarih',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('d MMMM yyyy', 'tr_TR').format(_selectedDate),
                      ),
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Açıklama
              const Text(
                'Açıklama',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText:
                      _descriptionHints[_categoryNames[_selectedCategoryIndex]] ??
                      'Açıklama girin',
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Kaydet / Güncelle butonu
              AppGradientButton(
                label: _isSaving
                    ? 'Kaydediliyor...'
                    : (_isEditing ? 'Güncelle' : 'Kaydet'),
                onPressed: _isSaving ? () {} : _saveExpense,
              ),
            ],
          ),
        ),
      ),
    );
  }
}