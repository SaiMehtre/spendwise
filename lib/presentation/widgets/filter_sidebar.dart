import 'package:flutter/material.dart';
import 'filter_bottom_sheet.dart';

class FilterSideBar extends StatelessWidget {
  final String selectedCategory;
  final DateTime? selectedMonth;
  final Function(String) onCategoryChanged;
  final Function(DateTime?) onMonthChanged;
  final VoidCallback onClear;
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime?)? onStartDateChanged;
  final Function(DateTime?)? onEndDateChanged;

  const FilterSideBar({
    super.key,
    required this.selectedCategory,
    required this.selectedMonth,
    required this.onCategoryChanged,
    required this.onMonthChanged,
    required this.onClear,
    required this.startDate,
    required this.endDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    String selectedMonthLabel = selectedMonth == null
        ? 'All'
        : months[selectedMonth!.month];

    return Material(
      color: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.75,
        height: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Filters",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  )
                ],
              ),

              const SizedBox(height: 20),

              /// CATEGORY
              const Text("Category", style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),

              DropdownButton<String>(
                value: selectedCategory,
                dropdownColor: Colors.black,
                isExpanded: true,
                items: ['All', 'Food', 'Travel', 'Shopping', 'Bills', 'Other']
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat,
                              style: const TextStyle(color: Colors.white)),
                        ))
                    .toList(),
                onChanged: (value) {
                  onCategoryChanged(value!);
                },
              ),

              const SizedBox(height: 20),

              /// MONTH
              const Text("Month", style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),

              DropdownButton<String>(
                value: selectedMonthLabel,
                dropdownColor: Colors.black,
                isExpanded: true,
                items: months.map((m) {
                  return DropdownMenuItem(
                    value: m,
                    child:
                        Text(m, style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == 'All') {
                    onMonthChanged(null);
                  } else {
                    final monthMap = {
                      'Jan': 1,
                      'Feb': 2,
                      'Mar': 3,
                      'Apr': 4,
                      'May': 5,
                      'Jun': 6,
                      'Jul': 7,
                      'Aug': 8,
                      'Sep': 9,
                      'Oct': 10,
                      'Nov': 11,
                      'Dec': 12,
                    };

                    final month = monthMap[value]!;
                    onMonthChanged(
                        DateTime(DateTime.now().year, month));
                  }
                },
              ),

              const SizedBox(height: 20),

              /// QUICK FILTERS
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final today = DateTime.now();
                        onStartDateChanged?.call(today);
                        onEndDateChanged?.call(today);
                      },
                      child: const Text("Today"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final today = DateTime.now();
                        final last7 =
                            today.subtract(const Duration(days: 6));
                        onStartDateChanged?.call(last7);
                        onEndDateChanged?.call(today);
                      },
                      child: const Text("7 Days"),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );

                  if (picked != null) {
                    onStartDateChanged?.call(picked);
                    onEndDateChanged?.call(picked);
                  }
                },
                child: const Text("Single Date"),
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: () async {
                  final pickedRange = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );

                  if (pickedRange != null) {
                    onStartDateChanged?.call(pickedRange.start);
                    onEndDateChanged?.call(pickedRange.end);
                  }
                },
                child: const Text("Date Range"),
              ),

              const Spacer(),

              /// CLEAR
              TextButton(
                onPressed: () {
                  onClear();
                  Navigator.pop(context);
                },
                child: const Text("Clear Filters",
                    style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}