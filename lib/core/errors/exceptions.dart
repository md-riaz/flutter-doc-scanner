class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AppException({
    required this.message,
    this.code,
    this.details,
  });

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException({
    required super.message,
    super.code,
    super.details,
  });
}

class AuthException extends AppException {
  AuthException({
    required super.message,
    super.code,
    super.details,
  });
}

class ValidationException extends AppException {
  ValidationException({
    required super.message,
    super.code,
    super.details,
  });
}

class StorageException extends AppException {
  StorageException({
    required super.message,
    super.code,
    super.details,
  });
}

class CameraException extends AppException {
  CameraException({
    required super.message,
    super.code,
    super.details,
  });
}

class PdfException extends AppException {
  PdfException({
    required super.message,
    super.code,
    super.details,
  });
}
