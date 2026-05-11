sealed class Failure {
  const Failure({this.stackTrace});
  final StackTrace? stackTrace;
}

class NetworkFailure extends Failure {
  final int code;
  final String message;
  const NetworkFailure(this.code, this.message, {super.stackTrace});
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.stackTrace});
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure({super.stackTrace});
}

class ValidationFailure extends Failure {
  final String message;
  const ValidationFailure(this.message, {super.stackTrace});
}

class CancelledFailure extends Failure {
  const CancelledFailure({super.stackTrace});
}

class ServerFailure extends Failure {
  final String message;
  const ServerFailure(this.message, {super.stackTrace});
}

class HttpFailure extends Failure {
  final int? code;
  final String? message;
  const HttpFailure({this.code, this.message, super.stackTrace});
}

class DatabaseFailure extends Failure {
  final String message;
  const DatabaseFailure(this.message, {super.stackTrace});
}

class UnknownFailure extends Failure {
  final Object error;
  const UnknownFailure(this.error, {required super.stackTrace});
}

String errorToMessage(Object error) {
  if (error is Failure) {
    return switch (error) {
      UnauthorizedFailure() => 'Session expired. Please sign in again.',
      ForbiddenFailure() => 'You dont have permission.',
      ValidationFailure(:final message) =>
        message.isEmpty ? 'Validation failed.' : message,
      NetworkFailure(:final code, :final message) =>
        'Network error (${code}). ${message.isEmpty ? "Check your connection." : message}',
      ServerFailure(:final message) =>
        'Server error. ${message.isEmpty ? "Try again." : message}',
      HttpFailure(:final code, :final message) =>
        'HTTP ${code ?? "-"}: ${message ?? "Something went wrong."}',
      DatabaseFailure(:final message) => message,
      UnknownFailure(:final error) => 'Unexpected error: $error',
      _ => 'Something went wrong.',
    };
  }
  return error.toString();
}
