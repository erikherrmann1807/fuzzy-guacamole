library;

import 'package:flutter/material.dart';
import 'package:fuzzy_guacamole/appointments/appointment_model.dart';
import 'package:fuzzy_guacamole/constants/colors.dart';
import 'package:fuzzy_guacamole/drawer.dart';
import 'package:fuzzy_guacamole/services/auth_service.dart';
import 'package:fuzzy_guacamole/services/database_service.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

part 'package:fuzzy_guacamole/appointments/appointment_editor.dart';
part 'package:fuzzy_guacamole/appointments/color_picker.dart';
part 'views/month_view.dart';
part 'views/day_view.dart';
part 'views/week_view.dart';

class EventCalendarScreen extends StatefulWidget {
  const EventCalendarScreen({super.key});

  @override
  State<EventCalendarScreen> createState() => _EventCalendarScreenState();
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

class _EventCalendarScreenState extends State<EventCalendarScreen> {
  final DatabaseService _databaseService = DatabaseService();
  late final DataSource _events;
  late String _userName = '';

  @override
  void initState() {
    loadUserName();
    _events = DataSource(<Meeting>[]);
    _databaseService.startListening((meetings) {
      setState(() {
        _events.appointments = meetings;
        _events.notifyListeners(CalendarDataSourceAction.reset, meetings);
      });
    });
    _selectedAppointment = null;
    _selectedColorIndex = 0;
    _subject = '';
    _notes = '';
    _startDate = DateTime.now();
    _endDate = DateTime.now();
    super.initState();
  }

  void loadUserName() {
    var username = authService.value.currentUser?.displayName;

    setState(() {
      _userName = username!;
    });
  }

  @override
  void dispose() {
    _databaseService.stopListening();
    super.dispose();
  }

  AppBar getAppBar() {
    switch (currentView) {
      case CalendarView.month:
        return AppBar(title: const Text('Monatsansicht'));
      case CalendarView.day:
        return AppBar(title: const Text('Tagesansicht'));
      case CalendarView.week:
        return AppBar(title: const Text('Wochenansicht'));
      default:
        return AppBar(title: const Text('Flutter Kalender'));
    }
  }

  // Widget getBody() {
  //   switch (currentView) {
  //     case CalendarView.month:
  //       return EventCalendarView(onCalendarLongPressed: onCalendarLongPress, dataSource: _events);
  //     case CalendarView.day:
  //       return EventCalendarView(onCalendarLongPressed: onCalendarLongPress, dataSource: _events);
  //     case CalendarView.week:
  //       return EventCalendarView(onCalendarLongPressed: onCalendarLongPress, dataSource: _events);
  //     default:
  //       return EventCalendarView(onCalendarLongPressed: onCalendarLongPress, dataSource: _events);
  //   }
  // }

  void changeView(CalendarView view) {
    setState(() {
      currentView = view;
      calendarController.view = view;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: MyDrawer(onViewChanged: changeView, username: _userName),
      appBar: getAppBar(),
      body: EventCalendarView(onCalendarLongPressed: onCalendarLongPress, dataSource: _events),
      floatingActionButton: FloatingActionButton(child: Icon(Icons.add), onPressed: () => onButtonPress()),
    );
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

    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => MeetingEditor()));
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
    Navigator.push<Widget>(context, MaterialPageRoute(builder: (BuildContext context) => MeetingEditor()));
  }
}

class DataSource extends CalendarDataSource {
  DataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  bool isAllDay(int index) => appointments![index].isAllDay;

  @override
  String getSubject(int index) => appointments![index].eventName;

  @override
  String getNotes(int index) => appointments![index].description;

  @override
  Color getColor(int index) => appointments![index].backgroundColor;

  @override
  DateTime getStartTime(int index) => appointments![index].start;

  @override
  DateTime getEndTime(int index) => appointments![index].end;
}
