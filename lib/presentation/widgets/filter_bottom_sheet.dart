import 'package:flutter/material.dart';

const List<String> months = [
  'All',
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
];

class FilterBottomSheet extends StatelessWidget {
  final String selectedCategory;
  final DateTime? selectedMonth;
  final Function(String) onCategoryChanged;
  final Function(DateTime?) onMonthChanged;
  final VoidCallback onClear;
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime?)? onStartDateChanged;
  final Function(DateTime?)? onEndDateChanged;

  const FilterBottomSheet({
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade900,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          const Text(
            "Filters",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          DropdownButton<String>(
            value: selectedCategory,
            dropdownColor: Colors.black,
            isExpanded: true,
            items: ['All', 'Food', 'Travel', 'Shopping', 'Bills', 'Other']
                .map((cat) => DropdownMenuItem(
                      value: cat,
                      child: Text(cat, style: const TextStyle(color: Colors.white)),
                    ))
                .toList(),
            onChanged: (value) {
              onCategoryChanged(value!);
            },
          ),

          const SizedBox(height: 12),

          

          DropdownButton<String>(
            value: selectedMonthLabel,
            dropdownColor: Colors.black,
            isExpanded: true,
            items: months.map((m) {
              return DropdownMenuItem(
                value: m,
                child: Text(m, style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
            onChanged: (value) {
              if (value == 'All') {
                onMonthChanged(null);
              } else {
                final monthMap = {
                  'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4,
                  'May': 5, 'Jun': 6, 'Jul': 7, 'Aug': 8,
                  'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
                };

                if (value == 'All') {
                  onMonthChanged(null);
                } else {
                  final month = monthMap[value]!;
                  onMonthChanged(DateTime(DateTime.now().year, month));
                }
              }
            },
          ),

          const SizedBox(height: 12),

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
            child: const Text("Select Date Range"),
          ),


          TextButton(
            onPressed: () {
              onClear();
              Navigator.pop(context);
            },
            child: const Text("Clear Filters"),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}