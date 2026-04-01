import 'package:flutter/material.dart';


class CategoryUtils {
  static Color getColor(String category) {
    switch (category) {
      case "Food":
        return Colors.orange;
      case "Travel":
        return Colors.blue;
      case "Shopping":
        return Colors.purple;
      case "Bills":
        return Colors.red;
      case "Health":
        return Colors.teal;
      case "Grocery":
        return Colors.green;
      case "Entertainment":
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  static IconData getIcon(String category) {
    switch (category) {
      case "Food":
        return Icons.restaurant;
      case "Travel":
        return Icons.directions_car;
      case "Shopping":
        return Icons.shopping_bag;
      case "Bills":
        return Icons.receipt;
      case "Health":
        return Icons.local_hospital;
      case "Grocery":
        return Icons.local_grocery_store;
      case "Entertainment":
        return Icons.movie;
      default:
        return Icons.category;
    }
  }
}