import 'package:flutter/material.dart';
import 'filter_sidebar.dart';

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
            showGeneralDialog(
              context: context,
              barrierDismissible: true,
              barrierLabel: "Filter",
              barrierColor: Colors.black54,
              transitionDuration: const Duration(milliseconds: 300),
              pageBuilder: (context, anim1, anim2) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: FilterSideBar(
                    selectedCategory: selectedCategory,
                    selectedMonth: selectedMonth,
                    onCategoryChanged: onCategoryChanged,
                    onMonthChanged: (val) {
                      onMonthChanged(val);
                      onStartDateChanged(null);
                      onEndDateChanged(null);
                    },
                    onClear: () {
                      onClear();
                      onStartDateChanged(null);
                      onEndDateChanged(null);
                    },
                    startDate: startDate,
                    endDate: endDate,
                    onStartDateChanged: (val) {
                      onStartDateChanged(val);
                      onMonthChanged(null);
                    },
                    onEndDateChanged: (val) {
                      onEndDateChanged(val);
                      onMonthChanged(null);
                    },
                  ),
                );
              },
              transitionBuilder: (context, anim, secAnim, child) {
                return SlideTransition(
                  position: Tween(
                    begin: const Offset(1, 0),
                    end: const Offset(0, 0),
                  ).animate(anim),
                  child: child,
                );
              },
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