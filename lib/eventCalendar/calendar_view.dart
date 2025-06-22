library;

import 'package:flutter/material.dart';
import 'package:fuzzy_guacamole/appointments/appointment_model.dart';
import 'package:fuzzy_guacamole/drawer.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

part 'package:fuzzy_guacamole/appointments/appointment_editor.dart';
part 'package:fuzzy_guacamole/appointments/color_picker.dart';
part 'month_view.dart';
part 'day_view.dart';
part 'week_view.dart';

class EventCalendarView extends StatefulWidget {
  const EventCalendarView({super.key});

  @override
  State<EventCalendarView> createState() => _EventCalendarViewState();
}

late List<Color> _colorCollection;
late List<String> _colorNames;
int _selectedColorIndex = 0;
late DataSource _events;
Meeting? _selectedAppointment;
late DateTime _startDate;
late TimeOfDay _startTime;
late DateTime _endDate;
late TimeOfDay _endTime;
late bool _isAllDay;
String _subject = '';
String _notes = '';
CalendarView currentView = CalendarView.month;

class _EventCalendarViewState extends State<EventCalendarView> {
  @override
  void initState() {
    _events = DataSource(getMeetingDetails());
    currentView = CalendarView.month;
    _selectedAppointment = null;
    _selectedColorIndex = 0;
    _subject = '';
    _notes = '';
    _startDate = DateTime.now();
    _endDate = DateTime.now();
    super.initState();
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

  Widget getBody() {
    switch (currentView) {
      case CalendarView.month:
        return MonthView(onCalendarLongPressed: onCalendarLongPress);
      case CalendarView.day:
        return DayView(onCalendarLongPressed: onCalendarLongPress);
      case CalendarView.week:
        return WeekView(onCalendarLongPressed: onCalendarLongPress);
      default:
        return MonthView(onCalendarLongPressed: onCalendarLongPress);
    }
  }

  void changeView(CalendarView view) {
    setState(() {
      currentView = view;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: MyDrawer(onViewChanged: changeView),
      appBar: getAppBar(),
      body: getBody(),
      floatingActionButton: FloatingActionButton(child: Icon(Icons.add), onPressed: () => onButtonPress()),
    );
  }

  void onButtonPress() {
    _selectedAppointment = null;
    _isAllDay = false;
    _selectedColorIndex = 0;
    _subject = '';
    _notes = '';

    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => AppointmentEditor()));
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
      _selectedColorIndex = _colorCollection.indexOf(meetingDetails.backgroundColor);
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
    Navigator.push<Widget>(context, MaterialPageRoute(builder: (BuildContext context) => AppointmentEditor()));
  }

  List<Meeting> getMeetingDetails() {
    final List<Meeting> meetingCollection = <Meeting>[];

    _colorCollection = <Color>[];
    _colorCollection.add(const Color(0xFF0F8644));
    _colorCollection.add(const Color(0xFF8B1FA9));
    _colorCollection.add(const Color(0xFFD20100));
    _colorCollection.add(const Color(0xFFFC571D));
    _colorCollection.add(const Color(0xFF85461E));
    _colorCollection.add(const Color(0xFFFF00FF));
    _colorCollection.add(const Color(0xFF3D4FB5));
    _colorCollection.add(const Color(0xFFE47C73));
    _colorCollection.add(const Color(0xFF636363));

    _colorNames = <String>[];
    _colorNames.add('Green');
    _colorNames.add('Purple');
    _colorNames.add('Red');
    _colorNames.add('Orange');
    _colorNames.add('Caramel');
    _colorNames.add('Magenta');
    _colorNames.add('Blue');
    _colorNames.add('Peach');
    _colorNames.add('Gray');

    return meetingCollection;
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
