import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/budget_repository.dart';
import 'budget_state.dart';

class BudgetCubit extends Cubit<BudgetState> {
  final BudgetRepository _repository = BudgetRepository();
  StreamSubscription<double>? _subscription;

  BudgetCubit() : super(BudgetInitial());

  void loadBudget(String userId) {
    emit(BudgetLoading());

    _subscription?.cancel();
    _subscription = _repository.getBudget(userId).listen(
      (amount) {
        emit(BudgetLoaded(amount));
      },
      onError: (error) {
        emit(BudgetError(error.toString()));
      },
    );
  }

  Future<void> updateBudget(String userId, double amount) async {
    try {
      await _repository.setBudget(userId, amount);
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}