// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get mode_detection => 'Mode: Object Detection';

  @override
  String get greeting => 'Welcome to Guidio';

  @override
  String get status_streaming => 'Streaming';

  @override
  String get status_stopped => 'Stopped';

  @override
  String get mic_start => 'Start microphone';

  @override
  String get mic_stop => 'Stop microphone';

  @override
  String get camera => 'Camera';

  @override
  String get other => 'Other';
}
