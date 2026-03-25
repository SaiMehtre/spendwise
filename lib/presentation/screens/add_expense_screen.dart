import 'package:flutter/material.dart';
import '../../data/services/expense_service.dart';

class AddExpenseScreen extends StatefulWidget {
  final Map<String, dynamic>? expense;
  final int? index; // 🔥 ADD THIS

  const AddExpenseScreen({super.key, this.expense, this.index});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}


class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String selectedCategory = "Food";

  final List<String> categories = [
    "Food",
    "Travel",
    "Shopping",
    "Bills",
    "Others"
  ];

  // void saveExpense() {
  //   // Abhi print only (Hive baad me)
  //   print("Amount: ${_amountController.text}");
  //   print("Category: $selectedCategory");
  //   print("Note: ${_noteController.text}");

  //   Navigator.pop(context);
  // }

  @override
  void initState() {
    super.initState();

    if (widget.expense != null) {
      _amountController.text = widget.expense!['amount'].toString(); // 🔥 FIX
      _noteController.text = widget.expense!['note']; // 🔥 FIX
      selectedCategory = widget.expense!['category'];
    }
  }

  void saveExpense() {
    final service = ExpenseService();

    final data = {
      "amount": double.tryParse(_amountController.text) ?? 0,
      "category": selectedCategory,
      "note": _noteController.text,
      "date": DateTime.now().toString(),
    };

    if (widget.index == null) {
      service.addExpense(data); // ➕ new
    } else {
      service.updateExpense(widget.index!, data); // ✏️ update
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Expense"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Amount Field
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Amount",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Category Dropdown
            DropdownButtonFormField(
              value: selectedCategory,
              items: categories
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Note Field
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: "Note",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Save Button
            ElevatedButton(
              onPressed: saveExpense,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              ),
              child: const Text("Save"),
            )
          ],
        ),
      ),
    );
  }
}