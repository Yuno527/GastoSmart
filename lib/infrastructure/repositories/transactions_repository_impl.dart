import 'package:proyecto_movil/domain/entities/transaction_entity.dart';
import 'package:proyecto_movil/domain/repositories/transactions_repository.dart';
import 'package:proyecto_movil/infrastructure/datasources/local_data_source.dart';

/// Implementación del repositorio usando LocalDataSource
class JsonTransactionsRepository implements TransactionsRepository {
  final LocalDataSource _dataSource;

  JsonTransactionsRepository(this._dataSource);

  @override
  Future<List<TransactionEntity>> getAll() async {
    final items = List<TransactionEntity>.from(_dataSource.getTransactions());
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  @override
  Future<void> add(TransactionEntity tx) => _dataSource.addTransaction(tx);

  @override
  Future<void> edit(TransactionEntity tx) => _dataSource.updateTransaction(tx);

  @override
  Future<void> delete(String id) => _dataSource.deleteTransaction(id);
}

/// Repositorio en memoria (para testing)
class InMemoryTransactionsRepository implements TransactionsRepository {
  final List<TransactionEntity> _items = [];

  @override
  Future<void> add(TransactionEntity tx) async {
    _items.add(tx);
  }

  @override
  Future<List<TransactionEntity>> getAll() async {
    return List.from(_items);
  }

  @override
  Future<void> edit(TransactionEntity tx) async {
    final idx = _items.indexWhere((t) => t.id == tx.id);
    if (idx >= 0) {
      _items[idx] = tx;
    }
  }

  @override
  Future<void> delete(String id) async {
    _items.removeWhere((t) => t.id == id);
  }
}
