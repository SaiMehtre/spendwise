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
  child: Padding(
    padding: const EdgeInsets.only(top: 70), // adjust based on search bar height
    child: Align(
      alignment: Alignment.topRight,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.75,
        height: MediaQuery.of(context).size.height * 0.65,
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
            mainAxisSize: MainAxisSize.min,
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
              const Text("Category", style: TextStyle(color: Colors.white70,fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: DropdownButton<String>(
                  value: selectedCategory, // month ke liye change karna
                  dropdownColor: Colors.black,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: ['All', 'Food', 'Travel', 'Shopping', 'Bills', "Health", "Grocery", "Entertainment", 'Other']
                      .map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat,
                                style: const TextStyle(color: Colors.white)),
                          ))
                      .toList(),
                  onChanged: (value) {
                    onCategoryChanged(value!);
                    Navigator.pop(context);
                  },
                ),
              ),

              const SizedBox(height: 20),

              /// MONTH
              const Text("Month", style: TextStyle(color: Colors.white70,fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                  child: DropdownButton<String>(
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
                      Navigator.pop(context);
                    },
                  ),
              ),

              const SizedBox(height: 20),

              /// QUICK FILTERS
              const Text("Date Filter", style: TextStyle(color: Colors.white70,fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: DropdownButton<String>(
                  value: null,
                  hint: const Text(
                    "Select Date Wise",
                    style: TextStyle(color: Colors.white54),
                  ),
                  dropdownColor: Colors.black,
                  isExpanded: true,
                  items: ["Today", "Last 7 Days", "Single Date", "Date Range"]
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e, style: const TextStyle(color: Colors.white)),
                          ))
                      .toList(),
                  onChanged: (value) async {
                    final today = DateTime.now();

                    if (value == "Today") {
                      onStartDateChanged?.call(today);
                      onEndDateChanged?.call(today);
                    }

                    if (value == "Last 7 Days") {
                      final last7 = today.subtract(const Duration(days: 6));
                      onStartDateChanged?.call(last7);
                      onEndDateChanged?.call(today);
                    }

                    if (value == "Single Date") {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: today,
                        firstDate: DateTime(2020),
                        lastDate: today,
                      );

                      if (picked != null) {
                        onStartDateChanged?.call(picked);
                        onEndDateChanged?.call(picked);
                      }
                    }

                    if (value == "Date Range") {
                      final pickedRange = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: today,
                      );

                      if (pickedRange != null) {
                        onStartDateChanged?.call(pickedRange.start);
                        onEndDateChanged?.call(pickedRange.end);
                      }
                    }

                    Navigator.pop(context);
                  },
                ),
              ),

              const Spacer(),

              /// CLEAR
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    onClear();
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Clear Filters",
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
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