import 'package:flutter/material.dart';
import 'add_expense_screen.dart';
import '../../data/services/expense_service.dart';
import 'analytics_screen.dart';

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
    final width = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.count(
        crossAxisCount: width < 300 ? 1 : 2, // 🔥 ultra small fix
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: width < 360 ? 1.1 : 1.4, // 🔥 height adjust
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
    final width = MediaQuery.of(context).size.width;

    final isSmall = width < 360; // 🔥 breakpoint

    return Container(
      padding: EdgeInsets.all(isSmall ? 8 : 14), // 🔥 responsive padding
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1, // ✅ overflow fix
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white70,
              fontSize: isSmall ? 11 : 14, // 🔥 responsive font
            ),
          ),

          const Spacer(),

          FittedBox( // 🔥 BIGGEST FIX
            child: Text(
              "₹${amount.toStringAsFixed(0)}",
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmall ? 14 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
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

        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart), // 📊 analytics icon
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AnalyticsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      
      // drawer: Drawer(
      //   child: ListView(
      //     children: const [
      //       DrawerHeader(child: Text("Menu")),
      //       ListTile(title: Text("Dashboard")),
      //       ListTile(title: Text("Analytics")),
      //       ListTile(title: Text("Settings")),
      //     ],
      //   ),
      // ),
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
  child: SingleChildScrollView(   // ✅ MAIN FIX
    child: Column(
      children: [
        const SizedBox(height: 20),

        buildDashboardCards(),

        const SizedBox(height: 10),

        expenses.isEmpty
            ? const Center(child: Text("No Expenses Yet"))
            : ListView.builder(
                shrinkWrap: true,   // ✅ IMPORTANT
                physics: const NeverScrollableScrollPhysics(), // ✅ IMPORTANT
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  final item = expenses[index];

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: getCategoryColor(item['category']).withOpacity(0.2),
                          child: Text(item['category'][0]),
                        ),
                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['category']),
                              Text(item['note']),
                            ],
                          ),
                        ),

                        Text("₹${item['amount']}"),
                      ],
                    ),
                  );
                },
              ),
      ],
    ),
  ),
)
    );
  }
}