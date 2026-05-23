import 'package:proyecto_movil/domain/entities/transaction_entity.dart';

/// Interfaz (Puerto) para repositorio de transacciones
abstract class TransactionsRepository {
  Future<void> add(TransactionEntity tx);
  Future<List<TransactionEntity>> getAll();
  Future<void> edit(TransactionEntity tx);
  Future<void> delete(String id);
}
