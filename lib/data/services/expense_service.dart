import 'package:hive/hive.dart';

class ExpenseService {
  final Box box = Hive.box('expenses');

  void addExpense(Map<String, dynamic> expense) {
    box.add(expense);
  }

  void deleteExpense(int index) {
    box.deleteAt(index); // 🔥 FIX
  }

  void updateExpense(int index, Map<String, dynamic> newData) {
    box.putAt(index, newData); // 🔥 FIX
  }

  List<Map<String, dynamic>> getExpenses() {
    return box.values
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
}