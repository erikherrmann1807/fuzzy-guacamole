// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get username => 'Username';

  @override
  String get oldPassword => 'Old password';

  @override
  String get newPassword => 'New password';

  @override
  String get enterEmail => 'Enter email address';

  @override
  String get invalidEmail => 'Please enter a valid email address';

  @override
  String get enterPassword => 'Enter password';

  @override
  String get invalidPassword =>
      'The password must contain at least eight characters, including at least one letter and one number';

  @override
  String get enterUsername => 'Enter username';

  @override
  String get invalidUsername =>
      'The username needs to be 8-20 characters long.\nNo \"_\" or \".\" at the beginning.\nNo \"__\", \"_.\", \"._\" or \"..\" inside.\nNo \"_\" or \".\" at the end.';

  @override
  String get noAccountYet => 'Got no account?';

  @override
  String get registerHere => 'You can register here!';

  @override
  String greeting(String username) {
    return 'Hello👋, $username!';
  }

  @override
  String get defaultUsername => 'User';

  @override
  String get accountManagementTitle => 'Account management';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get retry => 'Retry';

  @override
  String errorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String loadingError(String message) {
    return 'Error while loading: $message';
  }

  @override
  String get currentTasks => 'Current tasks';

  @override
  String get loadingTodaysAppointments => 'Loading today\'s appointments …';

  @override
  String get loadingWeather => 'Loading weather …';

  @override
  String get noAppointments => 'No appointments';

  @override
  String get noAppointmentsToday => 'No appointments for today';

  @override
  String appointmentsTodayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You have $count appointments today',
      one: 'You have 1 appointment today',
    );
    return '$_temp0';
  }

  @override
  String agendaForDate(String date) {
    return 'Agenda for $date';
  }

  @override
  String get allDay => 'All-day';

  @override
  String multiDaySuffix(int dayIndex, int totalDays) {
    return ' (day $dayIndex/$totalDays)';
  }

  @override
  String get selectMonthAndYear => 'Select month and year';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get newEvent => 'New event';

  @override
  String get eventDetails => 'Event details';

  @override
  String get addTitle => 'Add title';

  @override
  String get addDescription => 'Add description';

  @override
  String get noTitle => '(No title)';

  @override
  String get selectDate => 'Select date';

  @override
  String get saveMeetingFailed => 'The appointment could not be saved.';

  @override
  String get deleteMeetingFailed => 'The appointment could not be deleted.';

  @override
  String get priorityHigh => 'High';

  @override
  String get priorityLow => 'Low';

  @override
  String get resetPassword => 'Reset password';

  @override
  String get resetPasswordInfo =>
      'To reset your password, an email with a reset link will be sent to you.';

  @override
  String get updateUsername => 'Update username';

  @override
  String get updateUsernameInfo =>
      'Enter your new username in the field below and confirm the change with the button at the end.';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountInfo =>
      'To delete your account, you need to enter your email and your password.';

  @override
  String get updatePassword => 'Update password';

  @override
  String get updatePasswordInfo =>
      'To change your password, you need your current password and a new password.';

  @override
  String get logout => 'Logout';

  @override
  String get wrongCurrentPassword => 'The current password is not correct.';

  @override
  String get wrongEmailOrPassword => 'Email or password is not correct.';

  @override
  String get noUserSignedIn => 'No user signed in.';

  @override
  String deleteUserDataFailed(String message) {
    return 'User data could not be deleted: $message';
  }

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageEnglish => 'English';

  @override
  String get reminder => 'Reminder';

  @override
  String get reminderNone => 'No reminder';

  @override
  String get reminderAtStart => 'At start time';

  @override
  String reminderMinutesBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes before',
      one: '1 minute before',
    );
    return '$_temp0';
  }

  @override
  String reminderHoursBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours before',
      one: '1 hour before',
    );
    return '$_temp0';
  }

  @override
  String reminderDaysBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days before',
      one: '1 day before',
    );
    return '$_temp0';
  }

  @override
  String meetingReminderBody(String time) {
    return 'Starts at $time';
  }

  @override
  String get taskReminderBody => 'Daily task due';
}
