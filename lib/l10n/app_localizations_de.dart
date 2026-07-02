// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get login => 'Login';

  @override
  String get register => 'Registrieren';

  @override
  String get email => 'E-Mail';

  @override
  String get password => 'Passwort';

  @override
  String get username => 'Nutzername';

  @override
  String get oldPassword => 'Altes Passwort';

  @override
  String get newPassword => 'Neues Passwort';

  @override
  String get enterEmail => 'E-Mail-Adresse eingeben';

  @override
  String get invalidEmail => 'Bitte eine gültige E-Mail-Adresse eingeben';

  @override
  String get enterPassword => 'Passwort eingeben';

  @override
  String get invalidPassword =>
      'Das Passwort muss mindestens acht Zeichen, davon mindestens einen Buchstaben und eine Zahl enthalten';

  @override
  String get enterUsername => 'Nutzernamen eingeben';

  @override
  String get invalidUsername =>
      'Der Nutzername muss 8–20 Zeichen lang sein.\nKein \"_\" oder \".\" am Anfang.\nKein \"__\", \"_.\", \"._\" oder \"..\" im Namen.\nKein \"_\" oder \".\" am Ende.';

  @override
  String get noAccountYet => 'Noch keinen Account?';

  @override
  String get registerHere => 'Hier registrieren!';

  @override
  String greeting(String username) {
    return 'Hallo👋, $username!';
  }

  @override
  String get defaultUsername => 'Nutzer';

  @override
  String get accountManagementTitle => 'Account-Verwaltung';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String errorWithMessage(String message) {
    return 'Fehler: $message';
  }

  @override
  String loadingError(String message) {
    return 'Fehler beim Laden: $message';
  }

  @override
  String get currentTasks => 'Aktuelle Aufgaben';

  @override
  String get loadingTodaysAppointments => 'Lade heutige Termine …';

  @override
  String get loadingWeather => 'Wetter laden …';

  @override
  String get noAppointments => 'Keine Termine';

  @override
  String get noAppointmentsToday => 'Keine Termine für heute';

  @override
  String appointmentsTodayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Du hast $count Termine heute',
      one: 'Du hast 1 Termin heute',
    );
    return '$_temp0';
  }

  @override
  String agendaForDate(String date) {
    return 'Agenda für $date';
  }

  @override
  String get allDay => 'Ganztägig';

  @override
  String multiDaySuffix(int dayIndex, int totalDays) {
    return ' (Tag $dayIndex/$totalDays)';
  }

  @override
  String get selectMonthAndYear => 'Monat und Jahr wählen';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get newEvent => 'Neuer Termin';

  @override
  String get eventDetails => 'Termindetails';

  @override
  String get addTitle => 'Titel hinzufügen';

  @override
  String get addDescription => 'Beschreibung hinzufügen';

  @override
  String get noTitle => '(Ohne Titel)';

  @override
  String get selectDate => 'Datum auswählen';

  @override
  String get saveMeetingFailed => 'Der Termin konnte nicht gespeichert werden.';

  @override
  String get deleteMeetingFailed => 'Der Termin konnte nicht gelöscht werden.';

  @override
  String get priorityHigh => 'Hoch';

  @override
  String get priorityLow => 'Niedrig';

  @override
  String get resetPassword => 'Passwort zurücksetzen';

  @override
  String get resetPasswordInfo =>
      'Um Ihr Passwort zurückzusetzen, wird Ihnen eine E-Mail mit einem Link zum Zurücksetzen zugeschickt.';

  @override
  String get updateUsername => 'Nutzernamen ändern';

  @override
  String get updateUsernameInfo =>
      'Geben Sie in folgendem Feld Ihren neuen Nutzernamen ein und bestätigen Sie die Änderung mit dem Button am Ende.';

  @override
  String get deleteAccount => 'Account löschen';

  @override
  String get deleteAccountInfo =>
      'Um Ihren Account zu löschen, müssen Sie Ihre E-Mail und Ihr Passwort angeben.';

  @override
  String get updatePassword => 'Passwort ändern';

  @override
  String get updatePasswordInfo =>
      'Um Ihr Passwort zu ändern, benötigen Sie das aktuelle und ein neues Passwort.';

  @override
  String get logout => 'Abmelden';

  @override
  String get wrongCurrentPassword => 'Das aktuelle Passwort ist nicht korrekt.';

  @override
  String get wrongEmailOrPassword => 'E-Mail oder Passwort ist nicht korrekt.';

  @override
  String get noUserSignedIn => 'Kein Nutzer angemeldet.';

  @override
  String deleteUserDataFailed(String message) {
    return 'Nutzerdaten konnten nicht gelöscht werden: $message';
  }

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageEnglish => 'English';

  @override
  String get reminder => 'Erinnerung';

  @override
  String get reminderNone => 'Keine Erinnerung';

  @override
  String get reminderAtStart => 'Zum Startzeitpunkt';

  @override
  String reminderMinutesBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Minuten vorher',
      one: '1 Minute vorher',
    );
    return '$_temp0';
  }

  @override
  String reminderHoursBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Stunden vorher',
      one: '1 Stunde vorher',
    );
    return '$_temp0';
  }

  @override
  String reminderDaysBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tage vorher',
      one: '1 Tag vorher',
    );
    return '$_temp0';
  }

  @override
  String meetingReminderBody(String time) {
    return 'Beginnt um $time';
  }

  @override
  String get taskReminderBody => 'Daily Task fällig';
}
