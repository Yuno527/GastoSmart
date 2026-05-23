import 'package:proyecto_movil/domain/entities/transaction_entity.dart';
import 'package:proyecto_movil/domain/repositories/transactions_repository.dart';

class AddTransactionUseCase {
  final TransactionsRepository repo;
  AddTransactionUseCase(this.repo);

  Future<TransactionEntity> call(TransactionEntity tx) {
    if (tx.amount <= 0) throw Exception('El monto debe ser mayor a 0');
    return repo.add(tx);
  }
}