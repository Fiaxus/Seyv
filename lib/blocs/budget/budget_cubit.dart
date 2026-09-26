import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/budget_plan.dart';
import '../../repositories/budget_repository.dart';
import 'budget_state.dart';

/// Firestore'daki KAYITLI bütçe planını dinler (global).
/// Düzenleme taslağı BudgetPlanCubit'te tutulur.
class BudgetCubit extends Cubit<BudgetState> {
  final BudgetRepository _repository = BudgetRepository();
  StreamSubscription<BudgetPlan>? _subscription;

  BudgetCubit() : super(BudgetInitial());

  void loadBudget(String userId) {
    emit(BudgetLoading());

    _subscription?.cancel();
    _subscription = _repository.getPlan(userId).listen(
      (plan) {
        emit(BudgetLoaded(plan));
      },
      onError: (error) {
        emit(BudgetError(error.toString()));
      },
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}