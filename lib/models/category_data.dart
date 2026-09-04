import 'package:flutter/material.dart';

class CategoryData {
  final IconData icon;
  final String categoryName;
  final String amount;
  final Color accentColor;

  const CategoryData({
    required this.icon,
    required this.categoryName,
    required this.amount,
    required this.accentColor,
  });
}