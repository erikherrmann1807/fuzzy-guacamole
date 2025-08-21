import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuzzy_guacamole/screens/accountmanagement/account_management_screen.dart';
import 'package:fuzzy_guacamole/screens/auth/auth_layout.dart';
import 'package:fuzzy_guacamole/screens/auth/login_screen.dart';
import 'package:fuzzy_guacamole/screens/auth/register_screen.dart';
import 'package:fuzzy_guacamole/screens/calendar/views/calendar_month.dart';
import 'package:fuzzy_guacamole/screens/settings/settingsmenu.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fuzzy_guacamole/screens/calendar/calendar_screen.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: FirebaseOptions(
      apiKey: dotenv.get('API_KEY'),
      appId: dotenv.get('APP_ID'),
      messagingSenderId: dotenv.get('MESSAGING_SENDER_ID'),
      projectId: dotenv.get('PROJECT_ID'),
      storageBucket: dotenv.get('STORAGE_BUCKET')));
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('de')],
      locale: Locale('de'),
      initialRoute: '/authLayout',
      routes: {
        '/loginScreen': (context) => LoginScreen(),
        '/settingsScreen': (context) => SettingsMenu(),
        '/eventCalendar': (context) => EventCalendarScreen(),
        '/calendarMonth': (context) => MonthlyScreen(),
        '/registerScreen': (context) => RegisterScreen(),
        '/authLayout': (context) => AuthLayout(),
        '/accountManagementScreen': (context) => AccountManagementScreen(),
        '/meetingEditor': (context) => MeetingEditor(),
      },
    );
  }
}
