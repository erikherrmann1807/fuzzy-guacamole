import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fuzzy_guacamole/data/providers/locale_provider.dart';
import 'package:fuzzy_guacamole/l10n/app_localizations.dart';
import 'package:fuzzy_guacamole/routes.dart';
import 'package:fuzzy_guacamole/ui/screens/accountmanagement/account_management_screen.dart';
import 'package:fuzzy_guacamole/ui/screens/auth/auth_layout.dart';
import 'package:fuzzy_guacamole/ui/screens/auth/login_screen.dart';
import 'package:fuzzy_guacamole/ui/screens/auth/register_screen.dart';
import 'package:fuzzy_guacamole/ui/screens/calendar/calendar_screen.dart';
import 'package:fuzzy_guacamole/ui/screens/settings/settingsmenu.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: dotenv.get('API_KEY'),
      appId: dotenv.get('APP_ID'),
      messagingSenderId: dotenv.get('MESSAGING_SENDER_ID'),
      projectId: dotenv.get('PROJECT_ID'),
      storageBucket: dotenv.get('STORAGE_BUCKET'),
    ),
  );
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeAsync = ref.watch(localProvider);

    return localeAsync.when(
      data: (code) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale(code),
          home: AuthLayout(),
          routes: {
            '/settingsScreen': (context) => SettingsMenu(),
            '/eventCalendar': (context) => EventCalendarScreen(),
            '/registerScreen': (context) => RegisterScreen(),
            '/authLayout': (context) => AuthLayout(),
            '/accountManagementScreen': (context) => AccountManagementScreen(),
            '/meetingEditor': (context) => MeetingEditor(),
          },
        );
      },
      loading: () {
        return const MaterialApp(
          home: Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        );
      },
      error: (err, stack) {
        return MaterialApp(
          locale: const Locale('de'),
          home: Scaffold(
            body: Center(
              child: Text('Fehler beim Laden der Sprache: $err'),
            ),
          ),
        );
      },
    );
  }
}
