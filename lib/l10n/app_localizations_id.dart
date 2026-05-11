// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get mode_detection => 'Mode: Deteksi Objek';

  @override
  String get greeting => 'Selamat datang di Guidio';

  @override
  String get status_streaming => 'Sedang merekam';

  @override
  String get status_stopped => 'Berhenti';

  @override
  String get mic_start => 'Mulai mikrofon';

  @override
  String get mic_stop => 'Hentikan mikrofon';

  @override
  String get camera => 'Kamera';

  @override
  String get other => 'Lainnya';
}
