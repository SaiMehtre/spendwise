import 'package:flutter/material.dart';
import '../../data/services/expense_service.dart';
import 'dart:ui';

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
      extendBodyBehindAppBar: true, // for transparent appBar effect
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.1),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Add Expense",
          style: TextStyle(color: Colors.white),
        ),
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
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
        // padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Amount Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: "Amount",
                        labelStyle: TextStyle(color: Colors.white70),
                        floatingLabelStyle: TextStyle(color: Colors.white),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Category Dropdown
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: selectedCategory,
                      items: categories
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value!;
                        });
                      },
                      dropdownColor: Colors.blueGrey.shade900,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Note Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: TextField(
                      controller: _noteController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: "Note",
                        labelStyle: TextStyle(color: Colors.white70),
                        floatingLabelStyle: TextStyle(color: Colors.white),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Save Button
                  ElevatedButton(
                    onPressed: saveExpense,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 14),
                      backgroundColor: const Color(0xFF6A11CB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      shadowColor: Colors.deepPurpleAccent.withOpacity(0.6),
                      elevation: 8,
                    ),
                    child: const Text(
                      "Save",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}