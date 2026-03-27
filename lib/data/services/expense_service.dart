import 'package:hive/hive.dart';

class ExpenseService {
  final Box box = Hive.box('expenses');

  void addExpense(Map<String, dynamic> expense) {
    box.add(expense);
  }

  void deleteExpense(dynamic key) {
    box.delete(key); // ✅ CORRECT
  }

  void updateExpense(dynamic key, Map<String, dynamic> data) {
    box.put(key, data); // ✅ correct
  }

  void addExpenseWithKey(dynamic key, Map<String, dynamic> data) {
    box.put(key, data);
  }

  List<Map<String, dynamic>> getExpenses() {
    return box.values
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
}