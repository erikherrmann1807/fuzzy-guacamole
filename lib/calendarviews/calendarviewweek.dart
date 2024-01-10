import 'package:flutter/material.dart';
import 'package:fuzzy_guacamole/drawer.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarViewWeek extends StatefulWidget {
  const CalendarViewWeek({super.key});

  @override
  State<CalendarViewWeek> createState() => _CalendarViewWeekState();
}

class _CalendarViewWeekState extends State<CalendarViewWeek> {
  DateTime today = DateTime.now();
  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      today = day;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TableCalendar(
        locale: "en_US",
        headerStyle:
        const HeaderStyle(formatButtonVisible: false,
            titleCentered: true),
        calendarFormat: CalendarFormat.week,
        availableGestures: AvailableGestures.all,
        selectedDayPredicate: (day) => isSameDay(day, today),
        focusedDay: today,
        firstDay: DateTime.utc(2000, 1, 1),
        lastDay: DateTime.utc(2300, 12, 31),
        onDaySelected: _onDaySelected,
      ),
    );
  }
}
