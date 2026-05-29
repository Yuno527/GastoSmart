import 'package:flutter/material.dart';
import 'package:proyecto_movil/domain/entities/transaction_entity.dart';
import 'package:proyecto_movil/domain/entities/admin_entity.dart';
import 'package:proyecto_movil/domain/entities/user_finance_entity.dart';

class SupabaseMappers {
  // ======= iconos ======================================================================
  static const _iconMap = <String, IconData>{
    'restaurant': Icons.restaurant_outlined,
    'cafe':       Icons.local_cafe_outlined,
    'car':        Icons.directions_car_outlined,
    'home':       Icons.home_outlined,
    'devices':    Icons.devices_other_outlined,
    'health':     Icons.favorite_border,
    'label':      Icons.label_outline,
    'school':     Icons.school_outlined,
    'sports':     Icons.sports_esports_outlined,
    'shopping':   Icons.shopping_bag_outlined,
  };

  static IconData _iconFromKey(String k) => _iconMap[k] ?? Icons.label_outline;
  static String _iconToKey(IconData icon) {
    for (final e in _iconMap.entries) {
      if (e.value.codePoint == icon.codePoint) return e.key;
    }
    return 'label';
  }

  static Color _parseColor(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  static String _colorToHex(Color c) {
    final rgb = c.toARGB32() & 0xFFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  // ======= movimientos ======================================================================
  static TransactionEntity movimientoToEntity(Map<String, dynamic> row) {
    return TransactionEntity(
      id:       row['id'] as String,
      userId:   row['usuario_id'] as String,
      type:     (row['tipo'] as String) == 'ingreso'
                  ? TransactionType.income
                  : TransactionType.expense,
      amount:   (row['monto'] as num).toInt(),
      category: row['categoria_nombre'] as String? ?? '',
      date:     DateTime.parse(row['fecha'] as String),
      note:     row['nota'] as String? ?? '',
    );
  }

  static Map<String, dynamic> entityToMovimiento(TransactionEntity tx) {
    final f = tx.date;
    return {
      if (tx.id.isNotEmpty) 'id': tx.id,
      'usuario_id':       tx.userId,
      'tipo':             tx.type == TransactionType.income ? 'ingreso' : 'gasto',
      'monto':            tx.amount,
      'categoria_nombre': tx.category,
      'fecha': '${f.year}-${f.month.toString().padLeft(2,'0')}-${f.day.toString().padLeft(2,'0')}',
      'nota':             tx.note,
    };
  }

  // ======= detalle_historial ======================================================================
  static Map<String, dynamic> entityToDetalleHistorial({
    required String historialId,
    required TransactionEntity tx,
    required String accion,
  }) {
    final f = tx.date;
    return {
      'historial_id':       historialId,
      'movimiento_id':      tx.id,
      'tipo_snapshot':      tx.type == TransactionType.income ? 'ingreso' : 'gasto',
      'monto_snapshot':     tx.amount,
      'categoria_snapshot': tx.category,
      'fecha_snapshot': '${f.year}-${f.month.toString().padLeft(2,'0')}-${f.day.toString().padLeft(2,'0')}',
      'nota_snapshot':      tx.note,
      'accion':             accion,
    };
  }

  static TransactionEntity detalleHistorialToEntity(Map<String, dynamic> row) {
    return TransactionEntity(
      id:       row['movimiento_id'] as String,
      userId:   '',
      type:     (row['tipo_snapshot'] as String) == 'ingreso'
                  ? TransactionType.income
                  : TransactionType.expense,
      amount:   (row['monto_snapshot'] as num).toInt(),
      category: row['categoria_snapshot'] as String? ?? '',
      date:     DateTime.parse(row['fecha_snapshot'] as String),
      note:     row['nota_snapshot'] as String? ?? '',
    );
  }

  // ======= categorías ======================================================================
  static AdminCategoryEntity rowToCategory(Map<String, dynamic> row) {
    return AdminCategoryEntity(
      id:    row['id'] as String,
      name:  row['nombre'] as String,
      icon:  _iconFromKey(row['icono'] as String? ?? 'label'),
      color: _parseColor(row['color'] as String? ?? '#607D8B'),
    );
  }

  static Map<String, dynamic> categoryToRow(
    AdminCategoryEntity cat, {
    String? userId,
  }) {
    return {
      if (cat.id.isNotEmpty) 'id': cat.id,
      'nombre': cat.name,
      'icono':  _iconToKey(cat.icon),
      'color':  _colorToHex(cat.color),
      'activa': true,
      if (userId != null) 'usuario_id': userId,
    };
  }

  // ======= usuarios ======================================================================
  static AdminUserEntity rowToUser(Map<String, dynamic> row) {
    AdminUserStatus status;
    switch (row['estado'] as String? ?? 'activo') {
      case 'inactivo':  status = AdminUserStatus.inactive; break;
      case 'bloqueado': status = AdminUserStatus.blocked;  break;
      default:          status = AdminUserStatus.active;
    }
    AdminUserRole role = (row['rol'] as String? ?? 'usuario') == 'admin'
        ? AdminUserRole.admin
        : AdminUserRole.user;

    return AdminUserEntity(
      id:        row['id'] as String,
      name:      row['nombre'] as String,
      email:     row['correo'] as String,
      password:  row['contrasena'] as String? ?? '',
      createdAt: DateTime.parse(row['fecha_registro'] as String),
      status:    status,
      role:      role,
      saldoActual: (row['saldo_actual'] as num?)?.toInt() ?? 0,
    );
  }

  static Map<String, dynamic> userToRow(AdminUserEntity u) {
    return {
      if (u.id.isNotEmpty) 'id': u.id,
      'nombre':      u.name,
      'correo':      u.email,
      'contrasena':  u.password,
      'estado':      statusToString(u.status),
      'rol':         u.role == AdminUserRole.admin ? 'admin' : 'usuario',
      'saldo_actual': u.saldoActual,
    };
  }

  static String statusToString(AdminUserStatus s) {
    switch (s) {
      case AdminUserStatus.inactive: return 'inactivo';
      case AdminUserStatus.blocked:  return 'bloqueado';
      default:                       return 'activo';
    }
  }

  static String _dateOnly(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ======= presupuestos ======================================================================
  static PresupuestoEntity rowToPresupuesto(Map<String, dynamic> row) {
    return PresupuestoEntity(
      id:          row['id'] as String,
      userId:      row['usuario_id'] as String,
      montoLimite: (row['monto_limite'] as num).toInt(),
      periodo:     row['periodo'] as String,
      fechaInicio: DateTime.parse(row['fecha_inicio'] as String),
      fechaFin:    DateTime.parse(row['fecha_fin'] as String),
    );
  }

  static Map<String, dynamic> presupuestoToRow(PresupuestoEntity p) {
    return {
      if (p.id.isNotEmpty) 'id': p.id,
      'usuario_id':   p.userId,
      'monto_limite': p.montoLimite,
      'periodo':      p.periodo,
      'fecha_inicio': _dateOnly(p.fechaInicio),
      'fecha_fin':    _dateOnly(p.fechaFin),
    };
  }

  // ======= metas_ahorro ======================================================================
  static MetaAhorroEntity rowToMetaAhorro(Map<String, dynamic> row) {
    return MetaAhorroEntity(
      id:            row['id'] as String,
      userId:        row['usuario_id'] as String,
      nombre:        row['nombre'] as String,
      montoObjetivo: (row['monto_objetivo'] as num).toInt(),
      montoActual:   (row['monto_actual'] as num?)?.toInt() ?? 0,
      fechaMeta:     DateTime.parse(row['fecha_meta'] as String),
    );
  }

  static Map<String, dynamic> metaAhorroToRow(MetaAhorroEntity m) {
    return {
      if (m.id.isNotEmpty) 'id': m.id,
      'usuario_id':     m.userId,
      'nombre':         m.nombre,
      'monto_objetivo': m.montoObjetivo,
      'monto_actual':   m.montoActual,
      'fecha_meta':     _dateOnly(m.fechaMeta),
    };
  }

  // ======= reportes_personales ======================================================================
  static ReportePersonalEntity rowToReporte(Map<String, dynamic> row) {
    return ReportePersonalEntity(
      id:            row['id'] as String,
      userId:        row['usuario_id'] as String,
      periodo:       row['periodo'] as String,
      totalIngresos: (row['total_ingresos'] as num).toInt(),
      totalGastos:   (row['total_gastos'] as num).toInt(),
      balance:       (row['balance'] as num).toInt(),
      generadoEn:    DateTime.parse(row['generado_en'] as String),
    );
  }

  static Map<String, dynamic> reporteToRow(ReportePersonalEntity r) {
    return {
      if (r.id.isNotEmpty) 'id': r.id,
      'usuario_id':     r.userId,
      'periodo':        r.periodo,
      'total_ingresos': r.totalIngresos,
      'total_gastos':   r.totalGastos,
      // balance es columna generada en Postgres (total_ingresos - total_gastos)
    };
  }

  // ======= onboarding ======================================================================
  static OnboardingEntity rowToOnboarding(Map<String, dynamic> row) {
    return OnboardingEntity(
      id:         row['id'] as String,
      userId:     row['usuario_id'] as String,
      completado: row['completado'] as bool? ?? false,
      pasoActual: row['paso_actual'] as int? ?? 0,
    );
  }
}