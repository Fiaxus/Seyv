import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final String userId;
  final String categoryName;
  final String description;
  final String location;
  final DateTime date;
  final double amount;

  const Expense({
    required this.id,
    required this.userId,
    required this.categoryName,
    required this.description,
    required this.location,
    required this.date,
    required this.amount,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'categoryName': categoryName,
      'description': description,
      'location': location,
      'date': Timestamp.fromDate(date),
      'amount': amount,
    };
  }

  factory Expense.fromMap(String id, Map<String, dynamic> map) {
    return Expense(
      id: id,
      userId: map['userId'] as String,
      categoryName: map['categoryName'] as String,
      description: map['description'] as String,
      location: map['location'] as String,
      date: (map['date'] as Timestamp).toDate(),
      amount: (map['amount'] as num).toDouble(),
    );
  }
}