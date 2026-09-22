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

  Future<void> addExpense(Expense expense) {
    return _repository.addExpense(expense);
  }

  Future<void> updateExpense(Expense expense) {
    return _repository.updateExpense(expense);
  }

  Future<void> deleteExpense(String expenseId) {
    return _repository.deleteExpense(expenseId);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}