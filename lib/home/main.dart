import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fuzzy_guacamole/appointments/appointmentmulm.dart';
import 'package:fuzzy_guacamole/appointments/appointment_create_screen.dart';
import 'package:fuzzy_guacamole/calendarviews/calendarviewday.dart';
import 'package:fuzzy_guacamole/calendarviews/calendarviewmonth.dart';
import 'package:fuzzy_guacamole/calendarviews/calendarviewweek.dart';
import 'package:fuzzy_guacamole/drawer.dart';
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
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String initialView;

  const MyHomePage({Key? key, this.initialView = 'month'}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late String currentView;

  @override
  void initState() {
    super.initState();
    currentView = widget.initialView;
  }

  void changeView(String view) {
    setState(() {
      currentView = view;
    });
  }

  AppBar getAppBar() {
    switch (currentView) {
      case 'month':
        return AppBar(title: const Text('Monatsansicht'));
      case 'day':
        return AppBar(title: const Text('Tagesansicht'));
      case 'settings':
        return AppBar(title: const Text('Einstellungen'));
      default:
        return AppBar(title: const Text('Flutter Kalender'));
    }
  }

  Widget getBody() {
    switch (currentView) {
      case 'month':
        return const CalendarViewMonth();
      case 'day':
        return const CalendarViewDay();
      case 'week':
        return const CalendarViewWeek();
      case 'settings':
        return const SettingsMenu();
      default:
        return const CalendarViewMonth();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(),
      drawer: MyDrawer(onViewChanged: changeView),
      body: getBody(),
      floatingActionButton: FloatingActionButton(
          onPressed: () => AppointmentMulm().showMyDialog(context),
          child: Icon(Icons.add),
      ),
    );
  }
}
