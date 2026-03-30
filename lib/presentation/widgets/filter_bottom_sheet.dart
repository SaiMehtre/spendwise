import 'package:flutter/material.dart';

class FilterBottomSheet extends StatelessWidget {
  final String selectedCategory;
  final DateTime? selectedMonth;
  final Function(String) onCategoryChanged;
  final Function(DateTime?) onMonthChanged;
  final VoidCallback onClear;

  const FilterBottomSheet({
    super.key,
    required this.selectedCategory,
    required this.selectedMonth,
    required this.onCategoryChanged,
    required this.onMonthChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
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

          ElevatedButton(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );

              if (picked != null) {
                onMonthChanged(picked);
              }
            },
            child: const Text("Select Month"),
          ),

          const SizedBox(height: 12),

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