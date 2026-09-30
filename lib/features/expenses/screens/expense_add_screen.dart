import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:harcama_takip_uygulamasi/core/utils/category_style.dart';
import 'package:harcama_takip_uygulamasi/core/widgets/app_back_header.dart';
import 'package:harcama_takip_uygulamasi/core/widgets/app_gradient_button.dart';
import 'package:harcama_takip_uygulamasi/core/widgets/app_snackbar.dart';
import '../cubit/expense_cubit.dart';
import 'package:harcama_takip_uygulamasi/features/exchange_rates/cubit/exchange_rate_cubit.dart';
import 'package:harcama_takip_uygulamasi/features/exchange_rates/cubit/exchange_rate_state.dart';
import '../expense.dart';
import '../widgets/amount_card.dart';
import '../widgets/category_picker_grid.dart';
import '../widgets/date_field.dart';

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
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
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
              AppBackHeader(
                title: _isEditing ? 'Harcama Düzenle' : 'Harcama Ekle',
                subtitle: _isEditing ? 'Kaydı güncelle' : 'Yeni kayıt oluştur',
              ),
              const SizedBox(height: 24),
              AmountCard(
                controller: _amountController,
                selectedCurrency: _selectedCurrency,
                onAmountChanged: () => setState(() {}),
                onCurrencyChanged: (currency) {
                  setState(() {
                    _selectedCurrency = currency;
                  });
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Kategori',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              CategoryPickerGrid(
                categoryNames: _categoryNames,
                selectedIndex: _selectedCategoryIndex,
                onSelected: (index) {
                  setState(() {
                    _selectedCategoryIndex = index;
                  });
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Tarih',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              DateField(date: _selectedDate, onTap: _pickDate),
              const SizedBox(height: 24),
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
