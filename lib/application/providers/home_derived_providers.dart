import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:proyecto_movil/domain/entities/transaction_entity.dart';
import 'package:proyecto_movil/application/providers/app_providers.dart';

// Provider para categoría seleccionada en el historial
final historySelectedCategoryProvider = StateProvider<String>((ref) => 'Todas');

// Provider derivado para transacciones agrupadas por día
final groupedByDayProvider = Provider<Map<DateTime, List<TransactionEntity>>>((ref) {
  final selected = ref.watch(historySelectedCategoryProvider);
  final txState = ref.watch(transactionsControllerProvider);

  final Map<DateTime, List<TransactionEntity>> grouped = {};

  for (final tx in txState.items) {
    // Filtrar por categoría
    if (selected != 'Todas' && tx.category != selected) continue;

    final dateKey = DateTime(tx.date.year, tx.date.month, tx.date.day);

    if (!grouped.containsKey(dateKey)) {
      grouped[dateKey] = [];
    }
    grouped[dateKey]!.add(tx);
  }

  return grouped;
});
