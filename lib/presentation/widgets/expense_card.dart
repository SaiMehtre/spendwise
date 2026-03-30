import 'dart:ui';
import 'package:flutter/material.dart';
import '../../data/models/expense_model.dart';
import '../../core/utils/category_utils.dart';
import '../../core/utils/format_utils.dart';

class ExpenseCard extends StatefulWidget {
  final Expense item;

  const ExpenseCard({super.key, required this.item});

  @override
  State<ExpenseCard> createState() => _ExpenseCardState();
}

class _ExpenseCardState extends State<ExpenseCard> {
  bool isExpanded = false;

  @override
Widget build(BuildContext context) {
  final item = widget.item;

  return GestureDetector(
    onTap: () {
      setState(() {
        isExpanded = !isExpanded;
      });
    },
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16), // same rounded corners
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8), // blur effect
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: CategoryUtils.getColor(item.category).withOpacity(0.2),
                child: Icon(
                    CategoryUtils.getIcon(item.category),
                    color: CategoryUtils.getColor(item.category),
                  ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text((item.category),style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
                    
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 250),
                      crossFadeState: isExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      firstChild: Text(
                        item.note,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                      secondChild: Text(
                        item.note,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      FormatUtils.formatDate(item.date),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                FormatUtils.formatCurrency(item.amount),
                style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}