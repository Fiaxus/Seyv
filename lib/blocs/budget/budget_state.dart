import '../../models/budget_plan.dart';

sealed class BudgetState {}

class BudgetInitial extends BudgetState {}

class BudgetLoading extends BudgetState {}

class BudgetLoaded extends BudgetState {
  final BudgetPlan plan;

  BudgetLoaded(this.plan);
}

class BudgetError extends BudgetState {
  final String message;

  BudgetError(this.message);
}