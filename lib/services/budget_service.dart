import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _userDoc(String userId) =>
      _firestore.collection('users').doc(userId);

  Stream<double> getBudget(String userId) {
    return _userDoc(userId).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (data == null || data['monthlyBudget'] == null) return 0.0;
      return (data['monthlyBudget'] as num).toDouble();
    });
  }

  Future<void> setBudget(String userId, double amount) async {
    await _userDoc(userId).set({
      'monthlyBudget': amount,
    }, SetOptions(merge: true));
  }
}