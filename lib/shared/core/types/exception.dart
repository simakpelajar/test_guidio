// shared/core/mappers/dio_failure_mapper.dart
import 'package:dio/dio.dart';
import '../types/failure.dart';

extension DioFailureMapper on DioException {
  Failure toFailure({StackTrace? stackTrace}) {
    switch (type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return NetworkFailure(
          -1,
          'Connection timed out',
          stackTrace: stackTrace,
        );
      case DioExceptionType.connectionError:
        return NetworkFailure(
          -1,
          'No internet connection',
          stackTrace: stackTrace,
        );
      case DioExceptionType.cancel:
        return CancelledFailure(stackTrace: stackTrace);
      default:
        break;
    }

    final status = response?.statusCode ?? -1;
    if (status == 401) return UnauthorizedFailure(stackTrace: stackTrace);
    if (status == 403) return ForbiddenFailure(stackTrace: stackTrace);
    if (status == 404) {
      return NetworkFailure(
        status,
        'Endpoint not found',
        stackTrace: stackTrace,
      );
    }
    if (status == 422) {
      return ValidationFailure(
        _firstErrorMessage(response?.data),
        stackTrace: stackTrace,
      );
    }
    if (status >= 500 && status <= 599) {
      return ServerFailure('Server error ($status)', stackTrace: stackTrace);
    }
    return HttpFailure(
      code: status,
      message: response?.statusMessage ?? message ?? 'Unknown network error',
      stackTrace: stackTrace,
    );
  }

  String _firstErrorMessage(dynamic data) {
    if (data is Map && data['message'] is String)
      return data['message'] as String;
    if (data is Map && data['errors'] is Map) {
      final errs = data['errors'] as Map;
      if (errs.isNotEmpty) {
        final first = errs.values.first;
        if (first is List && first.isNotEmpty && first.first is String) {
          return first.first as String;
        }
      }
    }
    return 'Validation error';
  }
}
