import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarViewMonth extends StatefulWidget {
  const CalendarViewMonth({super.key});

  @override
  State<CalendarViewMonth> createState() => _CalendarViewMonthState();
}

class _CalendarViewMonthState extends State<CalendarViewMonth> {

  @override
  Widget build(BuildContext context) {
    return Container(
        child: SfCalendar(
          view: CalendarView.month,
          headerStyle: const CalendarHeaderStyle(
            textAlign: TextAlign.center,
          ),
          firstDayOfWeek: 1, //Montag
          todayHighlightColor: Colors.red,
          initialSelectedDate: DateTime.now(),
          weekNumberStyle: const WeekNumberStyle(
            backgroundColor: Colors.red,
            textStyle: TextStyle(color: Colors.white, fontSize: 15),
          ),
          showNavigationArrow: true,
          showTodayButton: true,
          dataSource: MeetingDataSource(_getDataSource()),
          appointmentTimeTextFormat: 'HH:mm',
          monthViewSettings: const MonthViewSettings(
            appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
            showAgenda: true,
            agendaStyle: AgendaStyle(
              appointmentTextStyle: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.white),
              dateTextStyle: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 12,
                fontWeight: FontWeight.w300,
                color: Colors.black),
              dayTextStyle: TextStyle(
                fontStyle: FontStyle.normal,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black),
              )
              )
              )
            );
  }

  List<Meeting> _getDataSource() {
    final List<Meeting> meetings = <Meeting>[];
    final DateTime today = DateTime.now();
    final DateTime startTime =
        DateTime(today.year, today.month, today.day, 9, 0, 0);
    final DateTime endTime = startTime.add(const Duration(hours: 2));
    meetings.add(Meeting(
        'Konferenz', startTime, endTime, const Color(0xFF0F8644), false));
    return meetings;
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }
}

class Meeting {
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}
