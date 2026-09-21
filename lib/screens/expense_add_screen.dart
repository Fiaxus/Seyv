import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/app_gradient_button.dart';
import '../blocs/expense/expense_cubit.dart';
import '../models/expense.dart';

class _CategoryOption {
  final IconData icon;
  final String label;
  final Color color;

  const _CategoryOption(this.icon, this.label, this.color);
}

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

  final List<_CategoryOption> _categories = const [
    _CategoryOption(Icons.restaurant_outlined, 'Yemek', Color(0xFFE0912F)),
    _CategoryOption(Icons.shopping_cart_outlined, 'Market', Color(0xFF08A88A)),
    _CategoryOption(Icons.directions_bus_outlined, 'Ulaşım', Color(0xFF4A90D9)),
    _CategoryOption(Icons.receipt_long_outlined, 'Fatura', Color(0xFF9B7FE0)),
    _CategoryOption(Icons.shopping_bag_outlined, 'Alışveriş', Color(0xFFDC4A38)),
    _CategoryOption(Icons.theater_comedy_outlined, 'Eğlence', Color(0xFFD670C4)),
    _CategoryOption(Icons.favorite_border, 'Sağlık', Color(0xFF3AA0A0)),
    _CategoryOption(Icons.school_outlined, 'Eğitim', Color(0xFFE0B23A)),
    _CategoryOption(Icons.more_horiz, 'Diğer', Color(0xFF8A8A8A)),
  ];

  bool get _isEditing => widget.existingExpense != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingExpense;
    if (existing != null) {
      _amountController.text = existing.amount
          .toStringAsFixed(2)
          .replaceAll('.', ',');
      _descriptionController.text = existing.description;
      _selectedDate = existing.date;
      final index = _categories.indexWhere(
        (c) => c.label == existing.categoryName,
      );
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
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final amountText = _amountController.text.replaceAll(',', '.');
    final amount = double.tryParse(amountText) ?? 0;

    final selectedCategory = _categories[_selectedCategoryIndex];

    final expense = Expense(
      id: widget.existingExpense?.id ?? '',
      userId: userId,
      categoryName: selectedCategory.label,
      description: _descriptionController.text,
      location: widget.existingExpense?.location ?? '',
      date: _selectedDate,
      amount: amount,
    );

    final cubit = context.read<ExpenseCubit>();
    if (_isEditing) {
      await cubit.updateExpense(expense);
    } else {
      await cubit.addExpense(expense);
    }

    if (context.mounted) {
      context.pop();
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
                      ),
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
                itemCount: _categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  final category = _categories[index];
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
                            color: category.color.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? category.color
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            category.icon,
                            color: category.color,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          category.label,
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
                  hintText: 'Öğle yemeği · Ofis',
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
                label: _isEditing ? 'Güncelle' : 'Kaydet',
                onPressed: _saveExpense,
              ),
            ],
          ),
        ),
      ),
    );
  }
}