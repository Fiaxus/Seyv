import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import 'package:harcama_takip_uygulamasi/core/utils/category_style.dart';
import 'package:harcama_takip_uygulamasi/core/widgets/app_back_header.dart';
import 'package:harcama_takip_uygulamasi/core/widgets/app_confirm_dialog.dart';
import 'package:harcama_takip_uygulamasi/core/widgets/app_gradient_button.dart';
import 'package:harcama_takip_uygulamasi/core/widgets/app_snackbar.dart';
import '../budget_formatters.dart';
import '../cubit/budget_plan_cubit.dart';
import '../cubit/budget_plan_state.dart';
import '../widgets/amount_input_dialog.dart';
import '../widgets/budget_info_box.dart';
import '../widgets/category_limit_row.dart';
import '../widgets/monthly_budget_card.dart';

class BudgetPlanScreen extends StatelessWidget {
  const BudgetPlanScreen({super.key});

  Future<void> _handleBack(BuildContext context) async {
    final cubit = context.read<BudgetPlanCubit>();
    if (!cubit.state.isDirty) {
      context.pop();
      return;
    }

    final leave = await showAppConfirmDialog(
      context,
      icon: Icons.warning_amber_rounded,
      iconColor: Theme.of(context).colorScheme.secondary,
      title: 'Kaydedilmemiş değişiklikler',
      message: 'Yaptığın değişiklikler kaydedilmedi. Çıkmak istiyor musun?',
      confirmLabel: 'Çık',
    );

    if (leave && context.mounted) {
      context.pop();
    }
  }

  Future<void> _save(BuildContext context) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final cubit = context.read<BudgetPlanCubit>();
    final colorScheme = Theme.of(context).colorScheme;

    try {
      await cubit.save(userId);
      if (context.mounted) {
        AppSnackBar.show(
          context,
          message: 'Bütçe planı kaydedildi.',
          icon: Icons.check_circle_outline,
          color: colorScheme.primary,
        );
        context.pop();
      }
    } catch (_) {
      if (context.mounted) {
        AppSnackBar.show(
          context,
          message: 'Bütçe planı kaydedilemedi. Lütfen tekrar dene.',
          icon: Icons.error_outline,
          color: colorScheme.error,
        );
      }
    }
  }

  Future<void> _editMonthly(BuildContext context) async {
    final cubit = context.read<BudgetPlanCubit>();
    final draft = cubit.state.draft;

    final result = await showAmountInputDialog(
      context,
      title: 'Aylık toplam bütçe',
      initial: draft.monthly,
      min: draft.allocated,
      helper: draft.allocated > 0
          ? 'En az ${groupedAmount(draft.allocated)} ₺ (kategorilere dağıtılan)'
          : null,
    );
    if (result != null) cubit.setMonthly(result);
  }

  Future<void> _editLimit(BuildContext context, String category) async {
    final cubit = context.read<BudgetPlanCubit>();
    final draft = cubit.state.draft;
    final max = draft.maxFor(category);

    final result = await showAmountInputDialog(
      context,
      title: '$category limiti',
      initial: draft.limitFor(category) ?? 0,
      max: max,
      helper:
          'En fazla ${groupedAmount(max)} ₺ ayırabilirsin. 0 girersen limit kaldırılır.',
      maxError: 'Kategori limitlerinin toplamı aylık bütçeyi aşamaz.',
    );
    if (result != null) cubit.setLimit(category, result);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<BudgetPlanCubit, BudgetPlanState>(
      builder: (context, state) {
        final cubit = context.read<BudgetPlanCubit>();
        final plan = state.draft;

        return PopScope(
          canPop: !state.isDirty,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _handleBack(context);
          },
          child: Scaffold(
            body: SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                children: [
                  AppBackHeader(
                    title: 'Bütçe planı',
                    subtitle: 'Aylık bütçe ve kategori limitleri',
                    onBack: () => _handleBack(context),
                  ),
                  const SizedBox(height: 20),
                  MonthlyBudgetCard(
                    plan: plan,
                    onIncrease: cubit.increaseMonthly,
                    onDecrease: cubit.canDecreaseMonthly
                        ? cubit.decreaseMonthly
                        : null,
                    onTapAmount: () => _editMonthly(context),
                  ),
                  const SizedBox(height: 16),
                  BudgetInfoBox(plan: plan),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Kategori limitleri',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${plan.limitedCategoryCount} kategori',
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  for (final category in CategoryStyles.all.keys)
                    CategoryLimitRow(
                      category: category,
                      plan: plan,
                      onIncrease: cubit.canIncreaseLimit(category)
                          ? () => cubit.increaseLimit(category)
                          : null,
                      onDecrease: cubit.canDecreaseLimit(category)
                          ? () => cubit.decreaseLimit(category)
                          : null,
                      onTapAmount: plan.hasMonthly
                          ? () => _editLimit(context, category)
                          : null,
                    ),
                ],
              ),
            ),
            bottomNavigationBar: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: AppGradientButton(
                  label: state.isSaving ? 'Kaydediliyor...' : 'Planı kaydet',
                  onPressed: state.canSave ? () => _save(context) : null,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
