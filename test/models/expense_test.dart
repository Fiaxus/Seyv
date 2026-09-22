import 'package:flutter_test/flutter_test.dart';
import 'package:harcama_takip_uygulamasi/models/expense.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('Expense.toMap / fromMap', () {
    test('toMap doğru alanları üretir', () {
      final expense = Expense(
        id: 'test-id',
        userId: 'user-1',
        categoryName: 'Yemek',
        description: 'Öğle yemeği',
        location: 'Ofis',
        date: DateTime(2026, 8, 24),
        amount: 285.0,
        currency: 'TRY',
      );

      final map = expense.toMap();

      expect(map['userId'], 'user-1');
      expect(map['categoryName'], 'Yemek');
      expect(map['amount'], 285.0);
      expect(map['currency'], 'TRY');
      expect(map.containsKey('id'), false); // id Map içine hiç girmemeli
    });

    test('fromMap, toMap ile üretilen veriyi doğru geri okur', () {
      final original = Expense(
        id: 'test-id',
        userId: 'user-1',
        categoryName: 'Market',
        description: 'Haftalık alışveriş',
        location: 'Migros',
        date: DateTime(2026, 8, 23),
        amount: 1240.50,
        currency: 'USD',
        exchangeRate: 41.20,
        originalAmount: 30.11,
      );

      final map = original.toMap();
      final restored = Expense.fromMap('test-id', map);

      expect(restored.userId, original.userId);
      expect(restored.categoryName, original.categoryName);
      expect(restored.amount, original.amount);
      expect(restored.currency, original.currency);
      expect(restored.exchangeRate, original.exchangeRate);
      expect(restored.originalAmount, original.originalAmount);
      expect(restored.date, original.date);
    });

    test('currency alanı eksikse fromMap varsayılan olarak TRY döner', () {
      final map = {
        'userId': 'user-1',
        'categoryName': 'Fatura',
        'description': 'Elektrik',
        'location': '',
        'date': original_date(),
        'amount': 500.0,
        // currency alanı kasıtlı olarak eksik bırakıldı
      };

      final expense = Expense.fromMap('old-doc', map);

      expect(expense.currency, 'TRY');
      expect(expense.exchangeRate, null);
    });
  });
}
Timestamp original_date() => Timestamp.fromDate(DateTime(2026, 8, 21));