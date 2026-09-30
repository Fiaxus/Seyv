import 'package:flutter/material.dart';

class CategoryData {
  final IconData icon;
  final String categoryName;
  final double amount;
  final Color accentColor;

  /// Bu kategorinin aylık limiti. null = limit yok.
  final double? limit;

  const CategoryData({
    required this.icon,
    required this.categoryName,
    required this.amount,
    required this.accentColor,
    this.limit,
  });
}