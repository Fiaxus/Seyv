// Expense modelini, TransactionTile'ın beklediği görüntüleme modeline
// (kategori ikonu ve rengiyle birlikte) çevirir.
import 'package:flutter/material.dart';

import 'package:harcama_takip_uygulamasi/core/models/transaction_data.dart';
import 'package:harcama_takip_uygulamasi/core/utils/category_style.dart';
import 'expense.dart';

extension ExpenseTransactionData on Expense {
  TransactionData toTransactionData(BuildContext context) {
    final style = CategoryStyles.of(categoryName);
    return TransactionData(
      icon: style.icon,
      categoryName: categoryName,
      description: description,
      location: location,
      date: date,
      amount: amount,
      accentColor: style.color(context),
      originalCurrency: currency,
      originalAmount: originalAmount,
    );
  }
}
