import 'package:hive/hive.dart';

class ExpenseService {
  final Box box = Hive.box('expenses');

  void addExpense(Map<String, dynamic> expense) {
    box.add(expense);
  }

  List<Map<String, dynamic>> getExpenses() {
    return box.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }
}