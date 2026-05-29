import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:proyecto_movil/domain/entities/transaction_entity.dart';
import 'package:proyecto_movil/domain/entities/admin_entity.dart';
import 'package:proyecto_movil/domain/entities/historial_entity.dart';
import 'package:proyecto_movil/domain/entities/user_finance_entity.dart';
import 'package:proyecto_movil/infrastructure/mappers/supabase_mappers.dart';

class SupabaseDataSource {
  SupabaseDataSource(this._client);
  final SupabaseClient _client;

  // === movimientos ========================================================
  Future<List<TransactionEntity>> getTransactions(String userId) async {
    final rows = await _client
        .from('movimientos')
        .select()
        .eq('usuario_id', userId)
        .order('fecha', ascending: false);
    return rows.map(SupabaseMappers.movimientoToEntity).toList();
  }

  Future<TransactionEntity> addTransaction(TransactionEntity tx) async {
    final row = await _client
        .from('movimientos')
        .insert(SupabaseMappers.entityToMovimiento(tx))
        .select()
        .single();
    final saved = SupabaseMappers.movimientoToEntity(row);
    await syncSaldoActual(tx.userId);
    return saved;
  }

  Future<TransactionEntity> updateTransaction(TransactionEntity tx) async {
    final row = await _client
        .from('movimientos')
        .update(SupabaseMappers.entityToMovimiento(tx))
        .eq('id', tx.id)
        .select()
        .single();
    final updated = SupabaseMappers.movimientoToEntity(row);
    await syncSaldoActual(tx.userId);
    return updated;
  }

  Future<void> deleteTransaction(String id, {required String userId}) async {
    await _client.from('movimientos').delete().eq('id', id);
    await syncSaldoActual(userId);
  }

  // === categorías ========================================================
  Future<List<AdminCategoryEntity>> getGlobalCategories() async {
    final rows = await _client
        .from('categorias')
        .select()
        .isFilter('usuario_id', null)
        .eq('activa', true)
        .order('nombre');
    return rows.map(SupabaseMappers.rowToCategory).toList();
  }

  Future<List<AdminCategoryEntity>> getUserCategories(String userId) async {
    final rows = await _client
        .from('categorias')
        .select()
        .eq('usuario_id', userId)
        .eq('activa', true)
        .order('nombre');
    return rows.map(SupabaseMappers.rowToCategory).toList();
  }

  Future<AdminCategoryEntity> addGlobalCategory(AdminCategoryEntity cat) async {
    final row = await _client
        .from('categorias')
        .insert(SupabaseMappers.categoryToRow(cat, userId: null))
        .select()
        .single();
    return SupabaseMappers.rowToCategory(row);
  }

  Future<AdminCategoryEntity> addUserCategory(
      AdminCategoryEntity cat, String userId) async {
    final row = await _client
        .from('categorias')
        .insert(SupabaseMappers.categoryToRow(cat, userId: userId))
        .select()
        .single();
    return SupabaseMappers.rowToCategory(row);
  }

  Future<AdminCategoryEntity> updateCategory(AdminCategoryEntity cat) async {
    final row = await _client
        .from('categorias')
        .update(SupabaseMappers.categoryToRow(cat))
        .eq('id', cat.id)
        .select()
        .single();
    return SupabaseMappers.rowToCategory(row);
  }

  Future<void> deleteCategory(String id) async {
    await _client.from('categorias').update({'activa': false}).eq('id', id);
  }

  // === usuarios ========================================================
  Future<List<AdminUserEntity>> getUsers() async {
    final rows = await _client.from('cuentas').select().order('nombre');
    return rows.map(SupabaseMappers.rowToUser).toList();
  }

  Future<AdminUserEntity?> getUserByEmail(String email) async {
    final rows = await _client
        .from('cuentas')
        .select()
        .eq('correo', email)
        .limit(1);
    if (rows.isEmpty) return null;
    return SupabaseMappers.rowToUser(rows.first);
  }

  Future<AdminUserEntity?> getUserById(String userId) async {
    final row = await _client
        .from('cuentas')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (row == null) return null;
    return SupabaseMappers.rowToUser(row);
  }

  Future<AdminUserEntity> createUser(AdminUserEntity user) async {
    final row = await _client
        .from('cuentas')
        .insert({
          ...SupabaseMappers.userToRow(user),
          'saldo_actual': 0,
        })
        .select()
        .single();
    return SupabaseMappers.rowToUser(row);
  }

  Future<void> updateUserStatus(String userId, AdminUserStatus status) async {
    await _client
        .from('cuentas')
        .update({'estado': SupabaseMappers.statusToString(status)})
        .eq('id', userId);
  }

  Future<void> updateUser(AdminUserEntity user) async {
    await _client
        .from('cuentas')
        .update(SupabaseMappers.userToRow(user))
        .eq('id', user.id);
  }

  Future<int> getSaldoActual(String userId) async {
    final row = await _client
        .from('cuentas')
        .select('saldo_actual')
        .eq('id', userId)
        .single();
    return (row['saldo_actual'] as num?)?.toInt() ?? 0;
  }

  Future<void> syncSaldoActual(String userId) async {
    final txs = await getTransactions(userId);
    var saldo = 0;
    for (final tx in txs) {
      saldo += tx.type == TransactionType.income ? tx.amount : -tx.amount;
    }
    await _client
        .from('cuentas')
        .update({'saldo_actual': saldo})
        .eq('id', userId);
  }

  // === historial + detalle_historial ========================================================
  Future<HistorialEntity> registrarConsulta({
    required String userId,
    required List<TransactionEntity> movimientosConsultados,
    String accion = 'visualizado',
  }) async {
    final histRow = await _client
        .from('historial')
        .insert({'usuario_id': userId})
        .select()
        .single();

    final historialId    = histRow['id'] as String;
    final fechaConsulta  = DateTime.parse(histRow['fecha_consulta'] as String);

    if (movimientosConsultados.isNotEmpty) {
      final detalles = movimientosConsultados
          .map((tx) => SupabaseMappers.entityToDetalleHistorial(
                historialId: historialId,
                tx: tx,
                accion: accion,
              ))
          .toList();
      await _client.from('detalle_historial').insert(detalles);
    }

    return HistorialEntity(
      id: historialId,
      userId: userId,
      fechaConsulta: fechaConsulta,
      movimientos: movimientosConsultados,
    );
  }

  Future<List<HistorialEntity>> getHistorial(String userId) async {
    final rows = await _client
        .from('historial')
        .select()
        .eq('usuario_id', userId)
        .order('fecha_consulta', ascending: false);
    return rows
        .map((r) => HistorialEntity(
              id: r['id'] as String,
              userId: userId,
              fechaConsulta: DateTime.parse(r['fecha_consulta'] as String),
              movimientos: const [],
            ))
        .toList();
  }

  Future<HistorialEntity> getHistorialConDetalle(String historialId) async {
    final rows = await _client
        .from('detalle_historial')
        .select('*, historial!inner(usuario_id, fecha_consulta)')
        .eq('historial_id', historialId)
        .order('created_at');

    if (rows.isEmpty) {
      final h = await _client
          .from('historial')
          .select()
          .eq('id', historialId)
          .single();
      return HistorialEntity(
        id: historialId,
        userId: h['usuario_id'] as String,
        fechaConsulta: DateTime.parse(h['fecha_consulta'] as String),
        movimientos: const [],
      );
    }

    final histData   = rows.first['historial'] as Map<String, dynamic>;
    final movimientos = rows.map(SupabaseMappers.detalleHistorialToEntity).toList();

    return HistorialEntity(
      id: historialId,
      userId: histData['usuario_id'] as String,
      fechaConsulta: DateTime.parse(histData['fecha_consulta'] as String),
      movimientos: movimientos,
    );
  }

  // === config ========================================================
  Future<Map<String, dynamic>> getConfig() async {
    final row = await _client.from('config_sistema').select().single();
    return {
      'modoOscuro':    row['modo_oscuro_admin']       as bool? ?? false,
      'notificaciones': row['notificaciones_globales'] as bool? ?? true,
      'presupuesto':   (row['presupuesto_global'] as num?)?.toInt() ?? 500000,
    };
  }

  Future<void> saveConfig(Map<String, dynamic> cfg) async {
    await _client.from('config_sistema').update({
      'modo_oscuro_admin':       cfg['modoOscuro']    as bool? ?? false,
      'notificaciones_globales': cfg['notificaciones'] as bool? ?? true,
      'presupuesto_global':      cfg['presupuesto']   as int?  ?? 500000,
    }).eq('id', 1);
  }

  // === onboarding ========================================================
  Future<OnboardingEntity?> getOnboarding(String userId) async {
    final row = await _client
        .from('onboarding')
        .select()
        .eq('usuario_id', userId)
        .maybeSingle();
    if (row == null) return null;
    return SupabaseMappers.rowToOnboarding(row);
  }

  Future<bool> getOnboardingCompletado(String userId) async {
    final ob = await getOnboarding(userId);
    return ob?.completado ?? false;
  }

  Future<void> _upsertOnboarding(
    String userId, {
    required bool completado,
    required int pasoActual,
  }) async {
    final existing = await getOnboarding(userId);
    final data = {
      'usuario_id': userId,
      'completado': completado,
      'paso_actual': pasoActual,
    };
    if (existing == null) {
      await _client.from('onboarding').insert(data);
    } else {
      await _client.from('onboarding').update(data).eq('usuario_id', userId);
    }
  }

  Future<void> iniciarOnboarding(String userId) async {
    final existing = await getOnboarding(userId);
    if (existing != null) return;
    await _client.from('onboarding').insert({
      'usuario_id': userId,
      'completado': false,
      'paso_actual': 0,
    });
  }

  Future<void> setOnboardingPaso(String userId, int paso) async {
    await _upsertOnboarding(userId, completado: false, pasoActual: paso);
  }

  Future<void> completarOnboarding(String userId) async {
    await _upsertOnboarding(userId, completado: true, pasoActual: 3);
  }

  // === presupuestos ========================================================
  static (DateTime, DateTime) _rangoMesActual() {
    final now = DateTime.now();
    final inicio = DateTime(now.year, now.month, 1);
    final fin = DateTime(now.year, now.month + 1, 0);
    return (inicio, fin);
  }

  static String _periodoMes(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}';

  Future<PresupuestoEntity?> getPresupuestoMensual(String userId) async {
    final (inicio, _) = _rangoMesActual();
    final inicioStr =
        '${inicio.year}-${inicio.month.toString().padLeft(2, '0')}-${inicio.day.toString().padLeft(2, '0')}';
    final row = await _client
        .from('presupuestos')
        .select()
        .eq('usuario_id', userId)
        .eq('fecha_inicio', inicioStr)
        .maybeSingle();
    if (row == null) return null;
    return SupabaseMappers.rowToPresupuesto(row);
  }

  Future<PresupuestoEntity> savePresupuestoMensual({
    required String userId,
    required int montoLimite,
  }) async {
    final (inicio, fin) = _rangoMesActual();
    final existing = await getPresupuestoMensual(userId);
    final entity = PresupuestoEntity(
      id: existing?.id ?? '',
      userId: userId,
      montoLimite: montoLimite,
      periodo: 'mensual',
      fechaInicio: inicio,
      fechaFin: fin,
    );

    if (existing != null) {
      final row = await _client
          .from('presupuestos')
          .update(SupabaseMappers.presupuestoToRow(entity))
          .eq('id', existing.id)
          .select()
          .single();
      return SupabaseMappers.rowToPresupuesto(row);
    }

    final row = await _client
        .from('presupuestos')
        .insert(SupabaseMappers.presupuestoToRow(entity))
        .select()
        .single();
    return SupabaseMappers.rowToPresupuesto(row);
  }

  // === metas_ahorro ========================================================
  Future<MetaAhorroEntity?> getMetaAhorroPrincipal(String userId) async {
    final rows = await _client
        .from('metas_ahorro')
        .select()
        .eq('usuario_id', userId)
        .order('fecha_meta', ascending: false)
        .limit(1);
    if (rows.isEmpty) return null;
    return SupabaseMappers.rowToMetaAhorro(rows.first);
  }

  Future<MetaAhorroEntity> saveMetaAhorro({
    required String userId,
    required String nombre,
    required int montoObjetivo,
    int montoActual = 0,
    DateTime? fechaMeta,
  }) async {
    final finMes = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
    final existing = await getMetaAhorroPrincipal(userId);
    final entity = MetaAhorroEntity(
      id: existing?.id ?? '',
      userId: userId,
      nombre: nombre,
      montoObjetivo: montoObjetivo,
      montoActual: existing?.montoActual ?? montoActual,
      fechaMeta: fechaMeta ?? finMes,
    );

    if (existing != null) {
      final row = await _client
          .from('metas_ahorro')
          .update(SupabaseMappers.metaAhorroToRow(entity))
          .eq('id', existing.id)
          .select()
          .single();
      return SupabaseMappers.rowToMetaAhorro(row);
    }

    final row = await _client
        .from('metas_ahorro')
        .insert(SupabaseMappers.metaAhorroToRow(entity))
        .select()
        .single();
    return SupabaseMappers.rowToMetaAhorro(row);
  }

  Future<void> actualizarProgresoMeta(String userId, int montoActual) async {
    final meta = await getMetaAhorroPrincipal(userId);
    if (meta == null) return;
    await _client
        .from('metas_ahorro')
        .update({'monto_actual': montoActual})
        .eq('id', meta.id);
  }

  // === reportes_personales ========================================================
  Future<List<ReportePersonalEntity>> getReportes(String userId) async {
    final rows = await _client
        .from('reportes_personales')
        .select()
        .eq('usuario_id', userId)
        .order('generado_en', ascending: false);
    return rows.map(SupabaseMappers.rowToReporte).toList();
  }

  Future<ReportePersonalEntity?> getReportePorPeriodo(
    String userId,
    String periodo,
  ) async {
    final row = await _client
        .from('reportes_personales')
        .select()
        .eq('usuario_id', userId)
        .eq('periodo', periodo)
        .maybeSingle();
    if (row == null) return null;
    return SupabaseMappers.rowToReporte(row);
  }

  Future<ReportePersonalEntity> guardarReporteMensual({
    required String userId,
    required int totalIngresos,
    required int totalGastos,
    DateTime? ref,
  }) async {
    final d = ref ?? DateTime.now();
    final periodo = _periodoMes(d);
    final existing = await getReportePorPeriodo(userId, periodo);
    final payload = {
      'usuario_id': userId,
      'periodo': periodo,
      'total_ingresos': totalIngresos,
      'total_gastos': totalGastos,
    };

    if (existing != null) {
      final row = await _client
          .from('reportes_personales')
          .update(payload)
          .eq('id', existing.id)
          .select()
          .single();
      return SupabaseMappers.rowToReporte(row);
    }

    final row = await _client
        .from('reportes_personales')
        .insert(payload)
        .select()
        .single();
    return SupabaseMappers.rowToReporte(row);
  }
}