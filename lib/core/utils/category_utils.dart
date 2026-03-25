import 'package:flutter/material.dart';

Color getCategoryColor(String category) {
  switch (category) {
    case "Food":
      return Colors.orange;
    case "Travel":
      return Colors.blue;
    case "Shopping":
      return Colors.purple;
    case "Bills":
      return Colors.red;
    default:
      return Colors.grey;
  }
}