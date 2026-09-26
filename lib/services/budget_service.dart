import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/budget_plan.dart';

class BudgetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _userDoc(String userId) =>
      _firestore.collection('users').doc(userId);

  Stream<BudgetPlan> getPlan(String userId) {
    return _userDoc(userId).snapshots().map(
      (snapshot) => BudgetPlan.fromMap(snapshot.data()),
    );
  }

  Future<void> savePlan(String userId, BudgetPlan plan) async {
    // mergeFields: sadece bu iki alanı TAMAMEN değiştirir, belgedeki diğer
    // alanlara (isim vb.) dokunmaz. `merge: true` kullanılsaydı map iç içe
    // birleştirilir, kaldırılan kategori limitleri Firestore'da kalırdı.
    await _userDoc(userId).set(
      plan.toMap(),
      SetOptions(mergeFields: ['monthlyBudget', 'categoryBudgets']),
    );
  }
}