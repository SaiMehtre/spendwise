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

  double getTotalExpense() {
    double total = 0;

    for (var item in expenses) {
      total += item['amount'];
    }

    return total;
  }

  Color getCategoryColor(String category) {
    switch (category) {
      case "Food":
        return Colors.orange;
      case "Travel":
        return Colors.blue;
      case "Shopping":
        return Colors.purple;
      case "Bills":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Today Spend
  double getTodayExpense() {
    final now = DateTime.now();

    return expenses.where((e) {
      final date = DateTime.parse(e['date']);
      return date.day == now.day &&
          date.month == now.month &&
          date.year == now.year;
    }).fold(0, (sum, e) => sum + e['amount']);
  }

  // Weekly spend
  double getWeeklyExpense() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    return expenses.where((e) {
      final date = DateTime.parse(e['date']);
      return date.isAfter(weekStart);
    }).fold(0, (sum, e) => sum + e['amount']);
  }
  // Monthly Spend
  double getMonthlyExpense() {
    final now = DateTime.now();

    return expenses.where((e) {
      final date = DateTime.parse(e['date']);
      return date.month == now.month && date.year == now.year;
    }).fold(0, (sum, e) => sum + e['amount']);
  }

  // Yearly Spend
  double getYearlyExpense() {
    final now = DateTime.now();

    return expenses.where((e) {
      final date = DateTime.parse(e['date']);
      return date.year == now.year;
    }).fold(0, (sum, e) => sum + e['amount']);
  }

  // Dashboard Cards

  Widget buildDashboardCards() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
        children: [
          buildCard("Today", getTodayExpense()),
          buildCard("Week", getWeeklyExpense()),
          buildCard("Month", getMonthlyExpense()),
          buildCard("Year", getYearlyExpense()),
        ],
      ),
    );
  }

  Widget buildCard(String title, double amount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const Spacer(),
          Text(
            "₹${amount.toStringAsFixed(0)}",
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: const Text("SpendWise"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          children: const [
            DrawerHeader(child: Text("Menu")),
            ListTile(title: Text("Dashboard")),
            ListTile(title: Text("Analytics")),
            ListTile(title: Text("Settings")),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Add Expense",
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddExpenseScreen(),
            ),
          );
          loadExpenses();
        },
        backgroundColor: const Color(0xFF6A11CB),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFEEF2F3), Color(0xFFDDE6ED)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
          const SizedBox(height: 20),

          // Total Card (we'll update next)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total Spend",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "This Month",
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Text(
                  "₹${getTotalExpense().toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
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

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: getCategoryColor(item['category']).withOpacity(0.2),
                              child: Text(
                                item['category'][0],
                                style: TextStyle(
                                  color: getCategoryColor(item['category']),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['category'],
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    item['note'],
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),

                            Text(
                              "₹${item['amount']}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            )
                          ],
                        ),
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