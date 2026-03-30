import 'package:flutter/material.dart';
import 'filter_bottom_sheet.dart';

class SearchFilterBar extends StatelessWidget {
  final Function(String) onSearch;
  final String selectedCategory;
  final DateTime? selectedMonth;
  final Function(String) onCategoryChanged;
  final Function(DateTime?) onMonthChanged;
  final VoidCallback onClear;

  const SearchFilterBar({
    super.key,
    required this.onSearch,
    required this.selectedCategory,
    required this.selectedMonth,
    required this.onCategoryChanged,
    required this.onMonthChanged,
    required this.onClear,
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
                onMonthChanged: onMonthChanged,
                onClear: onClear,
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