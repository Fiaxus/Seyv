import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:harcama_takip_uygulamasi/core/theme/theme_cubit.dart';
import 'package:harcama_takip_uygulamasi/core/utils/auth_error_translator.dart';
import 'package:harcama_takip_uygulamasi/core/widgets/app_confirm_dialog.dart';
import 'package:harcama_takip_uygulamasi/core/widgets/app_snackbar.dart';
import 'package:harcama_takip_uygulamasi/features/auth/cubit/auth_cubit.dart';
import 'package:harcama_takip_uygulamasi/features/budget/cubit/budget_cubit.dart';
import 'package:harcama_takip_uygulamasi/features/budget/cubit/budget_state.dart';
import 'package:harcama_takip_uygulamasi/features/expenses/cubit/expense_cubit.dart';
import 'user_repository.dart';
import 'widgets/change_password_dialog.dart';
import 'widgets/edit_profile_dialog.dart';
import 'widgets/logout_button.dart';
import 'widgets/password_confirm_dialog.dart';
import 'widgets/profile_header_card.dart';
import 'widgets/profile_stats_row.dart';
import 'widgets/settings_row.dart';
import 'widgets/theme_picker_sheet.dart';

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

  Future<void> _handleVerifyTap(BuildContext context) async {
    final authCubit = context.read<AuthCubit>();
    final colorScheme = Theme.of(context).colorScheme;
    final verified = await authCubit.reloadAndCheckVerified();
    if (!context.mounted) return;

    if (verified) {
      setState(() {});
      AppSnackBar.show(
        context,
        message: 'Hesabın doğrulandı.',
        icon: Icons.check_circle_outline,
        color: colorScheme.primary,
      );
      return;
    }

    try {
      await authCubit.sendEmailVerification();
      if (context.mounted) {
        AppSnackBar.show(
          context,
          message:
              'Doğrulama e-postası gönderildi. E-postanı doğruladıktan '
              'sonra buraya tekrar dokun.',
          icon: Icons.mail_outline,
          color: colorScheme.secondary,
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.show(
          context,
          message: translateAuthError(e),
          icon: Icons.error_outline,
          color: colorScheme.error,
        );
      }
    }
  }

  Future<void> _editProfile(BuildContext context) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final currentName = await _nameFuture ?? '';
    final currentEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    if (!context.mounted) return;

    final result = await showEditProfileDialog(
      context,
      initialName: currentName,
      initialEmail: currentEmail,
    );

    if (result == null || !context.mounted) return;

    final newName = result.name;
    final newEmail = result.email;
    final authCubit = context.read<AuthCubit>();
    final nameChanged = newName != currentName;
    final emailChanged = newEmail != currentEmail;

    if (nameChanged) {
      await UserRepository().setName(userId, newName);
      if (!context.mounted) return;
      setState(() {
        _nameFuture = Future.value(newName);
      });
    }

    if (emailChanged) {
      final password = await showPasswordConfirmDialog(
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
          AppSnackBar.show(
            context,
            message:
                'Doğrulama bağlantısı $newEmail adresine gönderildi. '
                'E-postanızın değişmesi için bağlantıya tıklamanız gerekiyor.',
            icon: Icons.mail_outline,
            color: Theme.of(context).colorScheme.secondary,
            duration: const Duration(seconds: 5),
          );
        }
      } catch (e) {
        if (context.mounted) {
          AppSnackBar.show(
            context,
            message: translateAuthError(e),
            icon: Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
          );
        }
      }
    } else if (nameChanged && context.mounted) {
      AppSnackBar.show(
        context,
        message: 'Profil güncellendi.',
        icon: Icons.check_circle_outline,
        color: Theme.of(context).colorScheme.primary,
      );
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final confirmed = await showAppConfirmDialog(
      context,
      icon: Icons.warning_amber_rounded,
      title: 'Hesabı Sil',
      message:
          'Hesabınızı ve tüm harcama verilerinizi kalıcı olarak silmek '
          'istediğinize emin misiniz? Bu işlem geri alınamaz.',
      confirmLabel: 'Sil',
    );
    if (!confirmed || !context.mounted) return;

    final password = await showPasswordConfirmDialog(
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
      await authCubit.reauthenticate(password: password);

      await expenseCubit.deleteAllExpensesForUser(userId);
      await UserRepository().deleteUser(userId);
      await authCubit.deleteAccount();

      if (context.mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.show(
          context,
          message: 'Hesap silinemedi: ${translateAuthError(e)}',
          icon: Icons.error_outline,
          color: Theme.of(context).colorScheme.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;

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
              ProfileHeaderCard(
                nameFuture: _nameFuture,
                email: user?.email ?? '',
                isVerified: user?.emailVerified ?? false,
                onVerifyTap: () => _handleVerifyTap(context),
              ),
              const SizedBox(height: 16),
              const ProfileStatsRow(),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colorScheme.outline),
                ),
                child: Column(
                  children: [
                    SettingsRow(
                      icon: Icons.edit_outlined,
                      label: 'Profili düzenle',
                      onTap: () => _editProfile(context),
                    ),
                    const SettingsRowDivider(),
                    SettingsRow(
                      icon: Icons.key_outlined,
                      label: 'Şifre değiştir',
                      onTap: () => showChangePasswordDialog(context),
                    ),
                    const SettingsRowDivider(),
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
                        return SettingsRow(
                          icon: Icons.account_balance_wallet_outlined,
                          label: 'Bütçe planı',
                          trailing: trailing,
                          onTap: () => context.push('/budget-plan'),
                        );
                      },
                    ),
                    const SettingsRowDivider(),
                    SettingsRow(
                      icon: Icons.currency_exchange,
                      label: 'Döviz kurları',
                      onTap: () => context.push('/exchange-rates'),
                    ),
                    const SettingsRowDivider(),
                    BlocBuilder<ThemeCubit, ThemeMode>(
                      builder: (context, mode) {
                        return SettingsRow(
                          icon: Icons.dark_mode_outlined,
                          label: 'Tema',
                          trailing: themeLabel(mode),
                          onTap: () => showThemePickerSheet(context),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              LogoutButton(
                onTap: () async {
                  await context.read<AuthCubit>().signOut();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
              ),
              const SizedBox(height: 12),
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
