import 'package:flutter_test/flutter_test.dart';
import 'package:harcama_takip_uygulamasi/utils/category_style.dart';

void main() {
  group('CategoryStyles.of', () {
    test('bilinen bir kategori için doğru rengi döner', () {
      final style = CategoryStyles.of('Market');
      expect(style.color, CategoryStyles.all['Market']!.color);
    });

    test('bilinmeyen bir kategori için "Diğer" stiline düşer', () {
      final style = CategoryStyles.of('Var Olmayan Kategori');
      expect(style.color, CategoryStyles.all['Diğer']!.color);
      expect(style.icon, CategoryStyles.all['Diğer']!.icon);
    });
  });
}