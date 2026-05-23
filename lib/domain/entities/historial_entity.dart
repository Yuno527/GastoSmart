import 'package:proyecto_movil/domain/entities/transaction_entity.dart';

class HistorialEntity {
  final String id;
  final String userId;
  final DateTime fechaConsulta;
  final List<TransactionEntity> movimientos;

  const HistorialEntity({
    required this.id,
    required this.userId,
    required this.fechaConsulta,
    required this.movimientos,
  });

  int get totalIngresos => movimientos
      .where((m) => m.type == TransactionType.income)
      .fold(0, (s, m) => s + m.amount);

  int get totalGastos => movimientos
      .where((m) => m.type == TransactionType.expense)
      .fold(0, (s, m) => s + m.amount);

  int get balance => totalIngresos - totalGastos;

  HistorialEntity copyWith({
    String? id,
    String? userId,
    DateTime? fechaConsulta,
    List<TransactionEntity>? movimientos,
  }) {
    return HistorialEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fechaConsulta: fechaConsulta ?? this.fechaConsulta,
      movimientos: movimientos ?? this.movimientos,
    );
  }
}