import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../blocs/expense/expense_cubit.dart';
import '../blocs/expense/expense_state.dart';
import '../models/expense.dart';
import '../models/transaction_data.dart';
import '../utils/category_style.dart';
import '../widgets/app_gradient_button.dart';
import '../widgets/transaction_tile.dart';

const Object _clearSelection = Object();

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
    final isDefaultMonth = _selectedMonth != null &&
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

  Future<bool> _confirmDelete(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colorScheme.error.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: colorScheme.error,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Harcamayı Sil',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: Text(
            'Bu harcamayı silmek istediğinize emin misiniz? Bu işlem geri alınamaz.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actions: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.onSurface,
                  side: BorderSide(color: colorScheme.outline),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Vazgeç'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text('Sil'),
              ),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<void> _pickCategory(
    BuildContext context,
    List<String> categories,
  ) async {
    final result = await showModalBottomSheet<Object?>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: const Text('Tümü'),
                onTap: () =>
                    Navigator.of(context).pop<Object?>(_clearSelection),
              ),
              ...categories.map(
                (category) => ListTile(
                  title: Text(category),
                  onTap: () => Navigator.of(context).pop<Object?>(category),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (result == null) return;
    setState(() {
      _selectedCategory = result == _clearSelection ? null : result as String;
    });
  }

  Future<void> _pickMonth(
    BuildContext context,
    List<DateTime> months,
  ) async {
    final result = await showModalBottomSheet<Object?>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: const Text('Tüm zamanlar'),
                onTap: () =>
                    Navigator.of(context).pop<Object?>(_clearSelection),
              ),
              ...months.map(
                (month) => ListTile(
                  title: Text(DateFormat('MMMM yyyy', 'tr_TR').format(month)),
                  onTap: () => Navigator.of(context).pop<Object?>(month),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (result == null) return;
    setState(() {
      _selectedMonth = result == _clearSelection ? null : result as DateTime;
    });
  }

  Future<void> _pickCurrency(
    BuildContext context,
    List<String> currencies,
  ) async {
    final result = await showModalBottomSheet<Object?>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: const Text('Tümü'),
                onTap: () =>
                    Navigator.of(context).pop<Object?>(_clearSelection),
              ),
              ...currencies.map(
                (currency) => ListTile(
                  title: Text(currency),
                  onTap: () => Navigator.of(context).pop<Object?>(currency),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (result == null) return;
    setState(() {
      _selectedCurrency = result == _clearSelection ? null : result as String;
    });
  }

  Future<void> _openFilterSheet(
    BuildContext context,
    List<DateTime> months,
    List<String> currencies,
  ) async {
    DateTime? tempMonth = _selectedMonth;
    String? tempCategory = _selectedCategory;
    String? tempCurrency = _selectedCurrency;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final colorScheme = Theme.of(sheetContext).colorScheme;
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
                      Text(
                        'Ay',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _SheetChip(
                            label: 'Tüm zamanlar',
                            selected: tempMonth == null,
                            onTap: () =>
                                setSheetState(() => tempMonth = null),
                          ),
                          for (final month in months)
                            _SheetChip(
                              label: DateFormat(
                                'MMMM yyyy',
                                'tr_TR',
                              ).format(month),
                              selected: tempMonth != null &&
                                  tempMonth!.year == month.year &&
                                  tempMonth!.month == month.month,
                              onTap: () =>
                                  setSheetState(() => tempMonth = month),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Kategori',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _SheetChip(
                            label: 'Tümü',
                            selected: tempCategory == null,
                            onTap: () =>
                                setSheetState(() => tempCategory = null),
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
                      Text(
                        'Para birimi',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _SheetChip(
                            label: 'Tümü',
                            selected: tempCurrency == null,
                            onTap: () =>
                                setSheetState(() => tempCurrency = null),
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
                          setState(() {
                            _selectedMonth = tempMonth;
                            _selectedCategory = tempCategory;
                            _selectedCurrency = tempCurrency;
                          });
                          Navigator.of(sheetContext).pop();
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
              BlocBuilder<ExpenseCubit, ExpenseState>(
                builder: (context, state) {
                  final months = state is ExpenseLoaded
                      ? (state.expenses
                              .map((e) => DateTime(e.date.year, e.date.month))
                              .toSet()
                              .toList()
                            ..sort((a, b) => b.compareTo(a)))
                      : <DateTime>[];
                  final currencies = state is ExpenseLoaded
                      ? ({
                          'TRY',
                          ...state.expenses.map((e) => e.currency),
                        }.toList()
                          ..sort())
                      : <String>['TRY'];

                  final filteredCount = state is ExpenseLoaded
                      ? state.expenses.where((e) {
                          final matchesMonth = _selectedMonth == null ||
                              (e.date.year == _selectedMonth!.year &&
                                  e.date.month == _selectedMonth!.month);
                          final matchesCategory = _selectedCategory == null ||
                              e.categoryName == _selectedCategory;
                          final expenseCurrency = e.currency;
                          final matchesCurrency = _selectedCurrency == null ||
                              expenseCurrency == _selectedCurrency;
                          return matchesMonth &&
                              matchesCategory &&
                              matchesCurrency;
                        }).length
                      : 0;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Harcamalar',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                          Text(
                            '$filteredCount kayıt · '
                            '${_selectedMonth != null ? DateFormat('MMMM yyyy', 'tr_TR').format(_selectedMonth!) : 'Tüm zamanlar'}',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => _openFilterSheet(
                          context,
                          months,
                          currencies,
                        ),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: colorScheme.outline),
                          ),
                          child: Icon(
                            LucideIcons.sliders_horizontal,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              // Arama kutusu
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

              // Filtre çipleri: Ay / Kategori / Para birimi
              BlocBuilder<ExpenseCubit, ExpenseState>(
                builder: (context, state) {
                  final months = state is ExpenseLoaded
                      ? (state.expenses
                              .map((e) => DateTime(e.date.year, e.date.month))
                              .toSet()
                              .toList()
                            ..sort((a, b) => b.compareTo(a)))
                      : <DateTime>[];
                  final categories = state is ExpenseLoaded
                      ? state.expenses
                            .map((e) => e.categoryName)
                            .toSet()
                            .toList()
                      : <String>[];
                  final currencies = state is ExpenseLoaded
                      ? ({
                          'TRY',
                          ...state.expenses.map((e) => e.currency),
                        }.toList()
                          ..sort())
                      : <String>['TRY'];

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterPill(
                          label: _selectedMonth != null
                              ? DateFormat(
                                  'MMMM yyyy',
                                  'tr_TR',
                                ).format(_selectedMonth!)
                              : 'Tüm zamanlar',
                          isActive: true,
                          onTap: () => _pickMonth(context, months),
                        ),
                        const SizedBox(width: 8),
                        _FilterPill(
                          label: _selectedCategory ?? 'Kategori',
                          isActive: _selectedCategory != null,
                          onTap: () => _pickCategory(context, categories),
                        ),
                        const SizedBox(width: 8),
                        _FilterPill(
                          label: _selectedCurrency ?? 'Para birimi',
                          isActive: _selectedCurrency != null,
                          onTap: () => _pickCurrency(context, currencies),
                        ),
                        if (_hasActiveFilters) ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _resetFilters,
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colorScheme.error.withValues(
                                  alpha: 0.12,
                                ),
                              ),
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              Expanded(
                child: BlocBuilder<ExpenseCubit, ExpenseState>(
                  builder: (context, state) {
                    if (state is ExpenseLoading || state is ExpenseInitial) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is ExpenseError) {
                      return Center(child: Text('Hata: ${state.message}'));
                    }

                    if (state is ExpenseLoaded) {
                      var filtered = state.expenses.where((e) {
                        final matchesSearch =
                            _searchQuery.isEmpty ||
                            e.description.toLowerCase().contains(
                              _searchQuery,
                            ) ||
                            e.categoryName.toLowerCase().contains(_searchQuery);
                        final matchesCategory =
                            _selectedCategory == null ||
                            e.categoryName == _selectedCategory;
                        final matchesMonth = _selectedMonth == null ||
                            (e.date.year == _selectedMonth!.year &&
                                e.date.month == _selectedMonth!.month);
                        final expenseCurrency = e.currency;
                        final matchesCurrency = _selectedCurrency == null ||
                            expenseCurrency == _selectedCurrency;
                        return matchesSearch &&
                            matchesCategory &&
                            matchesMonth &&
                            matchesCurrency;
                      }).toList();

                      if (filtered.isEmpty) {
                        return const Center(
                          child: Text('Eşleşen harcama bulunamadı.'),
                        );
                      }

                      final now = DateTime.now();

                      String groupLabel(DateTime date) {
                        final isToday = date.year == now.year &&
                            date.month == now.month &&
                            date.day == now.day;
                        if (isToday) return 'BUGÜN';
                        final isCurrentMonth =
                            date.year == now.year && date.month == now.month;
                        if (isCurrentMonth) return 'ÖNCEKİ GÜNLER';
                        return DateFormat(
                          'MMMM yyyy',
                          'tr_TR',
                        ).format(date).toUpperCase();
                      }

                      final Map<String, List<Expense>> grouped = {};
                      for (final expense in filtered) {
                        grouped
                            .putIfAbsent(groupLabel(expense.date), () => [])
                            .add(expense);
                      }
                      final groupEntries = grouped.entries.toList();

                      Widget buildTile(Expense expense) {
                        final style = CategoryStyles.of(expense.categoryName);
                        final data = TransactionData(
                          icon: style.icon,
                          categoryName: expense.categoryName,
                          description: expense.description,
                          location: expense.location,
                          date: expense.date,
                          amount: expense.amount,
                          accentColor: style.color(context),
                          originalCurrency: expense.currency,
                          originalAmount: expense.originalAmount,
                        );

                        return Dismissible(
                          key: ValueKey(expense.id),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (_) => _confirmDelete(context),
                          onDismissed: (_) async {
                            try {
                              await context.read<ExpenseCubit>().deleteExpense(
                                expense.id,
                              );
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Silinemedi: $e')),
                                );
                              }
                            }
                          },
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: colorScheme.error,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: TransactionTile(
                              transaction: data,
                              onTap: () {
                                context.push('/expense-add', extra: expense);
                              },
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: groupEntries.length,
                        itemBuilder: (context, index) {
                          final entry = groupEntries[index];
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index == groupEntries.length - 1
                                  ? 0
                                  : 16,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.key,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...entry.value.map(buildTile),
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

class _FilterPill extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? colorScheme.primary.withValues(alpha: 0.12)
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: isActive
              ? Border.all(color: colorScheme.primary.withValues(alpha: 0.4))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: isActive
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
          ],
        ),
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