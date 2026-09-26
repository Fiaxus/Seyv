import '../models/expense.dart';
import '../services/firestore_service.dart';

class ExpenseRepository {
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> addExpense(Expense expense) {
    return _firestoreService.addExpense(expense);
  }

  Stream<List<Expense>> getExpenses(String userId) {
    return _firestoreService.getExpenses(userId);
  }

  Future<void> deleteExpense(String expenseId) {
    return _firestoreService.deleteExpense(expenseId);
  }

  Future<void> updateExpense(Expense expense) {
    return _firestoreService.updateExpense(expense);
  }

  Future<void> deleteAllExpensesForUser(String userId) {
    return _firestoreService.deleteAllExpensesForUser(userId);
  }
}