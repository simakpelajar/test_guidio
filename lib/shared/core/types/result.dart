import 'package:dio/dio.dart';
import 'package:test_guidio/shared/core/types/exception.dart';
import 'package:test_guidio/shared/core/types/failure.dart';

class Unit {
  const Unit();
}

sealed class Result<T> {
  const Result();
  R fold<R>(R Function(Failure) onErr, R Function(T) onOk);

  bool get isOk => this is Ok<T>;
  bool get isErr => this is Err<T>;
}

class Ok<T> extends Result<T> {
  final T value;
  const Ok(this.value);

  @override
  R fold<R>(R Function(Failure) onErr, R Function(T) onOk) => onOk(value);
}

class Err<T> extends Result<T> {
  final Failure failure;
  const Err(this.failure);

  @override
  R fold<R>(R Function(Failure) onErr, R Function(T) onOk) => onErr(failure);
}

Future<Result<T>> guard<T>(Future<T> Function() task) async {
  try {
    final value = await task();
    return Ok(value);
  } on Failure catch (f) {
    return Err(f);
  } on DioException catch (e, st) {
    return Err(e.toFailure(stackTrace: st));
  } on Exception catch (e, st) {
    return Err(UnknownFailure(e, stackTrace: st));
  }
}
