import 'package:proyecto_movil/domain/entities/transaction_entity.dart';

abstract class TransactionsRepository {
  Future<TransactionEntity> add(TransactionEntity tx);
  Future<List<TransactionEntity>> getAll();
  Future<TransactionEntity> edit(TransactionEntity tx);
  Future<void> delete(String id, {required String userId});
}