import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:proyecto_movil/infrastructure/datasources/supabase_data_source.dart';
import 'package:proyecto_movil/infrastructure/repositories/supabase_transactions_repository.dart';
import 'package:proyecto_movil/infrastructure/services/session_service.dart';
import 'package:proyecto_movil/domain/usecases/add_transaction_usecase.dart';
import 'package:proyecto_movil/domain/entities/transaction_entity.dart';
import 'package:proyecto_movil/domain/entities/historial_entity.dart';

// ==== cliente & datasource ==============================================================================
final supabaseClientProvider = Provider<SupabaseClient>(
  (_) => Supabase.instance.client,
);

final supabaseDataSourceProvider = Provider<SupabaseDataSource>(
  (ref) => SupabaseDataSource(ref.watch(supabaseClientProvider)),
);

// ==== servicios ===============================================================================
final sessionServiceProvider = Provider<SessionService>(
  (_) => throw UnimplementedError('Sobreescribir en ProviderScope'),
);

// ==== repositorios ==============================================================================
final transactionsRepositoryProvider =
    Provider<SupabaseTransactionsRepository>(
  (ref) => SupabaseTransactionsRepository(ref.watch(supabaseDataSourceProvider)),
);

// ==== use cases ==============================================================================
final addTransactionUseCaseProvider = Provider<AddTransactionUseCase>(
  (ref) => AddTransactionUseCase(ref.watch(transactionsRepositoryProvider)),
);

// ==== onboarding ==============================================================================
final showOnboardingProvider = StateProvider<bool>((_) => true);

// ==== TransactionsState ==============================================================================
class TransactionsState {
  final List<TransactionEntity> items;
  final DateTime monthRef;
  final int incomeMonth;
  final int expenseMonth;
  final int balanceMonth;
  final bool isLoading;
  final String? error;

  const TransactionsState({
    required this.items,
    required this.monthRef,
    required this.incomeMonth,
    required this.expenseMonth,
    required this.balanceMonth,
    this.isLoading = false,
    this.error,
  });

  factory TransactionsState.initial() {
    final now = DateTime.now();
    return TransactionsState(
      items: const [],
      monthRef: DateTime(now.year, now.month, 1),
      incomeMonth: 0,
      expenseMonth: 0,
      balanceMonth: 0,
    );
  }

  TransactionsState copyWith({
    List<TransactionEntity>? items,
    DateTime? monthRef,
    int? incomeMonth,
    int? expenseMonth,
    int? balanceMonth,
    bool? isLoading,
    String? error,
  }) =>
      TransactionsState(
        items:        items        ?? this.items,
        monthRef:     monthRef     ?? this.monthRef,
        incomeMonth:  incomeMonth  ?? this.incomeMonth,
        expenseMonth: expenseMonth ?? this.expenseMonth,
        balanceMonth: balanceMonth ?? this.balanceMonth,
        isLoading:    isLoading    ?? this.isLoading,
        error:        error,
      );
}

// ==== TransactionsController ==============================================================================
class TransactionsController extends StateNotifier<TransactionsState> {
  final SupabaseTransactionsRepository repo;
  final AddTransactionUseCase addUseCase;
  final SessionService sessionService;
  final SupabaseDataSource dataSource;

  TransactionsController({
    required this.repo,
    required this.addUseCase,
    required this.sessionService,
    required this.dataSource,
  }) : super(TransactionsState.initial());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final userId = sessionService.currentUserId;
      final sorted = (await repo.getAllForUser(userId))
        ..sort((a, b) => b.date.compareTo(a.date));
      final ref    = _pickMonthRef(sorted);
      final s      = _calcMonth(sorted, ref);
      state = state.copyWith(
        isLoading: false, items: sorted, monthRef: ref,
        incomeMonth: s.income, expenseMonth: s.expense, balanceMonth: s.balance,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> add(TransactionEntity tx) async {
    try {
      final saved   = await addUseCase(tx);
      final updated = [...state.items, saved]
        ..sort((a, b) => b.date.compareTo(a.date));
      final ref = _pickMonthRef(updated);
      final s   = _calcMonth(updated, ref);
      state = state.copyWith(
        items: updated, monthRef: ref,
        incomeMonth: s.income, expenseMonth: s.expense, balanceMonth: s.balance,
        error: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> edit(TransactionEntity tx) async {
    try {
      final updated = await repo.edit(tx);
      final list    = state.items.map((t) => t.id == updated.id ? updated : t).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      final s = _calcMonth(list, state.monthRef);
      state = state.copyWith(
        items: list,
        incomeMonth: s.income, expenseMonth: s.expense, balanceMonth: s.balance,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> delete(String id) async {
    try {
      final userId = sessionService.currentUserId;
      await repo.delete(id, userId: userId);
      final list = state.items.where((t) => t.id != id).toList();
      final s    = _calcMonth(list, state.monthRef);
      state = state.copyWith(
        items: list,
        incomeMonth: s.income, expenseMonth: s.expense, balanceMonth: s.balance,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Llama esto cuando el usuario abre la pantalla de historial.
  Future<HistorialEntity?> registrarConsultaHistorial({
    String accion = 'visualizado',
  }) async {
    try {
      return await dataSource.registrarConsulta(
        userId: sessionService.currentUserId,
        movimientosConsultados: state.items,
        accion: accion,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  DateTime _pickMonthRef(List<TransactionEntity> s) {
    if (s.isEmpty) { final n = DateTime.now(); return DateTime(n.year, n.month, 1); }
    return DateTime(s.first.date.year, s.first.date.month, 1);
  }

  ({int income, int expense, int balance}) _calcMonth(
      List<TransactionEntity> s, DateTime ref) {
    int i = 0, e = 0;
    for (final t in s) {
      if (t.date.year == ref.year && t.date.month == ref.month) {
        t.type == TransactionType.income ? i += t.amount : e += t.amount;
      }
    }
    return (income: i, expense: e, balance: i - e);
  }
}

final transactionsControllerProvider =
    StateNotifierProvider<TransactionsController, TransactionsState>((ref) {
  return TransactionsController(
    repo:           ref.watch(transactionsRepositoryProvider),
    addUseCase:     ref.watch(addTransactionUseCaseProvider),
    sessionService: ref.watch(sessionServiceProvider),
    dataSource:     ref.watch(supabaseDataSourceProvider),
  );
});

// ==== HistorialState & Controller ==============================================================================
class HistorialState {
  final List<HistorialEntity> historial;
  final HistorialEntity? seleccionado;
  final bool isLoading;
  final String? error;

  const HistorialState({
    this.historial    = const [],
    this.seleccionado,
    this.isLoading    = false,
    this.error,
  });

  HistorialState copyWith({
    List<HistorialEntity>? historial,
    HistorialEntity? seleccionado,
    bool? isLoading,
    String? error,
  }) =>
      HistorialState(
        historial:    historial    ?? this.historial,
        seleccionado: seleccionado ?? this.seleccionado,
        isLoading:    isLoading    ?? this.isLoading,
        error:        error,
      );
}

class HistorialController extends StateNotifier<HistorialState> {
  final SupabaseDataSource _ds;
  final SessionService _session;

  HistorialController(this._ds, this._session) : super(const HistorialState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _ds.getHistorial(_session.currentUserId);
      state = state.copyWith(isLoading: false, historial: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> seleccionar(String historialId) async {
    state = state.copyWith(isLoading: true);
    try {
      final full = await _ds.getHistorialConDetalle(historialId);
      state = state.copyWith(isLoading: false, seleccionado: full);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void limpiarSeleccion() => state = state.copyWith(seleccionado: null);
}

final historialControllerProvider =
    StateNotifierProvider<HistorialController, HistorialState>((ref) {
  return HistorialController(
    ref.watch(supabaseDataSourceProvider),
    ref.watch(sessionServiceProvider),
  )..load();
});