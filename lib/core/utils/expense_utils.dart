import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/expense_model.dart';

class ExpenseUtils {
  static List<Expense> getExpenses(Box box) {
    return box.keys.map((key) {
      return Expense.fromMap(
        Map<String, dynamic>.from(box.get(key)),
        key,
      );
    }).toList();
  }

  static List<Expense> getSortedExpenses(Box box) {
    final list = getExpenses(box);

    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }
}