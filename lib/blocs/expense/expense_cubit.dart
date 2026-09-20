import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/expense.dart';
import '../../repositories/expense_repository.dart';
import 'expense_state.dart';

class ExpenseCubit extends Cubit<ExpenseState> {
  final ExpenseRepository _repository = ExpenseRepository();
  StreamSubscription<List<Expense>>? _subscription;

  ExpenseCubit() : super(ExpenseInitial());

  void loadExpenses(String userId) {
    emit(ExpenseLoading());

    _subscription?.cancel();
    _subscription = _repository.getExpenses(userId).listen(
      (expenses) {
        emit(ExpenseLoaded(expenses));
      },
      onError: (error) {
        emit(ExpenseError(error.toString()));
      },
    );
  }

  Future<void> addExpense(Expense expense) async {
    try {
      await _repository.addExpense(expense);
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    try {
      await _repository.deleteExpense(expenseId);
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}