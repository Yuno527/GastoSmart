import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:proyecto_movil/infrastructure/datasources/local_data_source.dart';
import 'package:proyecto_movil/infrastructure/repositories/transactions_repository_impl.dart';
import 'package:proyecto_movil/infrastructure/services/session_service.dart';
import 'package:proyecto_movil/domain/usecases/add_transaction_usecase.dart';
import 'package:proyecto_movil/domain/entities/transaction_entity.dart';

// ============== DATASOURCES ==============
final localDataSourceProvider = Provider<LocalDataSource>((ref) {
  throw UnimplementedError('Debe sobreescribirse en ProviderScope');
});

// ============== SERVICES ==============
final sessionServiceProvider = Provider<SessionService>((ref) {
  throw UnimplementedError('Debe sobreescribirse en ProviderScope');
});

// ============== REPOSITORIES ==============
final transactionsRepositoryProvider = Provider<JsonTransactionsRepository>((ref) {
  final dataSource = ref.watch(localDataSourceProvider);
  return JsonTransactionsRepository(dataSource);
});

// ============== USE CASES ==============
final addTransactionUseCaseProvider = Provider<AddTransactionUseCase>((ref) {
  final repo = ref.watch(transactionsRepositoryProvider);
  return AddTransactionUseCase(repo);
});

// ============== APPLICATION STATE ==============

// Onboarding
final showOnboardingProvider = StateProvider<bool>((ref) => true);

// Transactions State
class TransactionsState {
  final List<TransactionEntity> items;
  final DateTime monthRef;
  final int incomeMonth;
  final int expenseMonth;
  final int balanceMonth;

  const TransactionsState({
    required this.items,
    required this.monthRef,
    required this.incomeMonth,
    required this.expenseMonth,
    required this.balanceMonth,
  });

  factory TransactionsState.initial() {
    final now = DateTime.now();
    final m = DateTime(now.year, now.month, 1);
    return TransactionsState(
      items: const [],
      monthRef: m,
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
  }) {
    return TransactionsState(
      items: items ?? this.items,
      monthRef: monthRef ?? this.monthRef,
      incomeMonth: incomeMonth ?? this.incomeMonth,
      expenseMonth: expenseMonth ?? this.expenseMonth,
      balanceMonth: balanceMonth ?? this.balanceMonth,
    );
  }
}

// Transactions Controller
class TransactionsController extends StateNotifier<TransactionsState> {
  final JsonTransactionsRepository repo;
  final AddTransactionUseCase addUseCase;
  final SessionService sessionService;

  TransactionsController({
    required this.repo,
    required this.addUseCase,
    required this.sessionService,
  }) : super(TransactionsState.initial());

  Future<void> load() async {
    final items = await repo.getAll();
    final currentUserId = sessionService.currentUserId;
    final filtered = items.where((t) => t.userId == currentUserId).toList();
    final sorted = [...filtered]..sort((a, b) => b.date.compareTo(a.date));

    final monthRef = _pickMonthRef(sorted);
    final summary = _calcMonth(sorted, monthRef);

    state = state.copyWith(
      items: sorted,
      monthRef: monthRef,
      incomeMonth: summary.income,
      expenseMonth: summary.expense,
      balanceMonth: summary.balance,
    );
  }

  Future<void> add(TransactionEntity tx) async {
    await addUseCase(tx);

    final updated = [...state.items, tx]..sort((a, b) => b.date.compareTo(a.date));

    final monthRef = _pickMonthRef(updated);
    final summary = _calcMonth(updated, monthRef);

    state = state.copyWith(
      items: updated,
      monthRef: monthRef,
      incomeMonth: summary.income,
      expenseMonth: summary.expense,
      balanceMonth: summary.balance,
    );
  }

  DateTime _pickMonthRef(List<TransactionEntity> sorted) {
    if (sorted.isEmpty) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, 1);
    }
    final latest = sorted.first;
    return DateTime(latest.date.year, latest.date.month, 1);
  }

  ({int income, int expense, int balance}) _calcMonth(
    List<TransactionEntity> sorted,
    DateTime monthRef,
  ) {
    int income = 0, expense = 0;
    for (final t in sorted) {
      if (t.date.year == monthRef.year && t.date.month == monthRef.month) {
        if (t.type == TransactionType.income) {
          income += t.amount;
        } else {
          expense += t.amount;
        }
      }
    }
    return (income: income, expense: expense, balance: income - expense);
  }
}

final transactionsControllerProvider =
    StateNotifierProvider<TransactionsController, TransactionsState>((ref) {
  final repo = ref.watch(transactionsRepositoryProvider);
  final addUseCase = ref.watch(addTransactionUseCaseProvider);
  final sessionService = ref.watch(sessionServiceProvider);
  return TransactionsController(
    repo: repo,
    addUseCase: addUseCase,
    sessionService: sessionService,
  );
});
