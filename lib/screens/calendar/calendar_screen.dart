library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuzzy_guacamole/constants.dart';
import 'package:fuzzy_guacamole/models/appointment_model.dart';
import 'package:fuzzy_guacamole/drawer.dart';
import 'package:fuzzy_guacamole/providers/firebase_firestore_provider.dart';
import 'package:fuzzy_guacamole/providers/meetings_provider.dart';
import 'package:fuzzy_guacamole/screens/auth/app_loading_page.dart';
import 'package:fuzzy_guacamole/styles/colors.dart';
import 'package:fuzzy_guacamole/styles/styles.dart';
import 'package:fuzzy_guacamole/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../providers/users_provider.dart';

part '../appointments/appointment_editor.dart';
part '../appointments/color_picker.dart';
part 'month_view.dart';

class EventCalendarScreen extends ConsumerStatefulWidget {
  const EventCalendarScreen({super.key});

  @override
  ConsumerState<EventCalendarScreen> createState() => _EventCalendarScreenState();
}

int _selectedColorIndex = 0;
Meeting? _selectedAppointment;
late DateTime _startDate;
late TimeOfDay _startTime;
late DateTime _endDate;
late TimeOfDay _endTime;
late bool _isAllDay;
String _subject = '';
String _notes = '';
CalendarView currentView = CalendarView.month;
CalendarController calendarController = CalendarController();

class _EventCalendarScreenState extends ConsumerState<EventCalendarScreen> {
  final DataSource _events = DataSource(<Meeting>[]);

  @override
  void initState() {
    super.initState();
    _selectedAppointment = null;
    _selectedColorIndex = 0;
    _subject = '';
    _notes = '';
    _startDate = DateTime.now();
    _endDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    //TODO: correct rebuild after closing meeting editor
    final username = ref.watch(usernameProvider).value;
    final allMeetings = ref.watch(meetingStreamProvider);
    return allMeetings.when(
      data: (meetings) {
        _events.appointments = meetings;
        return Scaffold(
          resizeToAvoidBottomInset: false,
          drawer: MyDrawer(onViewChanged: changeView, username: username),
          appBar: getAppBar(),
          body: EventCalendarView(onCalendarLongPressed: onCalendarLongPress, dataSource: _events),
          floatingActionButton: FloatingActionButton(
              backgroundColor: MyColors.buttonColor,
              onPressed: () => onButtonPress(),
              child: Icon(Icons.add, color: Colors.black,)),
        );
      },
      loading: () => AppLoadingPage(),
      error: (err, stack) => Center(child: Text('Fehler: $err')),
    );
  }

  AppBar getAppBar() {
    switch (currentView) {
      case CalendarView.month:
        return AppBar(
            title: const Text('Monatsansicht'),
          backgroundColor: MyColors.appBarColor,
          titleTextStyle: agendaText,
        );
      case CalendarView.day:
        return AppBar(title: const Text('Tagesansicht'));
      case CalendarView.week:
        return AppBar(title: const Text('Wochenansicht'));
      default:
        return AppBar(title: const Text('Flutter Kalender'));
    }
  }

  void changeView(CalendarView view) {
    setState(() {
      currentView = view;
      calendarController.view = view;
    });
  }

  void onButtonPress() {
    _selectedAppointment = null;
    _isAllDay = false;
    _selectedColorIndex = 0;
    _subject = '';
    _notes = '';

    _startDate = DateTime.now();
    _endDate = _startDate.add(Duration(hours: 1));

    _startTime = TimeOfDay(hour: _startDate.hour, minute: _startDate.minute);
    _endTime = TimeOfDay(hour: _endDate.hour, minute: _endDate.minute);

    Navigator.pushNamed(context, '/meetingEditor');
  }

  void onCalendarLongPress(CalendarLongPressDetails calendarLongPressDetails) {
    if (calendarLongPressDetails.targetElement != CalendarElement.calendarCell &&
        calendarLongPressDetails.targetElement != CalendarElement.appointment) {
      return;
    }

    _selectedAppointment = null;
    _isAllDay = false;
    _selectedColorIndex = 0;
    _subject = '';
    _notes = '';

    if (calendarLongPressDetails.appointments != null && calendarLongPressDetails.appointments?.length == 1) {
      final Meeting meetingDetails = calendarLongPressDetails.appointments![0];
      _startDate = meetingDetails.start;
      _endDate = meetingDetails.end;
      _isAllDay = meetingDetails.isAllDay;
      _selectedColorIndex = colorCollection.indexOf(meetingDetails.backgroundColor);
      _subject = meetingDetails.eventName == '(No title)' ? '' : meetingDetails.eventName;
      _notes = meetingDetails.description;
      _selectedAppointment = meetingDetails;
    } else {
      final DateTime date = calendarLongPressDetails.date!;
      _startDate = date;
      _endDate = date.add(Duration(hours: 1));
    }
    _startTime = TimeOfDay(hour: _startDate.hour, minute: _startDate.minute);
    _endTime = TimeOfDay(hour: _endDate.hour, minute: _endDate.minute);
    Navigator.pushNamed(context, '/meetingEditor');
  }
}
