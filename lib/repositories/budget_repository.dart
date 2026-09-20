import '../services/budget_service.dart';

class BudgetRepository {
  final BudgetService _service = BudgetService();

  Stream<double> getBudget(String userId) {
    return _service.getBudget(userId);
  }

  Future<void> setBudget(String userId, double amount) {
    return _service.setBudget(userId, amount);
  }
}