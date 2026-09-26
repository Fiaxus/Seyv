import '../models/budget_plan.dart';
import '../services/budget_service.dart';

class BudgetRepository {
  final BudgetService _service = BudgetService();

  Stream<BudgetPlan> getPlan(String userId) {
    return _service.getPlan(userId);
  }

  Future<void> savePlan(String userId, BudgetPlan plan) {
    return _service.savePlan(userId, plan);
  }
}