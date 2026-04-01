import 'package:flutter/material.dart';
import 'add_expense_screen.dart';
import '../../data/services/expense_service.dart';
import 'analytics_screen.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'history_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../widgets/expense_card.dart';
import '../../data/models/expense_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Expense> expenses = [];
  final service = ExpenseService();
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    loadExpenses();
  }

  void loadExpenses() {
    final box = service.box;

    final data = box.keys.map((key) {
      final map = Map<String, dynamic>.from(box.get(key));
      return Expense.fromMap(map, key);
    }).toList();

    data.sort((a, b) => b.date.compareTo(a.date));

    setState(() {
      expenses = data;
    });
  }

  double getTotalExpense() {
    double total = 0;

    for (var item in expenses) {
      total += item.amount;
    }

    return total;
  }

  bool isBetween(DateTime date, DateTime start, DateTime end) {
    return (date.isAtSameMomentAs(start) || date.isAfter(start)) &&
          date.isBefore(end);
  }
  // Date format 

  String formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return DateFormat('dd MMM yyyy • hh:mm a').format(date);
  }

  // To EXpand Note Card

  Widget buildExpenseCard(Expense item) {
    return ExpenseCard(item: item);
  }

  // Dashboard Cards

  Widget buildDashboardCards() {
    return ValueListenableBuilder(
      valueListenable: service.box.listenable(),
      builder: (context, box, _) {

        final expenses = box.keys.map((key) {
          final map = Map<String, dynamic>.from(box.get(key));
          return Expense.fromMap(map, key);
        }).toList()
          ..sort((a, b) => b.date.compareTo(a.date));

        double getTotal(List<Expense> list) {
          return list.fold(0, (sum, e) => sum + e.amount);
        }

        final now = DateTime.now();

        // Today
        final todayStart = DateTime(now.year, now.month, now.day);
        final todayEnd = todayStart.add(const Duration(days: 1));

        // Week
        final weekStart = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: now.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 7));

        // Month
        final monthStart = DateTime(now.year, now.month, 1);
        final monthEnd = DateTime(now.year, now.month + 1, 1);

        // Year
        final yearStart = DateTime(now.year, 1, 1);
        final yearEnd = DateTime(now.year + 1, 1, 1);

        final today = expenses.where((e) {
          final d = e.date;
          return isBetween(d, todayStart, todayEnd);
        }).toList();

        final week = expenses.where((e) {
          final d = e.date;
          return isBetween(d, weekStart, weekEnd);
        }).toList();

        final month = expenses.where((e) {
          final d = e.date;
          return isBetween(d, monthStart, monthEnd);
        }).toList();

        final year = expenses.where((e) {
          final d = e.date;
          return isBetween(d, yearStart, yearEnd);
        }).toList();

        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1.6,
                      child: buildCard("Today", getTotal(today), Colors.blue),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1.6,
                      child: buildCard("Week", getTotal(week), Colors.green),
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
                      child: buildCard("Month", getTotal(month), Colors.orange),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1.6,
                      child: buildCard("Year", getTotal(year), Colors.purple),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildCard(String title, double amount, Color baseColor) {
    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 360;

    final formatter = NumberFormat.currency( 
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );

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
      child: Stack(
        children: [
          // 🔹 Title (Top Left)
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white70,
                fontSize: isSmall ? 14 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // 🔥 Amount (EXACT CENTER)
          Align(
            alignment: Alignment.center,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: amount),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Text(
                  formatter.format(value),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmall ? 14 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> screens = [
      HomeContent(
        key: const ValueKey("home"),
        expenses: expenses,
        service: service,
        loadExpenses: loadExpenses,
        buildDashboardCards: buildDashboardCards,
        formatDate: formatDate,
        onTabChange: (index) {          // ADD THIS
          setState(() => selectedIndex = index);
        },
      ),
      AnalyticsScreen(key: const ValueKey("analytics")),
      HistoryScreen(key: const ValueKey("history")),
    ];

    final Map<int, String> screenTitles = {
      0: "SpendWise",
      1: "Analytics",
      2: "History",
    };
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0f2027),
              Color(0xFF203a43),
              Color(0xFF2c5364),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: screens[selectedIndex],
        ),
      ),
      
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        tooltip: "Add Expense",
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddExpenseScreen(),
            ),
          );

          if (result != null && result['success'] == true) {
            loadExpenses();
            final isUpdate = result['isUpdate'] == true;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isUpdate
                      ? "Expense Updated Successfully"
                      : "Expense Added Successfully",
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        backgroundColor: const Color(0xFF6A11CB),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          // Rounded edges optional
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), // 🔥 blur
            child: AppBar(
              backgroundColor: Colors.white.withOpacity(0.1), // semi-transparent glass
              elevation: 0,
              centerTitle: true,
              title: Text(
                screenTitles[selectedIndex] ?? "App",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),

      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), // match AppBar blur
          child: BottomAppBar(
            color: Colors.white.withOpacity(0.1), // semi-transparent
            shape: const CircularNotchedRectangle(),
            notchMargin: 8,
            child: SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.home,
                      color: selectedIndex == 0 ? Colors.deepPurpleAccent : Colors.grey[400],
                    ),
                    onPressed: () {
                      setState(() => selectedIndex = 0);
                    },
                  ),
                  const SizedBox(width: 40), // space for FAB
                  IconButton(
                    icon: Icon(
                      Icons.bar_chart,
                      color: selectedIndex == 1 ? Colors.deepPurpleAccent : Colors.grey[400],
                    ),
                    onPressed: () {
                      setState(() => selectedIndex = 1);
                    },
                  ),

                  const SizedBox(width: 40),

                  IconButton(
                    icon: Icon(
                      Icons.history,
                      color: selectedIndex == 2
                          ? Colors.deepPurpleAccent
                          : Colors.grey[400],
                    ),
                    onPressed: () {
                      setState(() => selectedIndex = 2);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class HomeContent extends StatefulWidget  {
  final List<Expense> expenses;
  final ExpenseService service;
  final VoidCallback loadExpenses;
  final Function() buildDashboardCards;
  final String Function(String) formatDate;
  final Function(int) onTabChange;

  const HomeContent({
    super.key,
    required this.expenses,
    required this.service,
    required this.loadExpenses,
    required this.buildDashboardCards,
    required this.formatDate,
    required this.onTabChange,
  });

  @override
  State<HomeContent> createState() => _HomeContentState();

}

  class _HomeContentState extends State<HomeContent> {
  final ScrollController _scrollController = ScrollController();
  bool showButton = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.offset > 200 && !showButton) {
        setState(() => showButton = true);
      } else if (_scrollController.offset <= 200 && showButton) {
        setState(() => showButton = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
            children: [
              const SizedBox(height: 8),

              widget.buildDashboardCards(),

              const SizedBox(height: 6),

               // 🔥 IMPORTANT PART
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: widget.service.box.listenable(),
                  builder: (context, box, _) {

                    final expenses = box.keys.map((key) {
                      final map = Map<String, dynamic>.from(box.get(key));
                      return Expense.fromMap(map, key);
                    }).toList()
                      ..sort((a, b) => b.date.compareTo(a.date));
                    

                    if (expenses.isEmpty) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.receipt_long, size: 50, color: Colors.grey),
                          SizedBox(height: 10),
                          Text("No Expenses Yet"),
                        ],
                      );
                    }

                    final recentExpenses = expenses.take(10).toList();

                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: recentExpenses.length + 1,
                      padding: const EdgeInsets.only(bottom: 80),
                      itemBuilder: (context, index) {

                        // 🔥 LAST ITEM = BUTTON
                        if (index == recentExpenses.length) {
                          return AnimatedOpacity(
                            duration: const Duration(milliseconds: 500),
                            opacity: showButton ? 1 : 0,
                            child: AnimatedSlide(
                              duration: const Duration(milliseconds: 400),
                              offset: showButton ? Offset.zero : const Offset(0, 0.3),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
                                child: GestureDetector(
                                  onTap: () {
                                    widget.onTabChange(2);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF6A11CB),
                                          Color(0xFF2575FC),
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.deepPurple.withOpacity(0.4),
                                          blurRadius: 10,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Text(
                                          "View All Expenses",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

                        final item = recentExpenses[index];

                        return Dismissible(
                          key: ValueKey(item.id), // ✅ IMPORTANT

                          direction: DismissDirection.horizontal,
                          dismissThresholds: const {
                            DismissDirection.startToEnd: 0.4,
                            DismissDirection.endToStart: 0.4,
                          },

                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.startToEnd) {
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
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddExpenseScreen(
                                  expense: item,
                                  keyValue: item.id,
                                )
                                ),
                              );

                              if (result != null && result['success'] == true) {
                                final isUpdate = result['isUpdate'] == true;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isUpdate
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
                            widget.service.deleteExpense(deletedKey);

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
                                      widget.service.addExpenseWithKey(deletedKey, newItem);

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
                                Text("Delete", style: TextStyle(color: Colors.white)),
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
                                Text("Edit", style: TextStyle(color: Colors.white)),
                                SizedBox(width: 8),
                                Icon(Icons.edit, color: Colors.white),
                              ],
                            ),
                          ),

                          child: ExpenseCard(item: item)
                        );
                      },
                    );
                  },
                ),
              ),
            ],
        
    ); 
  }
}