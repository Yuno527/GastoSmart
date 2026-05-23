class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'CacheException']);
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'NetworkException']);
}

class ValidationException implements Exception {
  final String message;
  ValidationException([this.message = 'ValidationException']);
}
