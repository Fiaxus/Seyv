import 'package:flutter/material.dart';

class CategoryStyle {
  final IconData icon;
  final Color lightColor;
  final Color darkColor;

  const CategoryStyle({
    required this.icon,
    required this.lightColor,
    required this.darkColor,
  });

  Color color(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkColor
        : lightColor;
  }
}

class CategoryStyles {
  static const Map<String, CategoryStyle> all = {
    'Yemek': CategoryStyle(
      icon: Icons.restaurant_outlined,
      lightColor: Color(0xFFF08343),
      darkColor: Color(0xFFF9A470),
    ),
    'Market': CategoryStyle(
      icon: Icons.shopping_cart_outlined,
      lightColor: Color(0xFF35B678),
      darkColor: Color(0xFF63D69B),
    ),
    'Ulaşım': CategoryStyle(
      icon: Icons.directions_bus_outlined,
      lightColor: Color(0xFF4B92E6),
      darkColor: Color(0xFF7FB3F2),
    ),
    'Fatura': CategoryStyle(
      icon: Icons.receipt_long_outlined,
      lightColor: Color(0xFFA579E8),
      darkColor: Color(0xFFC3A0F5),
    ),
    'Alışveriş': CategoryStyle(
      icon: Icons.shopping_bag_outlined,
      lightColor: Color(0xFFF0725F),
      darkColor: Color(0xFFFB9686),
    ),
    'Eğlence': CategoryStyle(
      icon: Icons.theater_comedy_outlined,
      lightColor: Color(0xFFE070AE),
      darkColor: Color(0xFFF096C7),
    ),
    'Sağlık': CategoryStyle(
      icon: Icons.favorite_border,
      lightColor: Color(0xFF35B4C4),
      darkColor: Color(0xFF6FD6E2),
    ),
    'Eğitim': CategoryStyle(
      icon: Icons.school_outlined,
      lightColor: Color(0xFFC0A62F),
      darkColor: Color(0xFFDCC65C),
    ),
    'Diğer': CategoryStyle(
      icon: Icons.more_horiz,
      lightColor: Color(0xFF7C8F94),
      darkColor: Color(0xFFAFBFC3),
    ),
  };

  static CategoryStyle of(String categoryName) {
    return all[categoryName] ?? all['Diğer']!;
  }
}