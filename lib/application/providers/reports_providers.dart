import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:proyecto_movil/application/providers/app_providers.dart';
import 'package:proyecto_movil/domain/entities/transaction_entity.dart';
import 'package:proyecto_movil/domain/entities/user_finance_entity.dart';
import 'package:proyecto_movil/infrastructure/datasources/supabase_data_source.dart';
import 'package:proyecto_movil/infrastructure/services/session_service.dart';

class ReportsSummary {
  final int totalIncome;
  final int totalExpense;
  final int balance;
  final Map<String, int> byCategory;
  final double vsLastMonthPercent;
  final List<ReportePersonalEntity> historialReportes;

  const ReportsSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.byCategory,
    this.vsLastMonthPercent = 0,
    this.historialReportes = const [],
  });

  int get income => totalIncome;
  int get expense => totalExpense;

  double get savingRatePercent {
    if (totalIncome == 0) return 0;
    return (balance / totalIncome) * 100;
  }
}

class ReportsController extends StateNotifier<ReportsSummary> {
  final SupabaseDataSource _ds;
  final SessionService _session;

  ReportsController(this._ds, this._session)
      : super(const ReportsSummary(
          totalIncome: 0,
          totalExpense: 0,
          balance: 0,
          byCategory: {},
        ));

  Future<void> generarYGuardar(List<TransactionEntity> items) async {
    final userId = _session.currentUserId;
    if (userId.isEmpty) return;

    final now = DateTime.now();
    final ref = DateTime(now.year, now.month, 1);
    final prev = DateTime(now.year, now.month - 1, 1);

    final actual = _totalesMes(items, ref);
    final anterior = _totalesMes(items, prev);

    await _ds.guardarReporteMensual(
      userId: userId,
      totalIngresos: actual.income,
      totalGastos: actual.expense,
      ref: ref,
    );

    if (prev.month >= 1 || prev.year < DateTime.now().year) {
      await _ds.guardarReporteMensual(
        userId: userId,
        totalIngresos: anterior.income,
        totalGastos: anterior.expense,
        ref: prev,
      );
    }

    final historial = await _ds.getReportes(userId);
    final vs = _calcVsMesAnterior(anterior.expense, actual.expense);

    state = ReportsSummary(
      totalIncome: actual.income,
      totalExpense: actual.expense,
      balance: actual.balance,
      byCategory: _byCategory(items, ref),
      vsLastMonthPercent: vs,
      historialReportes: historial,
    );
  }

  ({int income, int expense, int balance}) _totalesMes(
    List<TransactionEntity> items,
    DateTime ref,
  ) {
    var i = 0, e = 0;
    for (final t in items) {
      if (t.date.year == ref.year && t.date.month == ref.month) {
        t.type == TransactionType.income ? i += t.amount : e += t.amount;
      }
    }
    return (income: i, expense: e, balance: i - e);
  }

  Map<String, int> _byCategory(List<TransactionEntity> items, DateTime ref) {
    final map = <String, int>{};
    for (final tx in items) {
      if (tx.date.year != ref.year || tx.date.month != ref.month) continue;
      final delta = tx.type == TransactionType.income ? tx.amount : -tx.amount;
      map[tx.category] = (map[tx.category] ?? 0) + delta;
    }
    return map;
  }

  double _calcVsMesAnterior(int gastoAnterior, int gastoActual) {
    if (gastoAnterior == 0) return 0;
    return ((gastoAnterior - gastoActual) / gastoAnterior) * 100;
  }
}

final reportsControllerProvider =
    StateNotifierProvider<ReportsController, ReportsSummary>((ref) {
  return ReportsController(
    ref.watch(supabaseDataSourceProvider),
    ref.watch(sessionServiceProvider),
  );
});

final reportsSummaryProvider = Provider<ReportsSummary>((ref) {
  ref.watch(transactionsControllerProvider);
  return ref.watch(reportsControllerProvider);
});
