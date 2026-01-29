/// Base exception class for the application
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, [this.code]);

  @override
  String toString() =>
      'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Exception thrown when local storage operations fail
class StorageException extends AppException {
  const StorageException(super.message, [super.code]);
}

/// Exception thrown when data validation fails
class ValidationException extends AppException {
  const ValidationException(super.message, [super.code]);
}

/// Exception thrown when network operations fail
class NetworkException extends AppException {
  const NetworkException(super.message, [super.code]);
}

/// Exception thrown when file operations fail
class FileException extends AppException {
  const FileException(super.message, [super.code]);
}
