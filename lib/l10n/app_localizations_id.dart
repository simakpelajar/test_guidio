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

  @override
  String get camera_permission_required => 'Izin kamera diperlukan';

  @override
  String get camera_processing => 'Memproses kamera...';

  @override
  String get camera_turn_off => 'Matikan Kamera';

  @override
  String get camera_turn_on => 'Nyalakan Kamera';

  @override
  String get mic_turn_off => 'Matikan Mikrofon';

  @override
  String get mic_turn_on => 'Nyalakan Mikrofon';

  @override
  String get camera_health_check => 'Cek Kesehatan Kamera';

  @override
  String get camera_health_check_enable_hint =>
      'Nyalakan kamera untuk cek kesehatan';

  @override
  String get detection_sample => '1 meter ada laptop depan anda';

  @override
  String get camera_not_ready => 'Kamera belum siap. Mohon tunggu...';

  @override
  String get health_orientation_skipped => 'Orientasi: Tidak perlu validasi';

  @override
  String get health_alert_too_fast => 'Gerakan terlalu cepat, mohon perlahan';

  @override
  String get health_alert_dark => 'Cahaya terlalu gelap';

  @override
  String get health_alert_lens_blocked => 'Kamera tertutup, periksa lensa';

  @override
  String get health_analyze_failed => 'Gagal menganalisis frame. Coba lagi.';

  @override
  String health_blur_bad(Object score) {
    return 'Blur: Terlalu blur (score: $score)';
  }

  @override
  String health_blur_good(Object score) {
    return 'Blur: Pergerakan stabil (score: $score)';
  }

  @override
  String health_light_bad(Object percent) {
    return 'Cahaya: Terlalu gelap ($percent%)';
  }

  @override
  String health_light_good(Object percent) {
    return 'Cahaya: Cukup ($percent%)';
  }

  @override
  String health_lens_bad(Object percent) {
    return 'Lensa: Tertutup ($percent% gelap)';
  }

  @override
  String health_lens_good(Object percent) {
    return 'Lensa: Bersih ($percent% gelap)';
  }

  @override
  String get health_ready_message => 'Kamera siap untuk navigasi!';

  @override
  String get health_issues_message => 'Ada masalah:';

  @override
  String get health_action_label => 'Aksi';

  @override
  String get health_ready_title => 'Kamera Siap';

  @override
  String get health_issues_title => 'Ada Masalah';

  @override
  String get error_prefix => 'Error';
}
