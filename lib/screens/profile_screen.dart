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
import '../utils/auth_error_translator.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<String?> _nameFuture;

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

  /// "Nafi Berkay Şahin" -> "NB"
  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
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

  Future<String?> _askForPassword(
    BuildContext context, {
    required String reason,
  }) async {
    final controller = TextEditingController();
    bool showError = false;

    return showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Şifreni Doğrula'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(reason),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Şifre',
                      errorText: showError ? 'Şifre boş olamaz' : null,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Vazgeç'),
                ),
                TextButton(
                  onPressed: () {
                    if (controller.text.isEmpty) {
                      setDialogState(() {
                        showError = true;
                      });
                      return;
                    }
                    Navigator.of(context).pop(controller.text);
                  },
                  child: const Text('Onayla'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _editProfile(BuildContext context) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final currentName = await _nameFuture ?? '';
    final currentEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    if (!context.mounted) return;

    final nameController = TextEditingController(text: currentName);
    final emailController = TextEditingController(text: currentEmail);
    String? nameError;
    String? emailError;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Profili Düzenle'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Ad Soyad',
                      errorText: nameError,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'E-posta',
                      errorText: emailError,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Vazgeç'),
                ),
                TextButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final email = emailController.text.trim();
                    setDialogState(() {
                      nameError = name.isEmpty ? 'Ad Soyad boş olamaz' : null;
                      emailError = (email.isEmpty || !email.contains('@'))
                          ? 'Geçerli bir e-posta girin'
                          : null;
                    });
                    if (nameError == null && emailError == null) {
                      Navigator.of(context).pop(true);
                    }
                  },
                  child: const Text('Kaydet'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    final newName = nameController.text.trim();
    final newEmail = emailController.text.trim();
    final authCubit = context.read<AuthCubit>();
    final nameChanged = newName != currentName;
    final emailChanged = newEmail != currentEmail;

    // İsim değişikliği: anında kaydedilir, doğrulama gerekmez
    if (nameChanged) {
      await UserRepository().setName(userId, newName);
      setState(() {
        _nameFuture = Future.value(newName);
      });
    }

    // E-posta değişikliği: şifre doğrulaması + yeni adrese doğrulama e-postası
    if (emailChanged) {
      final password = await _askForPassword(
        context,
        reason:
            'Güvenlik nedeniyle, e-postanı değiştirmeden önce şifreni '
            'tekrar girmen gerekiyor.',
      );
      if (password == null || !context.mounted) return;

      try {
        await authCubit.reauthenticate(password: password);
        await authCubit.updateEmail(newEmail: newEmail);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Doğrulama bağlantısı $newEmail adresine gönderildi. '
                'E-postanızın değişmesi için bağlantıya tıklamanız gerekiyor.',
              ),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(translateAuthError(e))),
          );
        }
      }
    } else if (nameChanged && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil güncellendi.')),
      );
    }
  }

  Future<bool> _confirmDeleteAccount(BuildContext context) async {
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
                  Icons.warning_amber_rounded,
                  color: colorScheme.error,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Hesabı Sil',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: Text(
            'Hesabınızı ve tüm harcama verilerinizi kalıcı olarak silmek '
            'istediğinize emin misiniz? Bu işlem geri alınamaz.',
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

  Future<void> _deleteAccount(BuildContext context) async {
    final confirmed = await _confirmDeleteAccount(context);
    if (!confirmed || !context.mounted) return;

    final password = await _askForPassword(
      context,
      reason:
          'Güvenlik nedeniyle, hesabını silmeden önce şifreni tekrar '
          'girmen gerekiyor.',
    );
    if (password == null || !context.mounted) return;

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final expenseCubit = context.read<ExpenseCubit>();
    final authCubit = context.read<AuthCubit>();

    try {
      // 1) Önce kimlik doğrulamasını tazele — bundan sonraki hiçbir
      // adım "requires-recent-login" hatasıyla yarıda kesilmez.
      await authCubit.reauthenticate(password: password);

      // 2) Kimlik doğrulandıktan sonra asıl silme işlemlerine geç.
      await expenseCubit.deleteAllExpensesForUser(userId);
      await UserRepository().deleteUser(userId);
      await authCubit.deleteAccount();

      if (context.mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hesap silinemedi: ${translateAuthError(e)}'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? '';
    final isVerified = user?.emailVerified ?? false;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
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
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colorScheme.outline),
                ),
                child: FutureBuilder<String?>(
                  future: _nameFuture,
                  builder: (context, snapshot) {
                    final name = snapshot.data ?? '';
                    return Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: colorScheme.primary,
                          child: Text(
                            _initials(name),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name.isEmpty ? 'İsimsiz Kullanıcı' : name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                email,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 6),
                              _VerifiedBadge(isVerified: isVerified),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
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

              // Ayarlar listesi (tek kart, satırlar arası çizgi)
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colorScheme.outline),
                ),
                child: Column(
                  children: [
                    _SettingsRow(
                      icon: Icons.edit_outlined,
                      label: 'Profili düzenle',
                      onTap: () => _editProfile(context),
                    ),
                    const _RowDivider(),
                    _SettingsRow(
                      icon: Icons.key_outlined,
                      label: 'Şifre değiştir',
                      onTap: () => _showComingSoon(context),
                    ),
                    const _RowDivider(),
                    BlocBuilder<BudgetCubit, BudgetState>(
                      builder: (context, state) {
                        String trailing = '—';
                        if (state is BudgetLoaded) {
                          final plan = state.plan;
                          trailing = plan.hasMonthly
                              ? '${NumberFormat.decimalPattern('tr_TR').format(plan.monthly.round())} ₺'
                                    ' · ${plan.limitedCategoryCount} kategori'
                              : 'Belirlenmedi';
                        }
                        return _SettingsRow(
                          icon: Icons.account_balance_wallet_outlined,
                          label: 'Bütçe planı',
                          trailing: trailing,
                          onTap: () => context.push('/budget-plan'),
                        );
                      },
                    ),
                    const _RowDivider(),
                    _SettingsRow(
                      icon: Icons.currency_exchange,
                      label: 'Döviz kurları',
                      onTap: () => context.push('/exchange-rates'),
                    ),
                    const _RowDivider(),
                    BlocBuilder<ThemeCubit, ThemeMode>(
                      builder: (context, mode) {
                        return _SettingsRow(
                          icon: Icons.dark_mode_outlined,
                          label: 'Tema',
                          trailing: _themeLabel(mode),
                          onTap: () => _pickTheme(context),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Çıkış Yap
              GestureDetector(
                onTap: () async {
                  await context.read<AuthCubit>().signOut();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.error.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, size: 18, color: colorScheme.error),
                      const SizedBox(width: 8),
                      Text(
                        'Çıkış Yap',
                        style: TextStyle(
                          color: colorScheme.error,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Hesabı Sil
              Center(
                child: TextButton.icon(
                  onPressed: () => _deleteAccount(context),
                  icon: Icon(
                    Icons.delete_outline,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  label: Text(
                    'Hesabı Sil',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  final bool isVerified;

  const _VerifiedBadge({required this.isVerified});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isVerified ? colorScheme.primary : colorScheme.secondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isVerified ? 'Doğrulanmış hesap' : 'Doğrulanmamış hesap',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback onTap;

  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.onSurface.withValues(alpha: 0.06),
              ),
              child: Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (trailing != null)
              Text(
                trailing!,
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Theme.of(context).colorScheme.outline,
    );
  }
}