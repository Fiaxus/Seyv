import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../blocs/expense/expense_cubit.dart';
import '../blocs/expense/expense_state.dart';
import '../models/expense.dart';
import '../models/transaction_data.dart';
import '../utils/category_style.dart';
import '../widgets/transaction_tile.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;

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
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Harcamayı Sil'),
          content: const Text(
            'Bu harcamayı silmek istediğinize emin misiniz? Bu işlem geri alınamaz.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Vazgeç'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Sil',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
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
    final selected = await showModalBottomSheet<String?>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Tümü'),
                onTap: () => Navigator.of(context).pop<String?>(null),
              ),
              ...categories.map(
                (category) => ListTile(
                  title: Text(category),
                  onTap: () => Navigator.of(context).pop<String?>(category),
                ),
              ),
            ],
          ),
        );
      },
    );
    setState(() {
      _selectedCategory = selected;
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
              BlocBuilder<ExpenseCubit, ExpenseState>(
                builder: (context, state) {
                  final count = state is ExpenseLoaded
                      ? state.expenses.length
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
                            '$count kayıt · '
                            '${DateFormat('MMMM yyyy', 'tr_TR').format(DateTime.now())}',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
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

              // Kategori filtre çipi
              BlocBuilder<ExpenseCubit, ExpenseState>(
                builder: (context, state) {
                  final categories = state is ExpenseLoaded
                      ? state.expenses
                            .map((e) => e.categoryName)
                            .toSet()
                            .toList()
                      : <String>[];

                  return Row(
                    children: [
                      GestureDetector(
                        onTap: () => _pickCategory(context, categories),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _selectedCategory != null
                                ? colorScheme.primary.withValues(alpha: 0.12)
                                : colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _selectedCategory ?? 'Kategori',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _selectedCategory != null
                                      ? colorScheme.primary
                                      : colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.keyboard_arrow_down,
                                size: 16,
                                color: _selectedCategory != null
                                    ? colorScheme.primary
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
                      // Filtreleme: arama + kategori
                      var filtered = state.expenses.where((e) {
                        final matchesSearch =
                            _searchQuery.isEmpty ||
                            e.description.toLowerCase().contains(
                              _searchQuery,
                            ) ||
                            e.categoryName.toLowerCase().contains(
                              _searchQuery,
                            );
                        final matchesCategory =
                            _selectedCategory == null ||
                            e.categoryName == _selectedCategory;
                        return matchesSearch && matchesCategory;
                      }).toList();

                      if (filtered.isEmpty) {
                        return const Center(
                          child: Text('Eşleşen harcama bulunamadı.'),
                        );
                      }

                      // Tarihe göre grupla: gerçek "bugün" ile karşılaştır
                      final now = DateTime.now();
                      final isSameDay = (DateTime a, DateTime b) =>
                          a.year == b.year &&
                          a.month == b.month &&
                          a.day == b.day;

                      final todayExpenses = filtered
                          .where((e) => isSameDay(e.date, now))
                          .toList();
                      final olderExpenses = filtered
                          .where((e) => !isSameDay(e.date, now))
                          .toList();

                      Widget buildTile(Expense expense) {
                        final style = CategoryStyles.of(expense.categoryName);
                        final data = TransactionData(
                          icon: style.icon,
                          categoryName: expense.categoryName,
                          description: expense.description,
                          location: expense.location,
                          date: expense.date,
                          amount: expense.amount,
                          accentColor: style.color,
                        );

                        return Dismissible(
                          key: ValueKey(expense.id),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (_) => _confirmDelete(context),
                          onDismissed: (_) {
                            context.read<ExpenseCubit>().deleteExpense(
                              expense.id,
                            );
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

                      return ListView(
                        children: [
                          if (todayExpenses.isNotEmpty) ...[
                            Text(
                              'BUGÜN',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...todayExpenses.map(buildTile),
                          ],
                          if (olderExpenses.isNotEmpty) ...[
                            if (todayExpenses.isNotEmpty)
                              const SizedBox(height: 16),
                            Text(
                              todayExpenses.isEmpty
                                  ? 'HARCAMALAR'
                                  : 'ÖNCEKİ GÜNLER',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...olderExpenses.map(buildTile),
                          ],
                        ],
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