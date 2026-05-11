import 'dart:developer' as developer;

import 'package:logging/logging.dart';

bool _loggingInitialized = false;

void initAppLogging({Level level = Level.INFO}) {
  if (_loggingInitialized) return;

  _loggingInitialized = true;
  Logger.root.level = level;
  Logger.root.onRecord.listen((record) {
    developer.log(
      record.message,
      time: record.time,
      name: record.loggerName,
      level: record.level.value,
      error: record.error,
      stackTrace: record.stackTrace,
    );
  });
}

Logger getLogger(String scope) => Logger(scope);
