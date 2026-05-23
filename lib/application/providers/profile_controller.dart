import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:proyecto_movil/application/providers/app_providers.dart';
import 'package:proyecto_movil/domain/entities/user_finance_entity.dart';
import 'package:proyecto_movil/infrastructure/datasources/supabase_data_source.dart';
import 'package:proyecto_movil/infrastructure/services/session_service.dart';

class ProfileState {
  final int saldoActual;
  final PresupuestoEntity? presupuesto;
  final MetaAhorroEntity? metaAhorro;
  final bool isLoading;
  final String? error;

  const ProfileState({
    this.saldoActual = 0,
    this.presupuesto,
    this.metaAhorro,
    this.isLoading = false,
    this.error,
  });

  ProfileState copyWith({
    int? saldoActual,
    PresupuestoEntity? presupuesto,
    MetaAhorroEntity? metaAhorro,
    bool? isLoading,
    String? error,
  }) =>
      ProfileState(
        saldoActual: saldoActual ?? this.saldoActual,
        presupuesto: presupuesto ?? this.presupuesto,
        metaAhorro: metaAhorro ?? this.metaAhorro,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class ProfileController extends StateNotifier<ProfileState> {
  final SupabaseDataSource _ds;
  final SessionService _session;

  ProfileController(this._ds, this._session) : super(const ProfileState());

  Future<void> load() async {
    final userId = _session.currentUserId;
    if (userId.isEmpty) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final saldo = await _ds.getSaldoActual(userId);
      final presupuesto = await _ds.getPresupuestoMensual(userId);
      final meta = await _ds.getMetaAhorroPrincipal(userId);
      state = state.copyWith(
        isLoading: false,
        saldoActual: saldo,
        presupuesto: presupuesto,
        metaAhorro: meta,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> savePresupuesto(int monto) async {
    final userId = _session.currentUserId;
    if (userId.isEmpty || monto <= 0) return false;
    try {
      final saved = await _ds.savePresupuestoMensual(
        userId: userId,
        montoLimite: monto,
      );
      state = state.copyWith(presupuesto: saved, error: null);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> saveMetaAhorro(int montoObjetivo) async {
    final userId = _session.currentUserId;
    if (userId.isEmpty || montoObjetivo <= 0) return false;
    try {
      final ahorroMes = _ahorroDelMes();
      final saved = await _ds.saveMetaAhorro(
        userId: userId,
        nombre: 'Ahorro mensual',
        montoObjetivo: montoObjetivo,
        montoActual: ahorroMes,
      );
      state = state.copyWith(metaAhorro: saved, error: null);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> syncMetaProgreso(int ingresosMes, int gastosMes) async {
    final userId = _session.currentUserId;
    if (userId.isEmpty) return;
    final ahorro = (ingresosMes - gastosMes).clamp(0, 1 << 30);
    try {
      await _ds.actualizarProgresoMeta(userId, ahorro);
      final meta = await _ds.getMetaAhorroPrincipal(userId);
      if (meta != null) state = state.copyWith(metaAhorro: meta);
    } catch (_) {}
  }

  Future<void> refreshSaldo() async {
    final userId = _session.currentUserId;
    if (userId.isEmpty) return;
    try {
      final saldo = await _ds.getSaldoActual(userId);
      state = state.copyWith(saldoActual: saldo);
    } catch (_) {}
  }

  int _ahorroDelMes() {
    // Se actualiza desde TransactionsController vía syncMetaProgreso
    return state.metaAhorro?.montoActual ?? 0;
  }
}

final profileControllerProvider =
    StateNotifierProvider<ProfileController, ProfileState>((ref) {
  return ProfileController(
    ref.watch(supabaseDataSourceProvider),
    ref.watch(sessionServiceProvider),
  );
});
