import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fuzzy_guacamole/drawer.dart';
import 'package:fuzzy_guacamole/eventCalendar/calendar_view.dart';
import 'package:fuzzy_guacamole/settings/settingsmenu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('de')],
      locale: Locale('de'),
      home: EventCalendarView(),
    );
  }
}
