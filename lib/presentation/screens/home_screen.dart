import 'package:flutter/material.dart';
import 'add_expense_screen.dart';
import '../../data/services/expense_service.dart';
import 'analytics_screen.dart';
import 'package:intl/intl.dart';
import '../../core/utils/category_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final service = ExpenseService();
  List<Map<String, dynamic>> expenses = [];
  int selectedIndex = 0;

  // final List<Widget> screens = [
  //   const HomeContent(),     // 👈 dashboard + list wala UI
  //   AnalyticsScreen(),       // 👈 tera existing screen
  // ];

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

  // Color getCategoryColor(String category) {
  //   switch (category) {
  //     case "Food":
  //       return Colors.orange;
  //     case "Travel":
  //       return Colors.blue;
  //     case "Shopping":
  //       return Colors.purple;
  //     case "Bills":
  //       return Colors.red;
  //     default:
  //       return Colors.grey;
  //   }
  // }

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

  // Date format 

  String formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return DateFormat('dd MMM, hh:mm a').format(date);
  }

  // To EXpand Note Card

  Widget buildExpenseCard(Map<String, dynamic> item) {
    return ExpenseCard(
      item: item,
      color: getCategoryColor(item['category']),
      formatDate: formatDate,
    );
  }

  // Dashboard Cards

  // Widget buildDashboardCards() {
  //   final width = MediaQuery.of(context).size.width;

  //   return Padding(
  //     padding: const EdgeInsets.all(12),
  //     child: GridView.count(
  //       crossAxisCount: width < 300 ? 1 : 2, // 🔥 ultra small fix
  //       shrinkWrap: true,
  //       physics: const NeverScrollableScrollPhysics(),
  //       crossAxisSpacing: 8,
  //       mainAxisSpacing: 8,
  //       childAspectRatio: width < 360 ? 1.4 : 1.8, // 🔥 height adjust
  //       children: [
  //         buildCard("Today", getTodayExpense(), Colors.blue),
  //         buildCard("Week", getWeeklyExpense(), Colors.green),
  //         buildCard("Month", getMonthlyExpense(), Colors.orange),
  //         buildCard("Year", getYearlyExpense(), Colors.purple),
  //       ],
  //     ),
  //   );
  // }

  Widget buildDashboardCards() {
  return Padding(
    padding: const EdgeInsets.all(12),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: 1.6,
                child: buildCard("Today", getTodayExpense(), Colors.blue),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AspectRatio(
                aspectRatio: 1.6,
                child: buildCard("Week", getWeeklyExpense(), Colors.green),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: 1.6,
                child: buildCard("Month", getMonthlyExpense(), Colors.orange),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AspectRatio(
                aspectRatio: 1.6,
                child: buildCard("Year", getYearlyExpense(), Colors.purple),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

  Widget buildCard(String title, double amount, Color baseColor) {
    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 360;

    return Container(
      padding: EdgeInsets.all(isSmall ? 8 : 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            baseColor.withOpacity(0.8),
            baseColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: baseColor.withOpacity(0.3),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // ✅ vertical center
        crossAxisAlignment: CrossAxisAlignment.center, // ✅ horizontal center
        children: [
          Text(
            title,
            textAlign: TextAlign.center, // optional
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmall ? 14 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 18), // thoda spacing

          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: amount),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Text(
                "₹${value.toStringAsFixed(2)}",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmall ? 14 : 20,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> screens = [
      HomeContent(
        expenses: expenses,
        service: service,
        loadExpenses: loadExpenses,
        buildDashboardCards: buildDashboardCards,
        formatDate: formatDate,
      ),
      AnalyticsScreen(),
    ];
    return Scaffold(
      extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      
      appBar: AppBar(
        // title: const Text("SpendWise"),
        title: Text(
          selectedIndex == 0 ? "SpendWise" : "Analytics",
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,

        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.bar_chart), // 📊 analytics icon
        //     onPressed: () {
        //       setState(() {
        //         selectedIndex = 1;
        //       });
        //     },
        //   ),
        // ],
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
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const AddExpenseScreen(),
              transitionsBuilder: (_, animation, __, child) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
            ),
          );
          loadExpenses(); // 👈 refresh after adding
        },
        backgroundColor: const Color(0xFF6A11CB),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),

      bottomNavigationBar: BottomAppBar(
        // color: Colors.white70,
        // elevation: 10,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(
                  Icons.home,
                  color: selectedIndex == 0 ? Colors.deepPurple : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    selectedIndex = 0;
                  });
                },
              ),

              const SizedBox(width: 40), // space for FAB
              // analytics page open 
              IconButton(
                icon: Icon(
                  Icons.bar_chart,
                  color: selectedIndex == 1 ? Colors.deepPurple : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    selectedIndex = 1; 
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class HomeContent extends StatelessWidget {
  final List<Map<String, dynamic>> expenses;
  final ExpenseService service;
  final VoidCallback loadExpenses;
  final Function() buildDashboardCards;
  final String Function(String) formatDate;

  const HomeContent({
    super.key,
    required this.expenses,
    required this.service,
    required this.loadExpenses,
    required this.buildDashboardCards,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEEF2F3), Color(0xFFDDE6ED)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),  // ✅ MAIN FIX
          child: Column(
            children: [
              const SizedBox(height: 8),

              buildDashboardCards(),

              const SizedBox(height: 6),

               // 🔥 IMPORTANT PART
              Expanded(
                child: expenses.isEmpty
                    ? const Center(child: Text("No Expenses Yet"))
                    : ListView.builder(
                        itemCount: expenses.length,
                        padding: const EdgeInsets.only(bottom: 80), // small safe space
                        itemBuilder: (context, index) {
                          final item = expenses[index];

                      return Dismissible(
                        // key: UniqueKey(),
                        key: ValueKey(item['date']), // ✅
                        direction: DismissDirection.horizontal,
                        dismissThresholds: const {
                          DismissDirection.startToEnd: 0.4,
                          DismissDirection.endToStart: 0.4,
                        },

                        // 🔥 CONFIRM FIRST
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            // 🗑 DELETE CONFIRM
                            return await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Delete?"),
                                content: const Text("Are you sure you want to delete this expense?"),
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
                            // ✏️ EDIT (NO DISMISS)
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddExpenseScreen(
                                  expense: item,
                                  index: index,
                                ),
                              ),
                            );
                            loadExpenses();
                            return false; // ❌ don't dismiss
                          }
                        },

                        // 🔥 ACTUAL DELETE HERE ONLY
                        onDismissed: (direction) {
                          final deletedItem = item;

                          service.deleteExpense(index);

                          loadExpenses(); // 👈 parent refresh karega

                          final messenger = ScaffoldMessenger.of(context);

                          messenger.clearSnackBars();

                          final snackBar = SnackBar(
                            duration: const Duration(seconds: 3),
                            backgroundColor: Colors.orange,
                            behavior: SnackBarBehavior.floating,
                            margin: EdgeInsets.all(12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            content: const Text("Expense deleted",style: TextStyle(color: Colors.white)),
                            action: SnackBarAction(
                              label: "UNDO",
                              textColor: Colors.white,
                              onPressed: () {
                                service.addExpense(deletedItem);

                                loadExpenses();

                                messenger.hideCurrentSnackBar(); // 👈 close on click
                              },
                            ),
                          );

                          messenger.showSnackBar(snackBar);

                          // 🔥 FORCE AUTO DISMISS AFTER 3 SEC
                          Future.delayed(const Duration(seconds: 3), () {
                            messenger.hideCurrentSnackBar();
                          });
                        },

                        // 🟥 LEFT → DELETE
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
                              Text("Delete", style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),

                        // 🟦 RIGHT → EDIT
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
                              Text("Edit", style: TextStyle(color: Colors.white)),
                              SizedBox(width: 8),
                              Icon(Icons.edit, color: Colors.white),
                            ],
                          ),
                        ),

                        child: ExpenseCard(
                          key: ValueKey(index),
                          item: item,
                          color: getCategoryColor(item['category']),
                          formatDate: formatDate,
                        ),
                      );
                    }
                    ),
              ),
            ],
          ),
        
    ); // 👈 pura jo body me tha
  }
}


  // Category icons 

  IconData getCategoryIcon(String category) {
    switch (category) {
      case "Food":
        return Icons.restaurant;
      case "Travel":
        return Icons.directions_car;
      case "Shopping":
        return Icons.shopping_bag;
      case "Bills":
        return Icons.receipt;
      default:
        return Icons.category;
    }
  }

class ExpenseCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final Color color;
  final String Function(String) formatDate;

  const ExpenseCard({
    super.key,
    required this.item,
    required this.color,
    required this.formatDate,
  });

  @override
  State<ExpenseCard> createState() => _ExpenseCardState();
}

class _ExpenseCardState extends State<ExpenseCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return GestureDetector(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded; // 🔥 toggle
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: widget.color.withOpacity(0.2),
              child: Icon(
                getCategoryIcon(item['category']),
                color: widget.color,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['category']),

                  // 🔥 ANIMATED NOTE
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 250),
                    crossFadeState: isExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,

                    firstChild: Text(
                      item['note'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),

                    secondChild: Text(
                      item['note'],
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    widget.formatDate(item['date']),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            Text(
              "₹${item['amount'].toStringAsFixed(2)}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      )
    );
  }
}