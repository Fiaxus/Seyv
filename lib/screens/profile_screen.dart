import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../blocs/auth/auth_cubit.dart';
import '../blocs/budget/budget_cubit.dart';
import '../blocs/budget/budget_state.dart';
import '../blocs/expense/expense_cubit.dart';
import '../blocs/expense/expense_state.dart';
import '../blocs/theme/theme_cubit.dart';
import '../repositories/user_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final Future<String?> _nameFuture;

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    _nameFuture = userId != null
        ? UserRepository().getName(userId)
        : Future.value(null);

    if (userId != null) {
      context.read<BudgetCubit>().loadBudget(userId);
    }
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bu özellik yakında eklenecek.')),
    );
  }

  Future<void> _editBudget(BuildContext context) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final controller = TextEditingController();
    final result = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Aylık Bütçe'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(hintText: 'Örn: 20000'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Vazgeç'),
            ),
            TextButton(
              onPressed: () {
                final value = double.tryParse(
                  controller.text.replaceAll(',', '.'),
                );
                Navigator.of(context).pop(value);
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      await context.read<BudgetCubit>().updateBudget(userId, result);
    }
  }

  String _themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Açık';
      case ThemeMode.dark:
        return 'Koyu';
      case ThemeMode.system:
        return 'Sistem';
    }
  }

  Future<void> _pickTheme(BuildContext context) async {
    final currentMode = context.read<ThemeCubit>().state;

    final selected = await showModalBottomSheet<ThemeMode>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final mode in ThemeMode.values)
                ListTile(
                  title: Text(_themeLabel(mode)),
                  trailing: mode == currentMode
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () => Navigator.of(context).pop(mode),
                ),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      await context.read<ThemeCubit>().setTheme(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Profil',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
              Text(
                'Hesap ve ayarlar',
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),

              // Kullanıcı bilgisi kartı
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outline),
                ),
                child: Row(
                  children: [
                    FutureBuilder<String?>(
                      future: _nameFuture,
                      builder: (context, snapshot) {
                        final name = snapshot.data ?? '';
                        final initials = name.trim().isNotEmpty
                            ? name.trim()[0].toUpperCase()
                            : '?';
                        return CircleAvatar(
                          radius: 24,
                          backgroundColor: colorScheme.primary,
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FutureBuilder<String?>(
                            future: _nameFuture,
                            builder: (context, snapshot) {
                              final name = snapshot.data;
                              return Text(
                                (name == null || name.isEmpty)
                                    ? 'İsimsiz Kullanıcı'
                                    : name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              );
                            },
                          ),
                          Text(
                            email,
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // İstatistik kartları
              BlocBuilder<ExpenseCubit, ExpenseState>(
                builder: (context, state) {
                  int totalCount = 0;
                  int activeMonths = 0;

                  if (state is ExpenseLoaded) {
                    totalCount = state.expenses.length;
                    final months = <String>{};
                    for (final expense in state.expenses) {
                      months.add(
                        '${expense.date.year}-${expense.date.month}',
                      );
                    }
                    activeMonths = months.length;
                  }

                  return Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Toplam kayıt',
                          value: '$totalCount',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'Aktif ay',
                          value: '$activeMonths',
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              // Ayarlar listesi
              _SettingsTile(
                icon: Icons.edit_outlined,
                label: 'Profili düzenle',
                onTap: () => _showComingSoon(context),
              ),
              _SettingsTile(
                icon: Icons.key_outlined,
                label: 'Şifre değiştir',
                onTap: () => _showComingSoon(context),
              ),
              BlocBuilder<BudgetCubit, BudgetState>(
                builder: (context, state) {
                  String trailing = '—';
                  if (state is BudgetLoaded) {
                    trailing = NumberFormat.currency(
                      locale: 'tr_TR',
                      symbol: '₺',
                    ).format(state.amount);
                  }
                  return _SettingsTile(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Aylık bütçe',
                    trailing: trailing,
                    onTap: () => _editBudget(context),
                  );
                },
              ),
              _SettingsTile(
                icon: Icons.currency_exchange,
                label: 'Döviz Kurları',
                onTap: () => context.push('/exchange-rates'),
              ),
              BlocBuilder<ThemeCubit, ThemeMode>(
                builder: (context, mode) {
                  return _SettingsTile(
                    icon: Icons.dark_mode_outlined,
                    label: 'Tema',
                    trailing: _themeLabel(mode),
                    onTap: () => _pickTheme(context),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Çıkış Yap
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    await context.read<AuthCubit>().signOut();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    side: BorderSide(color: colorScheme.error),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Çıkış Yap'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colorScheme.outline),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 14)),
            ),
            if (trailing != null)
              Text(
                trailing!,
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}