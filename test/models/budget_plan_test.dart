import 'package:flutter_test/flutter_test.dart';
import 'package:harcama_takip_uygulamasi/models/budget_plan.dart';

void main() {
  group('BudgetPlan', () {
    const plan = BudgetPlan(
      monthly: 10000,
      categoryLimits: {'Yemek': 3000, 'Market': 4000},
    );

    test('allocated ve unallocated doğru hesaplanır', () {
      expect(plan.allocated, 7000);
      expect(plan.unallocated, 3000);
    });

    test('maxFor, kategorinin kendi mevcut değerini hesaba katmaz', () {
      expect(plan.maxFor('Yemek'), 6000);
      expect(plan.maxFor('Ulaşım'), 3000);
    });

    test('limit toplamı aylık bütçeyi aşarsa plan geçersizdir', () {
      final invalid = plan.copyWith(monthly: 5000);
      expect(invalid.isValid, isFalse);
      expect(plan.isValid, isTrue);
    });

    test('toplam tam olarak aylık bütçeye eşitse plan geçerlidir', () {
      final full = plan.withLimit('Ulaşım', 3000);
      expect(full.unallocated, 0);
      expect(full.isValid, isTrue);
    });

    test('withLimit 0 verilince kategori limiti kaldırılır', () {
      final updated = plan.withLimit('Market', 0);
      expect(updated.limitFor('Market'), isNull);
      expect(updated.limitedCategoryCount, 1);
    });

    test('fromMap eksik veya hatalı veride güvenli çalışır', () {
      expect(BudgetPlan.fromMap(null), BudgetPlan.empty);

      final parsed = BudgetPlan.fromMap({
        'monthlyBudget': 20000,
        'categoryBudgets': {'Yemek': 3000, 'Market': 0, 'Fatura': 'hata'},
      });
      expect(parsed.monthly, 20000);
      expect(parsed.categoryLimits, {'Yemek': 3000.0});
    });

    test('içeriği aynı olan planlar eşittir', () {
      const same = BudgetPlan(
        monthly: 10000,
        categoryLimits: {'Market': 4000, 'Yemek': 3000},
      );
      expect(plan == same, isTrue);
      expect(plan == plan.withLimit('Yemek', 3100), isFalse);
    });
  });
}