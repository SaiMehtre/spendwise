import 'package:flutter/material.dart';
import '../../data/services/expense_service.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/utils/category_utils.dart';

class AnalyticsScreen extends StatelessWidget {
  AnalyticsScreen({super.key});

  final service = ExpenseService();
  final List<Color> pieColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
  ];

  @override
  Widget build(BuildContext context) {
    final expenses = service.getExpenses();

    double total = 0;
    Map<String, double> categoryMap = {};

    for (var e in expenses) {
      double amount = e['amount'];

      total += amount;

      if (categoryMap.containsKey(e['category'])) {
        categoryMap[e['category']] =
            categoryMap[e['category']]! + amount;
      } else {
        categoryMap[e['category']] = amount;
      }
    }

    String topCategory = "";
    double max = 0;

    categoryMap.forEach((key, value) {
      if (value > max) {
        max = value;
        topCategory = key;
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Analytics")),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEEF2F3), Color(0xFFDDE6ED)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 🔥 TOTAL CARD
              buildTopCard(total),

              const SizedBox(height: 10),

              // 🔥 TOP CATEGORY
              buildTopCategoryCard(topCategory, max),

              const SizedBox(height: 10),
              buildPieChart(categoryMap),
              const SizedBox(height: 10),

              // 🔥 CATEGORY LIST
              buildCategoryBreakdown(categoryMap),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTopCard(double total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            "Total Spend",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 10),
          Text(
            "₹${total.toStringAsFixed(0)}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTopCategoryCard(String category, double amount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF512F), Color(0xFFDD2476)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Text(
            "Top Category",
            style: TextStyle(color: Colors.white70),
          ),

          const Spacer(),

          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  "₹${amount.toStringAsFixed(0)}",
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          )
        ],
      )
    );
  }

  Widget buildCategoryBreakdown(Map<String, double> data) {
    return Column(
      children: data.entries.map((entry) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded( // 🔥 KEY FIX
                child: Text(
                  entry.key,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(width: 8),

              FittedBox( // 🔥 prevents overflow
                child: Text(
                  "₹${entry.value.toStringAsFixed(0)}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          )
        );
      }).toList(),
    );
  }

  List<PieChartSectionData> buildPieSections(Map<String, double> data) {
    // final colors = [
    //   Colors.blue,
    //   Colors.red,
    //   Colors.green,
    //   Colors.orange,
    //   Colors.purple,
    // ];

    // int i = 0;

    return data.entries.map((entry) {
      final section = PieChartSectionData(
        color: getCategoryColor(entry.key), // 🔥 FIXED
        value: entry.value,
        title: "",
        radius: 50,
      );
      // i++;
      return section;
    }).toList();
  }
  

  Widget buildPieChart(Map<String, double> data) {
    double total = data.values.fold(0, (sum, val) => sum + val);
    // int i = 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            "Category Breakdown",
            style: TextStyle(fontWeight: FontWeight.bold),
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
            ),
          ),

          const SizedBox(height: 20),

          // 🔥 LEGEND

          Column(
            children: data.entries.map((entry) {
              final percent = (entry.value / total) * 100;

              final color = getCategoryColor(entry.key); // 🔥 SAME COLOR

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      color: color, // 🔥 FIXED
                    ),
                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        entry.key,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    Text(
                      "₹${entry.value.toStringAsFixed(0)}  (${percent.toStringAsFixed(1)}%)",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}