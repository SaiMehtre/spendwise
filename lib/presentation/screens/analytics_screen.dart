import 'dart:ui';
import 'package:flutter/material.dart';
import '../../data/services/expense_service.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/utils/category_utils.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {

  final service = ExpenseService();

  String selectedFilter = "Month"; // default
  DateTime? startDate;
  DateTime? endDate;

  final List<Color> pieColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
  ];

  IconData _getFilterIcon(String value) {
  switch (value) {
    case "Today":
      return Icons.today;
    case "Week":
      return Icons.view_week;
    case "Month":
      return Icons.calendar_month;
    case "Year":
      return Icons.date_range;
    case "Single Date":
      return Icons.event;
    case "Date Range":
      return Icons.timeline;
    case "All Time":
      return Icons.all_inclusive;
    default:
      return Icons.filter_list;
  }
}
  

  @override
  Widget build(BuildContext context) {
  return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,

      body: ValueListenableBuilder(
        valueListenable: service.box.listenable(),
        builder: (context, box, _) {

          final expenses = box.keys.map((key) {
            final item = Map<String, dynamic>.from(box.get(key));
            item['key'] = key;
            return item;
          }).toList();

          // 🟡 DATE FILTER (MONTH)
          final now = DateTime.now();

          final filteredExpenses = expenses.where((e) {
          final d = DateTime.parse(e['date']);

          // 👉 All Time
          if (startDate == null && endDate == null) {
            return true;
          }

          // 👉 range filter
          return (d.isAfter(startDate!.subtract(const Duration(days: 1))) &&
                  d.isBefore(endDate!.add(const Duration(days: 1))));
        }).toList();

          double total = 0;
          Map<String, double> categoryMap = {};

          for (var e in filteredExpenses) {
            double amount = e['amount'];
            total += amount;

            categoryMap[e['category']] =
                (categoryMap[e['category']] ?? 0) + amount;
          }

          String topCategory = "";
          double max = 0;

          categoryMap.forEach((key, value) {
            if (value > max) {
              max = value;
              topCategory = key;
            }
          });

          if (categoryMap.isEmpty) {
            topCategory = "No Data";
          }

          // top category 
          double percent = total == 0 ? 0 : (max / total) * 100;

          return Container(
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Column(
                children: [
                  buildFilterCard(),
                  const SizedBox(height: 8),
                  buildTopCard(total),
                  const SizedBox(height: 8),
                  buildTopCategoryCard(topCategory, max, percent),
                  const SizedBox(height: 8),
                  buildPieChart(categoryMap),
                  const SizedBox(height: 8),
                  buildCategoryBreakdown(categoryMap),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildTopCard(double total) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF11998E), // teal green
                Color(0xFF38EF7D), // light green
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF38EF7D).withOpacity(0.4),
                blurRadius: 18,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                "Total Spend",
                style: TextStyle(color: Colors.white70,fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: total),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Text(
                    NumberFormat.currency(
                      locale: 'en_IN',
                      symbol: '₹',
                      decimalDigits: 2,
                    ).format(value),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTopCategoryCard(String category, double amount, double percent) {
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.orange.withOpacity(0.8),
                Colors.deepOrange,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.4),
                blurRadius: 15,
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.star, color: Colors.white70, size: 16),
              SizedBox(width: 2),
              const Text(
                "Top Category",
                style: TextStyle(color: Colors.white70,fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              // Expanded(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      category == "No Data"
                          ? "No Data"
                          : "$category (${percent.toStringAsFixed(1)}%)",
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      NumberFormat.currency(
                        locale: 'en_IN',
                        symbol: '₹',
                        decimalDigits: 2,
                      ).format(amount),
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCategoryBreakdown(Map<String, double> data) {
      final sorted = data.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

    return Padding(
        padding: const EdgeInsets.fromLTRB(1, 1, 1, 90), // bottom 90 extra
        
        child: Column(
          children: sorted.map((entry){
            return ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FittedBox(
                        child: Text(
                            NumberFormat.currency(
                            locale: 'en_IN',
                            symbol: '₹',
                            decimalDigits: 2,
                          ).format(entry.value),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
  }

  List<PieChartSectionData> buildPieSections(Map<String, double> data) {
    double total = data.values.fold(0, (sum, val) => sum + val);
    final sorted = data.entries.toList()
  ..sort((a, b) => b.value.compareTo(a.value));

    // 👇 EMPTY DATA CASE
    if (total == 0) {
      return [
        PieChartSectionData(
          color: Colors.white24,
          value: 1,
          title: "No Data",
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ];
    }

    return sorted.map((entry) {
      final percent = (entry.value / total) * 100;

      return PieChartSectionData(
        color: CategoryUtils.getColor(entry.key),
        value: entry.value,
        title: "${percent.toStringAsFixed(1)}%",
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget buildPieChart(Map<String, double> data) {
    double total = data.values.fold(0, (sum, val) => sum + val);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            children: [
              const Text(
                "Category Breakdown",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: buildPieSections(data),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                  ),
                  swapAnimationDuration: Duration(milliseconds: 500),
                ),
              ),
              const SizedBox(height: 20),
              Column(
                children: (data.isEmpty
                    ? ["Food", "Travel", "Shopping", "Bills", "Others"]
                    : data.keys).map((key) {
                  final value = data[key] ?? 0;
                  final percent = total == 0 ? 0 : (value / total) * 100;
                  final color = CategoryUtils.getColor(key);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(width: 12, height: 12, color: color),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            key,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        Text(
                          "${NumberFormat.currency(
                            locale: 'en_IN',
                            symbol: '₹',
                            decimalDigits: 2,
                          ).format(value)} (${percent.toStringAsFixed(1)}%)",
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFilterCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
          ),          
          child: GestureDetector(
            onTap: _openFilterDialog,
            behavior: HitTestBehavior.opaque, 
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14), 
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(_getFilterIcon(selectedFilter), color: Colors.white70),
                      const SizedBox(width: 10),
                      Text(
                        selectedFilter,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                ],
              ),
            ),
          )
          
        ),
      ),
    );
  }

  void _openFilterDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF0F2027),
                Color(0xFF203A43),
                Color(0xFF2C5364),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...[
                "Today",
                "Week",
                "Month",
                "Year",
                "Single Date",
                "Date Range",
                "All Time"
              ].map((e) {
                return ListTile(
                  leading: Icon(_getFilterIcon(e), color: Colors.white70),
                  title: Text(e, style: const TextStyle(color: Colors.white)),
                  onTap: () async {
                    final now = DateTime.now();

                    setState(() {
                      selectedFilter = e;
                    });

                    if (e == "Today") {
                      startDate = now;
                      endDate = now;
                    }

                    if (e == "Week") {
                      startDate = now.subtract(const Duration(days: 6));
                      endDate = now;
                    }

                    if (e == "Month") {
                      startDate = DateTime(now.year, now.month, 1);
                      endDate = now;
                    }

                    if (e == "Year") {
                      startDate = DateTime(now.year, 1, 1);
                      endDate = now;
                    }

                    if (e == "Single Date") {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: now,
                        firstDate: DateTime(2020),
                        lastDate: now,
                      );

                      if (picked != null) {
                        startDate = picked;
                        endDate = picked;
                      }
                    }

                    if (e == "Date Range") {
                      final pickedRange = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: now,
                      );

                      if (pickedRange != null) {
                        startDate = pickedRange.start;
                        endDate = pickedRange.end;
                      }
                    }

                    if (e == "All Time") {
                      startDate = null;
                      endDate = null;
                    }

                    Navigator.pop(context); 
                  },
                );
              }).toList(),
            ],
          ),
        ),
      );
    },
  );
}
}