import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @mode_detection.
  ///
  /// In en, this message translates to:
  /// **'Mode: Object Detection'**
  String get mode_detection;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Guidio'**
  String get greeting;

  /// No description provided for @status_streaming.
  ///
  /// In en, this message translates to:
  /// **'Streaming'**
  String get status_streaming;

  /// No description provided for @status_stopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get status_stopped;

  /// No description provided for @mic_start.
  ///
  /// In en, this message translates to:
  /// **'Start microphone'**
  String get mic_start;

  /// No description provided for @mic_stop.
  ///
  /// In en, this message translates to:
  /// **'Stop microphone'**
  String get mic_stop;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @camera_permission_required.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required'**
  String get camera_permission_required;

  /// No description provided for @camera_processing.
  ///
  /// In en, this message translates to:
  /// **'Processing camera...'**
  String get camera_processing;

  /// No description provided for @camera_turn_off.
  ///
  /// In en, this message translates to:
  /// **'Turn off camera'**
  String get camera_turn_off;

  /// No description provided for @camera_turn_on.
  ///
  /// In en, this message translates to:
  /// **'Turn on camera'**
  String get camera_turn_on;

  /// No description provided for @mic_turn_off.
  ///
  /// In en, this message translates to:
  /// **'Turn off microphone'**
  String get mic_turn_off;

  /// No description provided for @mic_turn_on.
  ///
  /// In en, this message translates to:
  /// **'Turn on microphone'**
  String get mic_turn_on;

  /// No description provided for @camera_health_check.
  ///
  /// In en, this message translates to:
  /// **'Check camera health'**
  String get camera_health_check;

  /// No description provided for @camera_health_check_enable_hint.
  ///
  /// In en, this message translates to:
  /// **'Turn on camera to check health'**
  String get camera_health_check_enable_hint;

  /// No description provided for @detection_sample.
  ///
  /// In en, this message translates to:
  /// **'There is a laptop one meter in front of you'**
  String get detection_sample;

  /// No description provided for @camera_not_ready.
  ///
  /// In en, this message translates to:
  /// **'Camera is not ready. Please wait...'**
  String get camera_not_ready;

  /// No description provided for @health_orientation_skipped.
  ///
  /// In en, this message translates to:
  /// **'Orientation: Skipped validation'**
  String get health_orientation_skipped;

  /// No description provided for @health_alert_too_fast.
  ///
  /// In en, this message translates to:
  /// **'Movement too fast, please slow down'**
  String get health_alert_too_fast;

  /// No description provided for @health_alert_dark.
  ///
  /// In en, this message translates to:
  /// **'Lighting is too dark'**
  String get health_alert_dark;

  /// No description provided for @health_alert_lens_blocked.
  ///
  /// In en, this message translates to:
  /// **'Camera is blocked, check the lens'**
  String get health_alert_lens_blocked;

  /// No description provided for @health_analyze_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to analyze frame. Please try again.'**
  String get health_analyze_failed;

  /// No description provided for @health_blur_bad.
  ///
  /// In en, this message translates to:
  /// **'Blur: Too blurry (score: {score})'**
  String health_blur_bad(Object score);

  /// No description provided for @health_blur_good.
  ///
  /// In en, this message translates to:
  /// **'Blur: Movement is stable (score: {score})'**
  String health_blur_good(Object score);

  /// No description provided for @health_light_bad.
  ///
  /// In en, this message translates to:
  /// **'Light: Too dark ({percent}%)'**
  String health_light_bad(Object percent);

  /// No description provided for @health_light_good.
  ///
  /// In en, this message translates to:
  /// **'Light: Sufficient ({percent}%)'**
  String health_light_good(Object percent);

  /// No description provided for @health_lens_bad.
  ///
  /// In en, this message translates to:
  /// **'Lens: Blocked ({percent}% dark)'**
  String health_lens_bad(Object percent);

  /// No description provided for @health_lens_good.
  ///
  /// In en, this message translates to:
  /// **'Lens: Clear ({percent}% dark)'**
  String health_lens_good(Object percent);

  /// No description provided for @health_ready_message.
  ///
  /// In en, this message translates to:
  /// **'Camera is ready for navigation!'**
  String get health_ready_message;

  /// No description provided for @health_issues_message.
  ///
  /// In en, this message translates to:
  /// **'Issues detected:'**
  String get health_issues_message;

  /// No description provided for @health_action_label.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get health_action_label;

  /// No description provided for @health_ready_title.
  ///
  /// In en, this message translates to:
  /// **'Camera Ready'**
  String get health_ready_title;

  /// No description provided for @health_issues_title.
  ///
  /// In en, this message translates to:
  /// **'Issues Found'**
  String get health_issues_title;

  /// No description provided for @error_prefix.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error_prefix;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
