import 'package:flutter/material.dart';
import 'dart:async';
import '../../data/services/expense_service.dart';
import '../widgets/expense_card.dart';
import '../../data/models/expense_model.dart';
import 'add_expense_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../widgets/search_filter_bar.dart';
import '../../core/utils/category_utils.dart';

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

  DateTime? startDate;
  DateTime? endDate;  

  Timer? _debounce; 

  DateTime normalize(DateTime d) {
    return DateTime(d.year, d.month, d.day);
  }

  String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy • hh:mm a').format(date);
  }


  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = CategoryUtils.getColor(selectedCategory);
    final icon = CategoryUtils.getIcon(selectedCategory);
    
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
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            const SizedBox(height: 8),
           
            SearchFilterBar(
                            
              onSearch: (value) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();

                _debounce = Timer(const Duration(milliseconds: 300), () {
                  setState(() {
                    searchQuery = value;
                  });
                });
              },
              selectedCategory: selectedCategory,
              selectedMonth: selectedMonth,

              onCategoryChanged: (val) {
                setState(() => selectedCategory = val);
              },

              onMonthChanged: (val) {
                setState(() => selectedMonth = val);
              },

              onClear: () {
                setState(() {
                  searchQuery = '';
                  selectedCategory = 'All';
                  selectedMonth = null;
                  startDate = null;
                  endDate = null;
                });
              },
              
              startDate: startDate,
              endDate: endDate,

              onStartDateChanged: (val) {
                setState(() => startDate = val);
              },

              onEndDateChanged: (val) {
                setState(() => endDate = val);
              },
            ),

            const SizedBox(height: 8),

            if (selectedCategory != 'All' || selectedMonth != null || startDate != null)
              Padding(                               
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  children: [

                    /// 🔵 CATEGORY CHIP
                    if (selectedCategory != 'All')
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                        child: Chip(
                          key: ValueKey(selectedCategory), // 🔥 IMPORTANT
                          avatar: Icon(icon, color: Colors.white, size: 18),
                          label: Text(
                            selectedCategory,
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: color.withOpacity(0.9),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          deleteIcon: const Icon(Icons.close, color: Colors.white),
                          onDeleted: () {
                            setState(() => selectedCategory = 'All');
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),

                    /// 🟣 MONTH CHIP
                    if (selectedMonth != null)
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                        child: Chip(
                          key: ValueKey(selectedMonth), // 🔥 IMPORTANT
                          avatar: const Icon(Icons.calendar_month, color: Colors.white, size: 18),
                          label: Text(
                            DateFormat.MMM().format(selectedMonth!),
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.purple,
                          deleteIcon: const Icon(Icons.close, color: Colors.white),
                          onDeleted: () {
                            setState(() => selectedMonth = null);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),

                    /// 🟢 DATE RANGE CHIP
                    if (startDate != null)
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                        child: Chip(
                          key: ValueKey(startDate.toString() + endDate.toString()), // 🔥 IMPORTANT
                          avatar: const Icon(Icons.date_range, color: Colors.white, size: 18),
                          label: Text(
                            (endDate == null || startDate == endDate)
                                ? DateFormat('dd MMM').format(startDate!)
                                : "${DateFormat('dd MMM').format(startDate!)} - ${DateFormat('dd MMM').format(endDate!)}",
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.green,
                          deleteIcon: const Icon(Icons.close, color: Colors.white),
                          onDeleted: () {
                            setState(() {
                              startDate = null;
                              endDate = null;
                            });
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                  ],
                )
              ),

            const SizedBox(height: 8),

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

                  final query = searchQuery.toLowerCase();

                    final matchesSearch =
                      e.note.toLowerCase().contains(query) ||
                      e.category.toLowerCase().contains(query);

                    final matchesCategory =
                        selectedCategory == 'All' ||
                        e.category.toLowerCase() == selectedCategory.toLowerCase();

                    final expenseDate = normalize(e.date);

                    final start = startDate != null ? normalize(startDate!) : null;
                    final end = endDate != null ? normalize(endDate!) : null;

                    final month = selectedMonth;

                    final matchesMonth =
                        (start != null || end != null)
                            ? true
                            : (month == null ||
                                (expenseDate.year == month.year &&
                                expenseDate.month == month.month));

                    // final expenseDate = normalize(e.date);

                    final matchesRange =
                      (start == null && end == null) ||

                      // Only start selected (single date)
                      (start != null && end == null && expenseDate == start) ||

                      // Only end selected (rare case)
                      (start == null && end != null && expenseDate == end) ||

                      // Range selected
                      (start != null && end != null &&
                          !expenseDate.isBefore(start) &&
                          !expenseDate.isAfter(end));

                      return matchesSearch &&
                              matchesCategory &&
                              matchesMonth &&
                              matchesRange;
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

                  if (filteredExpenses.isEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.search_off, size: 60, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          "No matching results",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    );
                  }


                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: filteredExpenses.length,
                    itemBuilder: (context, index) {
                      final item = filteredExpenses[index];

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