import 'package:flutter/material.dart';
import 'add_expense_screen.dart';
import '../../data/services/expense_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final service = ExpenseService();
  List<Map<String, dynamic>> expenses = [];

  @override
  void initState() {
    super.initState();
    loadExpenses();
  }

  void loadExpenses() {
    setState(() {
      expenses = service.getExpenses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expense Tracker"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddExpenseScreen(),
            ),
          );

          // 🔥 Important: refresh after coming back
          loadExpenses();
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          // Total Card (we'll update next)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.blue, Colors.purple],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total spend",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  "₹0",
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
              ],
            ),
          ),

          Expanded(
            child: expenses.isEmpty
                ? const Center(child: Text("No Expenses Yet"))
                : ListView.builder(
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final item = expenses[index];

                      return ListTile(
                        title: Text(item['category']),
                        subtitle: Text(item['note']),
                        trailing: Text("₹${item['amount']}"),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}