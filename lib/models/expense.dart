import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final String userId;
  final String categoryName;
  final String description;
  final String location;
  final DateTime date;
  final double amount; // Her zaman TL karşılığı
  final String currency; // 'TRY', 'USD', 'EUR'
  final double? exchangeRate; // Kayıt anındaki kur (TRY ise null)
  final double? originalAmount; // Girilen orijinal tutar (TRY ise null)

  const Expense({
    required this.id,
    required this.userId,
    required this.categoryName,
    required this.description,
    required this.location,
    required this.date,
    required this.amount,
    this.currency = 'TRY',
    this.exchangeRate,
    this.originalAmount,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'categoryName': categoryName,
      'description': description,
      'location': location,
      'date': Timestamp.fromDate(date),
      'amount': amount,
      'currency': currency,
      'exchangeRate': exchangeRate,
      'originalAmount': originalAmount,
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
      currency: map['currency'] as String? ?? 'TRY',
      exchangeRate: (map['exchangeRate'] as num?)?.toDouble(),
      originalAmount: (map['originalAmount'] as num?)?.toDouble(),
    );
  }
}