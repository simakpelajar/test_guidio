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

  @override
  String get camera_permission_required => 'Camera permission is required';

  @override
  String get camera_processing => 'Processing camera...';

  @override
  String get camera_turn_off => 'Turn off camera';

  @override
  String get camera_turn_on => 'Turn on camera';

  @override
  String get mic_turn_off => 'Turn off microphone';

  @override
  String get mic_turn_on => 'Turn on microphone';

  @override
  String get camera_health_check => 'Check camera health';

  @override
  String get camera_health_check_enable_hint =>
      'Turn on camera to check health';

  @override
  String get detection_sample => 'There is a laptop one meter in front of you';

  @override
  String get camera_not_ready => 'Camera is not ready. Please wait...';

  @override
  String get health_orientation_skipped => 'Orientation: Skipped validation';

  @override
  String get health_alert_too_fast => 'Movement too fast, please slow down';

  @override
  String get health_alert_dark => 'Lighting is too dark';

  @override
  String get health_alert_lens_blocked => 'Camera is blocked, check the lens';

  @override
  String get health_analyze_failed =>
      'Failed to analyze frame. Please try again.';

  @override
  String health_blur_bad(Object score) {
    return 'Blur: Too blurry (score: $score)';
  }

  @override
  String health_blur_good(Object score) {
    return 'Blur: Movement is stable (score: $score)';
  }

  @override
  String health_light_bad(Object percent) {
    return 'Light: Too dark ($percent%)';
  }

  @override
  String health_light_good(Object percent) {
    return 'Light: Sufficient ($percent%)';
  }

  @override
  String health_lens_bad(Object percent) {
    return 'Lens: Blocked ($percent% dark)';
  }

  @override
  String health_lens_good(Object percent) {
    return 'Lens: Clear ($percent% dark)';
  }

  @override
  String get health_ready_message => 'Camera is ready for navigation!';

  @override
  String get health_issues_message => 'Issues detected:';

  @override
  String get health_action_label => 'Action';

  @override
  String get health_ready_title => 'Camera Ready';

  @override
  String get health_issues_title => 'Issues Found';

  @override
  String get error_prefix => 'Error';
}
