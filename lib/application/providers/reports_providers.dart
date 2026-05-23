import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:proyecto_movil/domain/entities/transaction_entity.dart';
import 'package:proyecto_movil/application/providers/app_providers.dart';

// Provider para resumen de reportes
class ReportsSummary {
  final int totalIncome;
  final int totalExpense;
  final int balance;
  final Map<String, int> byCategory;

  const ReportsSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.byCategory,
  });

  // Alias para compatibilidad con código existente
  int get income => totalIncome;
  int get expense => totalExpense;
  
  // Getters derivados
  double get savingRatePercent {
    if (totalIncome == 0) return 0;
    return (balance / totalIncome) * 100;
  }
  
  double get vsLastMonthPercent => 0.0; // TODO: Implementar comparación con mes anterior
}

final reportsSummaryProvider = Provider<ReportsSummary>((ref) {
  final txState = ref.watch(transactionsControllerProvider);
  
  int income = 0, expense = 0;
  final byCategory = <String, int>{};

  for (final tx in txState.items) {
    if (tx.type == TransactionType.income) {
      income += tx.amount;
    } else {
      expense += tx.amount;
    }
    
    byCategory[tx.category] = (byCategory[tx.category] ?? 0) + (tx.type == TransactionType.income ? tx.amount : -tx.amount);
  }

  return ReportsSummary(
    totalIncome: income,
    totalExpense: expense,
    balance: income - expense,
    byCategory: byCategory,
  );
});
