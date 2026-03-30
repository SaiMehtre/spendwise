import 'package:flutter/material.dart';
import 'filter_bottom_sheet.dart';

class SearchFilterBar extends StatelessWidget {
  final Function(String) onSearch;
  final String selectedCategory;
  final DateTime? selectedMonth;
  final Function(String) onCategoryChanged;
  final Function(DateTime?) onMonthChanged;
  final VoidCallback onClear;
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime?) onStartDateChanged;
  final Function(DateTime?) onEndDateChanged;

  const SearchFilterBar({
    super.key,
    required this.onSearch,
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

    bool isFilterActive =
        selectedCategory != 'All' || selectedMonth != null;

    return TextField(
      onChanged: (value) => onSearch(value.toLowerCase()),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: "Search expenses...",
        hintStyle: const TextStyle(color: Colors.white54),

        prefixIcon: const Icon(Icons.search, color: Colors.white70),

        suffixIcon: IconButton(
          icon: Icon(
            Icons.tune,
            color: isFilterActive ? Colors.orange : Colors.white70,
          ),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (_) => FilterBottomSheet(
                selectedCategory: selectedCategory,
                selectedMonth: selectedMonth,

                onCategoryChanged: onCategoryChanged,

                onMonthChanged: (val) {
                  onMonthChanged(val);

                  // 👉 month select hua to range reset
                  onStartDateChanged(null);
                  onEndDateChanged(null);
                },

                onClear: () {
                  onClear();

                  // 👉 clear me sab reset
                  onStartDateChanged(null);
                  onEndDateChanged(null);
                },

                // 🔥 NEW PARAMETERS (IMPORTANT)
                startDate: startDate,
                endDate: endDate,

                onStartDateChanged: (val) {
                  onStartDateChanged(val);

                  // 👉 range select hua to month reset
                  onMonthChanged(null);
                },

                onEndDateChanged: (val) {
                  onEndDateChanged(val);

                  // 👉 range select hua to month reset
                  onMonthChanged(null);
                },
              ),
            );
          },
        ),

        filled: true,
        fillColor: Colors.white.withOpacity(0.1),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}