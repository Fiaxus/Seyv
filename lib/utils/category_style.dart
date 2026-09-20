import 'package:flutter/material.dart';

class CategoryStyle {
  final IconData icon;
  final Color color;

  const CategoryStyle({required this.icon, required this.color});
}

class CategoryStyles {
  static const Map<String, CategoryStyle> all = {
    'Yemek': CategoryStyle(
      icon: Icons.restaurant_outlined,
      color: Color(0xFFE0912F),
    ),
    'Market': CategoryStyle(
      icon: Icons.shopping_cart_outlined,
      color: Color(0xFF08A88A),
    ),
    'Ulaşım': CategoryStyle(
      icon: Icons.directions_bus_outlined,
      color: Color(0xFF4A90D9),
    ),
    'Fatura': CategoryStyle(
      icon: Icons.receipt_long_outlined,
      color: Color(0xFF9B7FE0),
    ),
    'Alışveriş': CategoryStyle(
      icon: Icons.shopping_bag_outlined,
      color: Color(0xFFDC4A38),
    ),
    'Eğlence': CategoryStyle(
      icon: Icons.theater_comedy_outlined,
      color: Color(0xFFD670C4),
    ),
    'Sağlık': CategoryStyle(
      icon: Icons.favorite_border,
      color: Color(0xFF3AA0A0),
    ),
    'Eğitim': CategoryStyle(
      icon: Icons.school_outlined,
      color: Color(0xFFE0B23A),
    ),
    'Diğer': CategoryStyle(
      icon: Icons.more_horiz,
      color: Color(0xFF8A8A8A),
    ),
  };

  static CategoryStyle of(String categoryName) {
    return all[categoryName] ?? all['Diğer']!;
  }
}