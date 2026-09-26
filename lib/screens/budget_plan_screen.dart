import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../blocs/budget_plan/budget_plan_cubit.dart';
import '../blocs/budget_plan/budget_plan_state.dart';
import '../models/budget_plan.dart';
import '../theme/app_theme.dart';
import '../utils/category_style.dart';
import '../widgets/app_gradient_button.dart';

// ---------- Biçimlendirme yardımcıları ----------

String _plain(double value) => value.round().toString();

String _grouped(double value) =>
    NumberFormat.decimalPattern('tr_TR').format(value.round());

/// "Bütçenin %15'i", "%20'si", "%13'ü" — Türkçe ek sayının okunuşuna göre.
String _percentText(int percent) {
  final p = percent.clamp(0, 100);
  const tens = {
    0: 'ı',
    10: 'u',
    20: 'si',
    30: 'u',
    40: 'ı',
    50: 'si',
    60: 'ı',
    70: 'i',
    80: 'i',
    90: 'ı',
  };
  const ones = {
    1: 'i',
    2: 'si',
    3: 'ü',
    4: 'ü',
    5: 'i',
    6: 'sı',
    7: 'si',
    8: 'i',
    9: 'u',
  };

  final String suffix;
  if (p == 100) {
    suffix = 'ü';
  } else if (p % 10 == 0) {
    suffix = tens[p]!;
  } else {
    suffix = ones[p % 10]!;
  }
  return "Bütçenin %$p'$suffix";
}

// ---------- Ekran ----------

class BudgetPlanScreen extends StatelessWidget {
  const BudgetPlanScreen({super.key});

  Future<void> _handleBack(BuildContext context) async {
    final cubit = context.read<BudgetPlanCubit>();
    if (!cubit.state.isDirty) {
      context.pop();
      return;
    }

    final colorScheme = Theme.of(context).colorScheme;
    final leave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
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
                  color: colorScheme.secondary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: colorScheme.secondary,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Kaydedilmemiş değişiklikler',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: Text(
            'Yaptığın değişiklikler kaydedilmedi. Çıkmak istiyor musun?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actions: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
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
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text('Çık'),
              ),
            ),
          ],
        );
      },
    );

    if (leave == true && context.mounted) {
      context.pop();
    }
  }

  Future<void> _save(BuildContext context) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final cubit = context.read<BudgetPlanCubit>();
    final messenger = ScaffoldMessenger.of(context);

    try {
      await cubit.save(userId);
      messenger.showSnackBar(
        const SnackBar(content: Text('Bütçe planı kaydedildi.')),
      );
      if (context.mounted) context.pop();
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Bütçe planı kaydedilemedi. Lütfen tekrar dene.'),
        ),
      );
    }
  }

  /// Tutar girme dialog'u. [min]/[max] dışındaki değerlerde "Tamam" pasif.
  Future<double?> _askAmount(
    BuildContext context, {
    required String title,
    required double initial,
    double min = 0,
    double? max,
    String? helper,
    String? maxError,
  }) {
    final controller = TextEditingController(
      text: initial > 0 ? _plain(initial) : '',
    );
    String? error;

    return showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            void validate() {
              final value = double.tryParse(controller.text) ?? 0;
              if (max != null && value > max) {
                error = maxError ?? 'En fazla ${_grouped(max)} ₺ girebilirsin.';
              } else if (value < min) {
                error =
                    'Aylık bütçe, kategorilere dağıtılan ${_grouped(min)} ₺ '
                    'tutarından az olamaz.';
              } else {
                error = null;
              }
            }

            return AlertDialog(
              title: Text(title),
              content: TextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => setDialogState(validate),
                decoration: InputDecoration(
                  suffixText: '₺',
                  helperText: helper,
                  helperMaxLines: 2,
                  errorText: error,
                  errorMaxLines: 3,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Vazgeç'),
                ),
                TextButton(
                  onPressed: error != null
                      ? null
                      : () =>
                            Navigator.of(dialogContext)
                                .pop(double.tryParse(controller.text) ?? 0),
                  child: const Text('Tamam'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _editMonthly(BuildContext context) async {
    final cubit = context.read<BudgetPlanCubit>();
    final draft = cubit.state.draft;

    final result = await _askAmount(
      context,
      title: 'Aylık toplam bütçe',
      initial: draft.monthly,
      min: draft.allocated,
      helper: draft.allocated > 0
          ? 'En az ${_grouped(draft.allocated)} ₺ (kategorilere dağıtılan)'
          : null,
    );
    if (result != null) cubit.setMonthly(result);
  }

  Future<void> _editLimit(BuildContext context, String category) async {
    final cubit = context.read<BudgetPlanCubit>();
    final draft = cubit.state.draft;
    final max = draft.maxFor(category);

    final result = await _askAmount(
      context,
      title: '$category limiti',
      initial: draft.limitFor(category) ?? 0,
      max: max,
      helper:
          'En fazla ${_grouped(max)} ₺ ayırabilirsin. 0 girersen limit kaldırılır.',
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
                  // Başlık
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _handleBack(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.surface,
                            border: Border.all(color: colorScheme.outline),
                          ),
                          child: const Icon(Icons.arrow_back, size: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bütçe planı',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            'Aylık bütçe ve kategori limitleri',
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Aylık toplam bütçe kartı
                  _MonthlyCard(
                    plan: plan,
                    onIncrease: cubit.increaseMonthly,
                    onDecrease: cubit.canDecreaseMonthly
                        ? cubit.decreaseMonthly
                        : null,
                    onTapAmount: () => _editMonthly(context),
                  ),
                  const SizedBox(height: 16),

                  // Bilgi kutusu
                  _InfoBox(plan: plan),
                  const SizedBox(height: 24),

                  // Kategori limitleri
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
                    _CategoryLimitRow(
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

// ---------- Aylık toplam bütçe kartı ----------

class _MonthlyCard extends StatelessWidget {
  final BudgetPlan plan;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;
  final VoidCallback onTapAmount;

  const _MonthlyCard({
    required this.plan,
    required this.onIncrease,
    required this.onDecrease,
    required this.onTapAmount,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final double progress = plan.hasMonthly
        ? (plan.allocated / plan.monthly).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primary, AppTheme.heroDark],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AYLIK TOPLAM BÜTÇE',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _HeroStepButton(icon: Icons.remove, onTap: onDecrease),
              Expanded(
                child: GestureDetector(
                  onTap: onTapAmount,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _plain(plan.monthly),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₺',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _HeroStepButton(icon: Icons.add, onTap: onIncrease),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                plan.isValid ? colorScheme.primary : colorScheme.error,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dağıtılan ${_grouped(plan.allocated)} ₺',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
              Text(
                plan.isValid
                    ? 'Boşta ${_grouped(plan.unallocated)} ₺'
                    : 'Fazla ${_grouped(-plan.unallocated)} ₺',
                style: TextStyle(
                  color: plan.isValid ? Colors.white : colorScheme.error,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _HeroStepButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.12),
        ),
        child: Icon(
          icon,
          size: 20,
          color: Colors.white.withValues(alpha: enabled ? 1 : 0.3),
        ),
      ),
    );
  }
}

// ---------- Bilgi kutusu ----------

class _InfoBox extends StatelessWidget {
  final BudgetPlan plan;

  const _InfoBox({required this.plan});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final Color color;
    final IconData icon;
    final String text;

    if (!plan.isValid) {
      color = colorScheme.error;
      icon = Icons.error_outline;
      text =
          'Kategori limitlerinin toplamı aylık bütçeyi aşamaz. '
          '${_grouped(-plan.unallocated)} ₺ fazla dağıtıldı.';
    } else if (!plan.hasMonthly) {
      color = colorScheme.secondary;
      icon = Icons.info_outline;
      text = 'Kategori limiti belirlemek için önce aylık bütçeni belirle.';
    } else {
      color = colorScheme.primary;
      icon = Icons.check_circle_outline;
      text = 'Kategori limitlerinin toplamı aylık bütçeyi aşamaz.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Kategori satırı ----------

class _CategoryLimitRow extends StatelessWidget {
  final String category;
  final BudgetPlan plan;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;
  final VoidCallback? onTapAmount;

  const _CategoryLimitRow({
    required this.category,
    required this.plan,
    required this.onIncrease,
    required this.onDecrease,
    required this.onTapAmount,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final style = CategoryStyles.of(category);
    final limit = plan.limitFor(category) ?? 0;
    final hasLimit = limit > 0;
    final double ratio = plan.hasMonthly
        ? (limit / plan.monthly).clamp(0.0, 1.0)
        : 0.0;
    final percent = (ratio * 100).round();

    return Opacity(
      opacity: plan.hasMonthly ? 1 : 0.5,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outline),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: style.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(style.icon, color: style.color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasLimit ? _percentText(percent) : 'Limit yok',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                _StepButton(icon: Icons.remove, onTap: onDecrease),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onTapAmount,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 76),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_plain(limit)} ₺',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: hasLimit
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _StepButton(icon: Icons.add, onTap: onIncrease),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 6,
                backgroundColor: colorScheme.onSurface.withValues(alpha: 0.08),
                valueColor: AlwaysStoppedAnimation<Color>(style.color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final enabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: colorScheme.outline),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled
              ? colorScheme.onSurface
              : colorScheme.onSurface.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
