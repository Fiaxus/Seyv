import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/expense.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _expensesRef =>
      _firestore.collection('expenses');

  Future<void> addExpense(Expense expense) async {
    await _expensesRef.add(expense.toMap());
  }

  Stream<List<Expense>> getExpenses(String userId) {
    return _expensesRef
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Expense.fromMap(doc.id, doc.data()))
              .toList();
        });
  }

  Future<void> deleteExpense(String expenseId) async {
    await _expensesRef.doc(expenseId).delete();
  }

  Future<void> updateExpense(Expense expense) async {
    await _expensesRef.doc(expense.id).update(expense.toMap());
  }
}