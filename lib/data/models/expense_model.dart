class Expense {
  final String? id;
  final double amount;
  final String category;
  final String note;
  final DateTime date;

  Expense({
    this.id,
    required this.amount,
    required this.category,
    required this.note,
    required this.date,
  });

  factory Expense.fromMap(Map<String, dynamic> map, dynamic key) {
    return Expense(
      id: key?.toString(),
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] ?? 'Other',
      note: map['note'] ?? '',
      date: map['date'] is String
          ? DateTime.tryParse(map['date']) ?? DateTime.now()
          : map['date'] ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'category': category,
      'note': note,
      'date': date.toIso8601String(),
    };
  }
}