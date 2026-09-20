sealed class BudgetState {}

class BudgetInitial extends BudgetState {}

class BudgetLoading extends BudgetState {}

class BudgetLoaded extends BudgetState {
  final double amount;

  BudgetLoaded(this.amount);
}

class BudgetError extends BudgetState {
  final String message;

  BudgetError(this.message);
}