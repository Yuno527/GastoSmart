import 'package:proyecto_movil/domain/entities/transaction_entity.dart';

class TransactionMapper {
  static Map<String, dynamic> toMap(TransactionEntity entity) {
    return {
      'id': entity.id,
      'userId': entity.userId,
      'type': entity.type == TransactionType.income ? 'income' : 'expense',
      'amount': entity.amount,
      'category': entity.category,
      'date': entity.date.toIso8601String(),
      'note': entity.note,
    };
  }

  static TransactionEntity fromMap(Map<String, dynamic> map) {
    return TransactionEntity(
      id: map['id'] as String,
      userId: map['userId'] as String,
      type: (map['type'] as String) == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      amount: map['amount'] as int,
      category: map['category'] as String,
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String,
    );
  }
}
