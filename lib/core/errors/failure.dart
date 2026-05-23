abstract class Failure {
  final String message;
  const Failure(this.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Error desconocido']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Datos inválidos']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Error de almacenamiento local']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Error de red']);
}
