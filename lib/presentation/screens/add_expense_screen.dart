import 'package:flutter/material.dart';
import '../../data/services/expense_service.dart';
import 'dart:ui';

class AddExpenseScreen extends StatefulWidget {
  final Map<String, dynamic>? expense;
  final int? index;

  const AddExpenseScreen({super.key, this.expense, this.index});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String? selectedCategory;
  final List<String> categories = ["Food", "Travel", "Shopping", "Bills", "Others"];

  // ✅ Form key for validation
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _amountController.text = widget.expense!['amount'].toString();
      _noteController.text = widget.expense!['note'];
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
      service.addExpense(data);
    } else {
      service.updateExpense(widget.index!, data);
    }
    Navigator.pop(context, true); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
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
        padding: EdgeInsets.fromLTRB(
          20,
          kToolbarHeight + MediaQuery.of(context).padding.top + 10, // 🔥 dynamic top
          20,
          20,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
              ),
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Amount Field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: "Amount",
                          labelStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                          floatingLabelStyle: TextStyle(color: Colors.white),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              double.tryParse(value) == null ||
                              double.parse(value) <= 0) {
                            return "Enter a valid amount";
                          }
                          return null;
                        },
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
                        hint: const Text(
                          "Select Category",
                          style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold), // premium subtle hint
                        ),
                        items: categories
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e, style: const TextStyle(color: Colors.white)),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value!;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Select a category";
                          }
                          return null;
                        },
                        dropdownColor: Colors.blueGrey.shade900,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Note Field (optional)
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
                          labelStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                          floatingLabelStyle: TextStyle(color: Colors.white),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Save Button
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          saveExpense();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
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
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}