import '../../models/budget_plan.dart';

class BudgetPlanState {
  /// Firestore'daki son kayıtlı plan.
  final BudgetPlan saved;

  /// Kullanıcının ekranda düzenlediği, henüz kaydedilmemiş plan.
  final BudgetPlan draft;

  final bool isSaving;

  const BudgetPlanState({
    required this.saved,
    required this.draft,
    this.isSaving = false,
  });

  bool get isDirty => draft != saved;

  bool get canSave => isDirty && draft.isValid && !isSaving;

  BudgetPlanState copyWith({
    BudgetPlan? saved,
    BudgetPlan? draft,
    bool? isSaving,
  }) {
    return BudgetPlanState(
      saved: saved ?? this.saved,
      draft: draft ?? this.draft,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}