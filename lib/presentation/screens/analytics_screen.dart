import 'dart:ui';
import 'package:flutter/material.dart';
import '../../data/services/expense_service.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/utils/category_utils.dart';
import 'package:intl/intl.dart';

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
        categoryMap[e['category']] = categoryMap[e['category']]! + amount;
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Column(
            children: [
              buildTopCard(total),
              const SizedBox(height: 8),
              buildTopCategoryCard(topCategory, max),
              const SizedBox(height: 8),
              buildPieChart(categoryMap),
              const SizedBox(height: 8),
              buildCategoryBreakdown(categoryMap),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTopCard(double total) {
    // final formatter = NumberFormat.currency(
    //   locale: 'en_IN',
    //   symbol: '₹',
    //   decimalDigits: 2,
    // );

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            children: [
              const Text(
                "Total Spend",
                style: TextStyle(color: Colors.white70),
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

  Widget buildTopCategoryCard(String category, double amount) {
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
          child: Row(
            children: [
              const Text(
                "Top Category",
                style: TextStyle(color: Colors.white70,fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      "₹${amount.toStringAsFixed(2)}",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCategoryBreakdown(Map<String, double> data) {
  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 90), // bottom 90 extra
      child: Column(
        children: data.entries.map((entry) {
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
                        "₹${entry.value.toStringAsFixed(2)}",
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
    ),
  );
}

  List<PieChartSectionData> buildPieSections(Map<String, double> data) {
    double total = data.values.fold(0, (sum, val) => sum + val);
    if (total == 0) return [];

    return data.entries.map((entry) {
      final percent = (entry.value / total) * 100;

      return PieChartSectionData(
        color: getCategoryColor(entry.key),
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
                ),
              ),
              const SizedBox(height: 20),
              Column(
                children: data.entries.map((entry) {
                  final percent = (entry.value / total) * 100;
                  final color = getCategoryColor(entry.key);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(width: 12, height: 12, color: color),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.key,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        Text(
                          "₹${entry.value.toStringAsFixed(2)} (${percent.toStringAsFixed(1)}%)",
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, color: Colors.white),
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
}