class PresupuestoEntity {
  final String id;
  final String userId;
  final int montoLimite;
  final String periodo;
  final DateTime fechaInicio;
  final DateTime fechaFin;

  const PresupuestoEntity({
    required this.id,
    required this.userId,
    required this.montoLimite,
    required this.periodo,
    required this.fechaInicio,
    required this.fechaFin,
  });
}

class MetaAhorroEntity {
  final String id;
  final String userId;
  final String nombre;
  final int montoObjetivo;
  final int montoActual;
  final DateTime fechaMeta;

  const MetaAhorroEntity({
    required this.id,
    required this.userId,
    required this.nombre,
    required this.montoObjetivo,
    required this.montoActual,
    required this.fechaMeta,
  });

  double get progreso =>
      montoObjetivo <= 0 ? 0 : (montoActual / montoObjetivo).clamp(0.0, 1.0);
}

class ReportePersonalEntity {
  final String id;
  final String userId;
  final String periodo;
  final int totalIngresos;
  final int totalGastos;
  final int balance;
  final DateTime generadoEn;

  const ReportePersonalEntity({
    required this.id,
    required this.userId,
    required this.periodo,
    required this.totalIngresos,
    required this.totalGastos,
    required this.balance,
    required this.generadoEn,
  });
}

class OnboardingEntity {
  final String id;
  final String userId;
  final bool completado;
  final int pasoActual;

  const OnboardingEntity({
    required this.id,
    required this.userId,
    required this.completado,
    required this.pasoActual,
  });
}
