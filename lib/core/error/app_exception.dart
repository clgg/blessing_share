class AppException implements Exception {
  const AppException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

class DataFormatException extends AppException {
  const DataFormatException(super.message, {super.cause});
}

class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.cause});
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.cause});
}

class AppTimeoutException extends NetworkException {
  const AppTimeoutException(super.message, {super.cause});
}

class RequestCancelledException extends NetworkException {
  const RequestCancelledException(super.message, {super.cause});
}
