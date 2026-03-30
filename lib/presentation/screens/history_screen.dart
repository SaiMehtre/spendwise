import 'package:flutter/material.dart';
import '../../data/services/expense_service.dart';
import '../../core/utils/category_utils.dart';
import '../widgets/expense_card.dart';
import '../../data/models/expense_model.dart';
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

  String searchQuery = '';
  String selectedCategory = 'All';
  DateTime? selectedMonth;

  String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy • hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 8),

            TextButton(
              onPressed: () {
                setState(() {
                  searchQuery = '';
                  selectedCategory = 'All';
                  selectedMonth = null;
                });
              },
              child: const Text("Clear Filters"),
            ),

            TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search expenses...",
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),

            DropdownButton<String>(
              value: selectedCategory,
              dropdownColor: Colors.black,
              isExpanded: true,
              items: ['All', 'Food', 'Travel', 'Shopping', 'Bills', 'Other']
                  .map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(cat, style: const TextStyle(color: Colors.white)),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );

                if (picked != null) {
                  setState(() {
                    selectedMonth = picked;
                  });
                }
              },
              child: const Text("Filter by Month"),
            ),

            Expanded(
              child: ValueListenableBuilder(
                valueListenable: service.box.listenable(),
                builder: (context, box, _) {
                  
                  final expenses = box.keys.map((key) {
                    final map = Map<String, dynamic>.from(box.get(key));
                    return Expense.fromMap(map, key);
                  }).toList()
                    ..sort((a, b) => b.date.compareTo(a.date));

                  final filteredExpenses = expenses.where((e) {
                    final matchesSearch =
                        e.note.toLowerCase().contains(searchQuery) ||
                        e.category.toLowerCase().contains(searchQuery);

                    final matchesCategory =
                        selectedCategory == 'All' || e.category == selectedCategory;

                    final matchesMonth = selectedMonth == null ||
                        (e.date.month == selectedMonth!.month &&
                        e.date.year == selectedMonth!.year);

                    return matchesSearch && matchesCategory && matchesMonth;
                  }).toList();

                  if (expenses.isEmpty) {
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

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final item = expenses[index];

                      return Dismissible(
                        key: ValueKey(item.id),
                        direction: DismissDirection.horizontal,

                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            return await showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Delete?"),
                                content: const Text(
                                  "Are you sure you want to delete this expense?",
                                ),
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
                                  expense: item,
                                  keyValue: item.id,
                                ),
                              ),
                            );

                            if (result != null && result['success'] == true) {
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

                            return false;
                          }
                        },

                        onDismissed: (direction) {
                            // 1️⃣ Backup the deleted item and its key
                            final deletedItem = item.toMap();
                            final deletedKey = item.id;

                            // 2️⃣ Delete the expense
                            service.deleteExpense(deletedKey);

                            // 3️⃣ Post-frame callback to show SnackBar safely
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              final messenger = ScaffoldMessenger.of(context);

                              // Clear any existing SnackBars
                              messenger.clearSnackBars();

                              // 4️⃣ Declare controller before use
                              late ScaffoldFeatureController<SnackBar, SnackBarClosedReason> controller;

                              // 5️⃣ Show SnackBar with UNDO
                              controller = messenger.showSnackBar(
                                SnackBar(
                                  duration: const Duration(seconds: 3),
                                  behavior: SnackBarBehavior.floating,
                                  margin: const EdgeInsets.all(12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  backgroundColor: Colors.orange,
                                  content: const Text(
                                    "Expense deleted",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  action: SnackBarAction(
                                    label: "UNDO",
                                    textColor: Colors.white,
                                    onPressed: () {
                                      // 6️⃣ Restore the expense safely
                                      final newItem = Map<String, dynamic>.from(deletedItem);
                                      newItem.remove('key');
                                      service.addExpenseWithKey(deletedKey, newItem);

                                      // 7️⃣ Close this SnackBar safely
                                      try {
                                        controller.close();
                                      } catch (_) {
                                        // ignore if already dismissed
                                      }

                                      // Optional: Show a restored SnackBar
                                      late ScaffoldFeatureController<SnackBar, SnackBarClosedReason> restoredController;
                                      restoredController = messenger.showSnackBar(
                                        SnackBar(
                                          duration: const Duration(seconds: 2),
                                          behavior: SnackBarBehavior.floating,
                                          margin: const EdgeInsets.all(12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          backgroundColor: Colors.green,
                                          content: const Text(
                                            "Expense restored successfully",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      );

                                      Future.delayed(const Duration(seconds: 2), () {
                                        try {
                                          restoredController.close();
                                        } catch (_) {}
                                      });
                                    },
                                  ),
                                ),
                              );

                              // 8️⃣ Auto-dismiss delete SnackBar after 3 sec
                              Future.delayed(const Duration(seconds: 3), () {
                                try {
                                  controller.close();
                                } catch (_) {
                                  // ignore if already dismissed
                                }
                              });
                            });
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

                        child: ExpenseCard(item: item),
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