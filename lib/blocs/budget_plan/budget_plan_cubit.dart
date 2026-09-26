import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/budget_plan.dart';
import '../../repositories/budget_repository.dart';
import 'budget_plan_state.dart';

/// Sadece Bütçe Planı ekranında yaşar. Butonlar taslağı değiştirir,
/// Firestore'a yalnızca "Planı kaydet" ile yazılır.
class BudgetPlanCubit extends Cubit<BudgetPlanState> {
  static const double monthlyStep = 500;
  static const double categoryStep = 100;

  final BudgetRepository _repository = BudgetRepository();

  BudgetPlanCubit(BudgetPlan initial)
    : super(BudgetPlanState(saved: initial, draft: initial));

  BudgetPlan get _draft => state.draft;

  void _update(BudgetPlan draft) => emit(state.copyWith(draft: draft));

  // ---------- Aylık bütçe ----------

  /// Aylık bütçe, dağıtılan toplamın altına inemez.
  bool get canDecreaseMonthly => _draft.monthly > _draft.allocated;

  void increaseMonthly() {
    _update(_draft.copyWith(monthly: _draft.monthly + monthlyStep));
  }

  void decreaseMonthly() {
    if (!canDecreaseMonthly) return;
    final floor = _draft.allocated;
    final next = _draft.monthly - monthlyStep;
    _update(_draft.copyWith(monthly: next < floor ? floor : next));
  }

  void setMonthly(double value) {
    _update(_draft.copyWith(monthly: value < 0 ? 0 : value));
  }

  // ---------- Kategori limitleri ----------

  /// Aylık bütçe varsa ve boşta tutar kalmışsa artırılabilir.
  bool canIncreaseLimit(String category) =>
      _draft.hasMonthly && _draft.unallocated > 0;

  bool canDecreaseLimit(String category) =>
      (_draft.limitFor(category) ?? 0) > 0;

  void increaseLimit(String category) {
    if (!canIncreaseLimit(category)) return;
    final current = _draft.limitFor(category) ?? 0;
    final max = _draft.maxFor(category);
    final next = current + categoryStep;
    _update(_draft.withLimit(category, next > max ? max : next));
  }

  void decreaseLimit(String category) {
    final current = _draft.limitFor(category) ?? 0;
    final next = current - categoryStep;
    _update(_draft.withLimit(category, next < 0 ? 0 : next));
  }

  void setLimit(String category, double value) {
    _update(_draft.withLimit(category, value));
  }

  // ---------- Kaydet ----------

  /// Hata olursa tekrar fırlatır; ekran SnackBar ile gösterir.
  Future<void> save(String userId) async {
    if (!state.canSave) return;

    emit(state.copyWith(isSaving: true));
    try {
      await _repository.savePlan(userId, state.draft);
      emit(state.copyWith(saved: state.draft, isSaving: false));
    } catch (e) {
      emit(state.copyWith(isSaving: false));
      rethrow;
    }
  }
}