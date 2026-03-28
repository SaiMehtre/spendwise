import 'package:flutter/material.dart';
import '../../data/services/expense_service.dart';
import '../../core/utils/category_utils.dart';
import 'home_screen.dart';
import 'add_expense_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final service = ExpenseService();

  String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy • hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      // appBar: AppBar(
        
      // ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blueGrey.shade900.withOpacity(0.85),
              Colors.blueGrey.shade800.withOpacity(0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 8),
            // 🔥 Expenses list
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: service.box.listenable(),
                builder: (context, Box box, _) {

                  if (box.isEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.receipt_long, size: 60, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          "No Expenses Yet",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    );
                  }                  

                  final expenses = box.keys.map((key) {
                    final item = Map<String, dynamic>.from(box.get(key));
                    item['key'] = key;
                    item['parsedDate'] = DateTime.parse(item['date']); //
                    return item;
                  }).toList()
                    ..sort((a, b) => b['parsedDate'].compareTo(a['parsedDate']));                    

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final item = expenses[index];

                      return Dismissible(
                        key: ValueKey(item['key']),
                        direction: DismissDirection.horizontal,

                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            return await showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Delete?"),
                                content: const Text(
                                    "Are you sure you want to delete this expense?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text("Delete"),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddExpenseScreen(
                                expense: item,              // 🔥 PASS DATA
                                keyValue: item['key'],      // 🔥 PASS KEY
                              ),
                              ),
                            );

                            if (result != null && result['success'] == true) {
                              if (!mounted) return false;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    result['isUpdate']
                                        ? "Expense Updated Successfully"
                                        : "Expense Added Successfully",
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                            return false; // 🔥 important
                          }
                        },

                        onDismissed: (direction) {
                          final deletedItem = item;

                          service.box.delete(item['key']);

                          final messenger = ScaffoldMessenger.of(context);
                          messenger.clearSnackBars();

                          messenger.showSnackBar(
                            SnackBar(
                              duration: const Duration(seconds: 3),
                                backgroundColor: Colors.orange,
                                behavior: SnackBarBehavior.floating,
                                margin: const EdgeInsets.all(12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                content: const Text(
                                  "Expense deleted",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              action: SnackBarAction(
                                label: "UNDO",
                                onPressed: () {
                                  final newItem =
                                      Map<String, dynamic>.from(deletedItem);
                                  newItem.remove('key');

                                  service.addExpenseWithKey(deletedItem['key'], newItem);
                                },
                              ),
                            ),
                          );
                        },

                        background: Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 20),
                          child: Row(
                            children: const [
                              Icon(Icons.delete, color: Colors.white),
                              SizedBox(width: 8),
                              Text("Delete",
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),

                        secondaryBackground: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: const [
                              Text("Edit",
                                  style: TextStyle(color: Colors.white)),
                              SizedBox(width: 8),
                              Icon(Icons.edit, color: Colors.white),
                            ],
                          ),
                        ),

                        child: ExpenseCard(
                          item: item,
                          color: getCategoryColor(item['category']),
                          formatDate: (_) => formatDate(item['parsedDate']),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}