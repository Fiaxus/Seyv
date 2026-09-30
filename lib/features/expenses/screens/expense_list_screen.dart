import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../cubit/expense_cubit.dart';
import '../cubit/expense_state.dart';
import '../expense.dart';
import '../widgets/expense_filter_bar.dart';
import '../widgets/expense_filter_sheet.dart';
import '../widgets/expense_list_header.dart';
import '../widgets/grouped_expense_list.dart';
import '../widgets/option_picker_sheet.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedCurrency;
  DateTime? _selectedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );

  bool get _hasActiveFilters {
    final defaultMonth = DateTime(DateTime.now().year, DateTime.now().month);
    final isDefaultMonth =
        _selectedMonth != null &&
        _selectedMonth!.year == defaultMonth.year &&
        _selectedMonth!.month == defaultMonth.month;
    return !isDefaultMonth ||
        _selectedCategory != null ||
        _selectedCurrency != null;
  }

  void _resetFilters() {
    setState(() {
      _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
      _selectedCategory = null;
      _selectedCurrency = null;
    });
  }

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      context.read<ExpenseCubit>().loadExpenses(userId);
    }
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesFilters(Expense e) {
    final matchesMonth =
        _selectedMonth == null ||
        (e.date.year == _selectedMonth!.year &&
            e.date.month == _selectedMonth!.month);
    final matchesCategory =
        _selectedCategory == null || e.categoryName == _selectedCategory;
    final matchesCurrency =
        _selectedCurrency == null || e.currency == _selectedCurrency;
    return matchesMonth && matchesCategory && matchesCurrency;
  }

  bool _matchesSearch(Expense e) {
    return _searchQuery.isEmpty ||
        e.description.toLowerCase().contains(_searchQuery) ||
        e.categoryName.toLowerCase().contains(_searchQuery);
  }

  Future<void> _pickMonth(List<DateTime> months) async {
    final picked = await showOptionPickerSheet<DateTime>(
      context,
      clearLabel: 'Tüm zamanlar',
      options: months,
      labelOf: (month) => DateFormat('MMMM yyyy', 'tr_TR').format(month),
    );
    if (picked == null || !mounted) return;
    setState(() => _selectedMonth = picked.value);
  }

  Future<void> _pickCategory(List<String> categories) async {
    final picked = await showOptionPickerSheet<String>(
      context,
      clearLabel: 'Tümü',
      options: categories,
      labelOf: (category) => category,
    );
    if (picked == null || !mounted) return;
    setState(() => _selectedCategory = picked.value);
  }

  Future<void> _pickCurrency(List<String> currencies) async {
    final picked = await showOptionPickerSheet<String>(
      context,
      clearLabel: 'Tümü',
      options: currencies,
      labelOf: (currency) => currency,
    );
    if (picked == null || !mounted) return;
    setState(() => _selectedCurrency = picked.value);
  }

  Future<void> _openFilterSheet(
    List<DateTime> months,
    List<String> currencies,
  ) async {
    final selection = await showExpenseFilterSheet(
      context,
      current: (
        month: _selectedMonth,
        category: _selectedCategory,
        currency: _selectedCurrency,
      ),
      months: months,
      currencies: currencies,
    );
    if (selection == null || !mounted) return;
    setState(() {
      _selectedMonth = selection.month;
      _selectedCategory = selection.category;
      _selectedCurrency = selection.currency;
    });
  }

  Widget _buildList(ExpenseState state, List<Expense> filtered) {
    if (state is ExpenseLoading || state is ExpenseInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ExpenseError) {
      return Center(child: Text('Hata: ${state.message}'));
    }

    if (state is ExpenseLoaded) {
      final visible = filtered.where(_matchesSearch).toList();
      if (visible.isEmpty) {
        return const Center(child: Text('Eşleşen harcama bulunamadı.'));
      }
      return GroupedExpenseList(expenses: visible);
    }

    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: BlocBuilder<ExpenseCubit, ExpenseState>(
            builder: (context, state) {
              final expenses = state is ExpenseLoaded
                  ? state.expenses
                  : const <Expense>[];

              final months =
                  expenses
                      .map((e) => DateTime(e.date.year, e.date.month))
                      .toSet()
                      .toList()
                    ..sort((a, b) => b.compareTo(a));
              final categories = expenses
                  .map((e) => e.categoryName)
                  .toSet()
                  .toList();
              final currencies =
                  {'TRY', ...expenses.map((e) => e.currency)}.toList()..sort();

              final filtered = expenses.where(_matchesFilters).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExpenseListHeader(
                    filteredCount: filtered.length,
                    selectedMonth: _selectedMonth,
                    onFilterTap: () => _openFilterSheet(months, currencies),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Harcama ara...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ExpenseFilterBar(
                    selectedMonth: _selectedMonth,
                    selectedCategory: _selectedCategory,
                    selectedCurrency: _selectedCurrency,
                    onMonthTap: () => _pickMonth(months),
                    onCategoryTap: () => _pickCategory(categories),
                    onCurrencyTap: () => _pickCurrency(currencies),
                    onReset: _hasActiveFilters ? _resetFilters : null,
                  ),
                  const SizedBox(height: 16),
                  Expanded(child: _buildList(state, filtered)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
