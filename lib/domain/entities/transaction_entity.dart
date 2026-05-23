enum TransactionType { income, expense }

class TransactionEntity {
  final String id;
  final String userId;
  final TransactionType type;
  final int amount;
  final String category; // "Alimentación", etc.
  final DateTime date;
  final String note;

  const TransactionEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.category,
    required this.date,
    required this.note,
  });

  TransactionEntity copyWith({
    String? id,
    String? userId,
    TransactionType? type,
    int? amount,
    String? category,
    DateTime? date,
    String? note,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }
}
