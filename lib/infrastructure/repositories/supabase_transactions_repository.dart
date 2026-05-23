import 'package:proyecto_movil/domain/entities/transaction_entity.dart';
import 'package:proyecto_movil/domain/repositories/transactions_repository.dart';
import 'package:proyecto_movil/infrastructure/datasources/supabase_data_source.dart';

class SupabaseTransactionsRepository implements TransactionsRepository {
  final SupabaseDataSource _ds;
  SupabaseTransactionsRepository(this._ds);

  @override
  Future<List<TransactionEntity>> getAll() =>
      throw UnimplementedError('Usa getAllForUser(userId)');

  Future<List<TransactionEntity>> getAllForUser(String userId) =>
      _ds.getTransactions(userId);

  @override
  Future<TransactionEntity> add(TransactionEntity tx) => _ds.addTransaction(tx);

  @override
  Future<TransactionEntity> edit(TransactionEntity tx) => _ds.updateTransaction(tx);

  @override
  Future<void> delete(String id, {required String userId}) =>
      _ds.deleteTransaction(id, userId: userId);
}