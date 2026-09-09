import 'package:flutter/material.dart';

class TransactionData {
  final IconData icon;
  final String categoryName;
  final String description;
  final DateTime date;
  final String location;
  final double amount;
  final Color accentColor;

  const TransactionData({
    required this.icon,
    required this.categoryName,
    required this.description,
    required this.date,
    required this.location,
    required this.amount,
    required this.accentColor,
  });
}