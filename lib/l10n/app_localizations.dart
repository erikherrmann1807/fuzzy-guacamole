import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

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
    Locale('de'),
    Locale('en'),
  ];

  /// Titel und Button des Login-Screens
  ///
  /// In de, this message translates to:
  /// **'Login'**
  String get login;

  /// Titel und Button des Registrierungs-Screens
  ///
  /// In de, this message translates to:
  /// **'Registrieren'**
  String get register;

  /// No description provided for @email.
  ///
  /// In de, this message translates to:
  /// **'E-Mail'**
  String get email;

  /// No description provided for @password.
  ///
  /// In de, this message translates to:
  /// **'Passwort'**
  String get password;

  /// No description provided for @username.
  ///
  /// In de, this message translates to:
  /// **'Nutzername'**
  String get username;

  /// No description provided for @oldPassword.
  ///
  /// In de, this message translates to:
  /// **'Altes Passwort'**
  String get oldPassword;

  /// No description provided for @newPassword.
  ///
  /// In de, this message translates to:
  /// **'Neues Passwort'**
  String get newPassword;

  /// No description provided for @enterEmail.
  ///
  /// In de, this message translates to:
  /// **'E-Mail-Adresse eingeben'**
  String get enterEmail;

  /// No description provided for @invalidEmail.
  ///
  /// In de, this message translates to:
  /// **'Bitte eine gültige E-Mail-Adresse eingeben'**
  String get invalidEmail;

  /// No description provided for @enterPassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort eingeben'**
  String get enterPassword;

  /// No description provided for @invalidPassword.
  ///
  /// In de, this message translates to:
  /// **'Das Passwort muss mindestens acht Zeichen, davon mindestens einen Buchstaben und eine Zahl enthalten'**
  String get invalidPassword;

  /// No description provided for @enterUsername.
  ///
  /// In de, this message translates to:
  /// **'Nutzernamen eingeben'**
  String get enterUsername;

  /// No description provided for @invalidUsername.
  ///
  /// In de, this message translates to:
  /// **'Der Nutzername muss 8–20 Zeichen lang sein.\nKein \"_\" oder \".\" am Anfang.\nKein \"__\", \"_.\", \"._\" oder \"..\" im Namen.\nKein \"_\" oder \".\" am Ende.'**
  String get invalidUsername;

  /// No description provided for @noAccountYet.
  ///
  /// In de, this message translates to:
  /// **'Noch keinen Account?'**
  String get noAccountYet;

  /// No description provided for @registerHere.
  ///
  /// In de, this message translates to:
  /// **'Hier registrieren!'**
  String get registerHere;

  /// Begrüßung in der AppBar
  ///
  /// In de, this message translates to:
  /// **'Hallo👋, {username}!'**
  String greeting(String username);

  /// No description provided for @defaultUsername.
  ///
  /// In de, this message translates to:
  /// **'Nutzer'**
  String get defaultUsername;

  /// No description provided for @accountManagementTitle.
  ///
  /// In de, this message translates to:
  /// **'Account-Verwaltung'**
  String get accountManagementTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get settingsTitle;

  /// No description provided for @retry.
  ///
  /// In de, this message translates to:
  /// **'Erneut versuchen'**
  String get retry;

  /// No description provided for @errorWithMessage.
  ///
  /// In de, this message translates to:
  /// **'Fehler: {message}'**
  String errorWithMessage(String message);

  /// No description provided for @loadingError.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Laden: {message}'**
  String loadingError(String message);

  /// No description provided for @currentTasks.
  ///
  /// In de, this message translates to:
  /// **'Aktuelle Aufgaben'**
  String get currentTasks;

  /// No description provided for @loadingTodaysAppointments.
  ///
  /// In de, this message translates to:
  /// **'Lade heutige Termine …'**
  String get loadingTodaysAppointments;

  /// No description provided for @loadingWeather.
  ///
  /// In de, this message translates to:
  /// **'Wetter laden …'**
  String get loadingWeather;

  /// No description provided for @noAppointments.
  ///
  /// In de, this message translates to:
  /// **'Keine Termine'**
  String get noAppointments;

  /// No description provided for @noAppointmentsToday.
  ///
  /// In de, this message translates to:
  /// **'Keine Termine für heute'**
  String get noAppointmentsToday;

  /// Anzahl der heutigen Termine auf dem Home-Screen
  ///
  /// In de, this message translates to:
  /// **'{count, plural, one{Du hast 1 Termin heute} other{Du hast {count} Termine heute}}'**
  String appointmentsTodayCount(int count);

  /// No description provided for @agendaForDate.
  ///
  /// In de, this message translates to:
  /// **'Agenda für {date}'**
  String agendaForDate(String date);

  /// No description provided for @allDay.
  ///
  /// In de, this message translates to:
  /// **'Ganztägig'**
  String get allDay;

  /// Suffix hinter Terminnamen bei mehrtägigen Terminen
  ///
  /// In de, this message translates to:
  /// **' (Tag {dayIndex}/{totalDays})'**
  String multiDaySuffix(int dayIndex, int totalDays);

  /// No description provided for @selectMonthAndYear.
  ///
  /// In de, this message translates to:
  /// **'Monat und Jahr wählen'**
  String get selectMonthAndYear;

  /// No description provided for @ok.
  ///
  /// In de, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get cancel;

  /// No description provided for @newEvent.
  ///
  /// In de, this message translates to:
  /// **'Neuer Termin'**
  String get newEvent;

  /// No description provided for @eventDetails.
  ///
  /// In de, this message translates to:
  /// **'Termindetails'**
  String get eventDetails;

  /// No description provided for @addTitle.
  ///
  /// In de, this message translates to:
  /// **'Titel hinzufügen'**
  String get addTitle;

  /// No description provided for @addDescription.
  ///
  /// In de, this message translates to:
  /// **'Beschreibung hinzufügen'**
  String get addDescription;

  /// No description provided for @noTitle.
  ///
  /// In de, this message translates to:
  /// **'(Ohne Titel)'**
  String get noTitle;

  /// No description provided for @selectDate.
  ///
  /// In de, this message translates to:
  /// **'Datum auswählen'**
  String get selectDate;

  /// No description provided for @saveMeetingFailed.
  ///
  /// In de, this message translates to:
  /// **'Der Termin konnte nicht gespeichert werden.'**
  String get saveMeetingFailed;

  /// No description provided for @deleteMeetingFailed.
  ///
  /// In de, this message translates to:
  /// **'Der Termin konnte nicht gelöscht werden.'**
  String get deleteMeetingFailed;

  /// No description provided for @priorityHigh.
  ///
  /// In de, this message translates to:
  /// **'Hoch'**
  String get priorityHigh;

  /// No description provided for @priorityLow.
  ///
  /// In de, this message translates to:
  /// **'Niedrig'**
  String get priorityLow;

  /// No description provided for @resetPassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort zurücksetzen'**
  String get resetPassword;

  /// No description provided for @resetPasswordInfo.
  ///
  /// In de, this message translates to:
  /// **'Um Ihr Passwort zurückzusetzen, wird Ihnen eine E-Mail mit einem Link zum Zurücksetzen zugeschickt.'**
  String get resetPasswordInfo;

  /// No description provided for @updateUsername.
  ///
  /// In de, this message translates to:
  /// **'Nutzernamen ändern'**
  String get updateUsername;

  /// No description provided for @updateUsernameInfo.
  ///
  /// In de, this message translates to:
  /// **'Geben Sie in folgendem Feld Ihren neuen Nutzernamen ein und bestätigen Sie die Änderung mit dem Button am Ende.'**
  String get updateUsernameInfo;

  /// No description provided for @deleteAccount.
  ///
  /// In de, this message translates to:
  /// **'Account löschen'**
  String get deleteAccount;

  /// No description provided for @deleteAccountInfo.
  ///
  /// In de, this message translates to:
  /// **'Um Ihren Account zu löschen, müssen Sie Ihre E-Mail und Ihr Passwort angeben.'**
  String get deleteAccountInfo;

  /// No description provided for @updatePassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort ändern'**
  String get updatePassword;

  /// No description provided for @updatePasswordInfo.
  ///
  /// In de, this message translates to:
  /// **'Um Ihr Passwort zu ändern, benötigen Sie das aktuelle und ein neues Passwort.'**
  String get updatePasswordInfo;

  /// No description provided for @logout.
  ///
  /// In de, this message translates to:
  /// **'Abmelden'**
  String get logout;

  /// No description provided for @wrongCurrentPassword.
  ///
  /// In de, this message translates to:
  /// **'Das aktuelle Passwort ist nicht korrekt.'**
  String get wrongCurrentPassword;

  /// No description provided for @wrongEmailOrPassword.
  ///
  /// In de, this message translates to:
  /// **'E-Mail oder Passwort ist nicht korrekt.'**
  String get wrongEmailOrPassword;

  /// No description provided for @noUserSignedIn.
  ///
  /// In de, this message translates to:
  /// **'Kein Nutzer angemeldet.'**
  String get noUserSignedIn;

  /// No description provided for @deleteUserDataFailed.
  ///
  /// In de, this message translates to:
  /// **'Nutzerdaten konnten nicht gelöscht werden: {message}'**
  String deleteUserDataFailed(String message);

  /// No description provided for @languageGerman.
  ///
  /// In de, this message translates to:
  /// **'Deutsch'**
  String get languageGerman;

  /// No description provided for @languageEnglish.
  ///
  /// In de, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @reminder.
  ///
  /// In de, this message translates to:
  /// **'Erinnerung'**
  String get reminder;

  /// No description provided for @reminderNone.
  ///
  /// In de, this message translates to:
  /// **'Keine Erinnerung'**
  String get reminderNone;

  /// No description provided for @reminderAtStart.
  ///
  /// In de, this message translates to:
  /// **'Zum Startzeitpunkt'**
  String get reminderAtStart;

  /// No description provided for @reminderMinutesBefore.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, one{1 Minute vorher} other{{count} Minuten vorher}}'**
  String reminderMinutesBefore(int count);

  /// No description provided for @reminderHoursBefore.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, one{1 Stunde vorher} other{{count} Stunden vorher}}'**
  String reminderHoursBefore(int count);

  /// No description provided for @reminderDaysBefore.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, one{1 Tag vorher} other{{count} Tage vorher}}'**
  String reminderDaysBefore(int count);

  /// Text der Termin-Erinnerungs-Benachrichtigung
  ///
  /// In de, this message translates to:
  /// **'Beginnt um {time}'**
  String meetingReminderBody(String time);

  /// No description provided for @taskReminderBody.
  ///
  /// In de, this message translates to:
  /// **'Daily Task fällig'**
  String get taskReminderBody;

  /// Titel des Daily-Tasks-Dialogs
  ///
  /// In de, this message translates to:
  /// **'Aufgaben am {date}'**
  String dailyTasksTitle(String date);

  /// No description provided for @dailyTasksTooltip.
  ///
  /// In de, this message translates to:
  /// **'Aufgaben des Tages'**
  String get dailyTasksTooltip;

  /// No description provided for @noTasksForDay.
  ///
  /// In de, this message translates to:
  /// **'Keine Aufgaben für diesen Tag.'**
  String get noTasksForDay;

  /// No description provided for @newTaskHint.
  ///
  /// In de, this message translates to:
  /// **'Neue Aufgabe'**
  String get newTaskHint;

  /// No description provided for @addTask.
  ///
  /// In de, this message translates to:
  /// **'Aufgabe hinzufügen'**
  String get addTask;

  /// No description provided for @deleteTask.
  ///
  /// In de, this message translates to:
  /// **'Aufgabe löschen'**
  String get deleteTask;

  /// No description provided for @pickReminderTime.
  ///
  /// In de, this message translates to:
  /// **'Erinnerungszeit wählen'**
  String get pickReminderTime;

  /// No description provided for @taskReminderAt.
  ///
  /// In de, this message translates to:
  /// **'Erinnerung um {time}'**
  String taskReminderAt(String time);

  /// No description provided for @saveTaskFailed.
  ///
  /// In de, this message translates to:
  /// **'Die Aufgabe konnte nicht gespeichert werden.'**
  String get saveTaskFailed;

  /// No description provided for @deleteTaskFailed.
  ///
  /// In de, this message translates to:
  /// **'Die Aufgabe konnte nicht gelöscht werden.'**
  String get deleteTaskFailed;

  /// No description provided for @dayViewTooltip.
  ///
  /// In de, this message translates to:
  /// **'Tagesansicht'**
  String get dayViewTooltip;

  /// No description provided for @previousDay.
  ///
  /// In de, this message translates to:
  /// **'Vorheriger Tag'**
  String get previousDay;

  /// No description provided for @nextDay.
  ///
  /// In de, this message translates to:
  /// **'Nächster Tag'**
  String get nextDay;

  /// No description provided for @language.
  ///
  /// In de, this message translates to:
  /// **'Sprache'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In de, this message translates to:
  /// **'Design'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In de, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In de, this message translates to:
  /// **'Hell'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In de, this message translates to:
  /// **'Dunkel'**
  String get themeDark;

  /// No description provided for @firstDayOfWeek.
  ///
  /// In de, this message translates to:
  /// **'Wochenbeginn'**
  String get firstDayOfWeek;
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
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
