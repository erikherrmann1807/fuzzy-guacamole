part of '../calendar_screen.dart';

class DayView extends StatelessWidget {
  const DayView({required this.onCalendarLongPressed, super.key, required this.dataSource});
  final CalendarLongPressCallback onCalendarLongPressed;
  final DataSource dataSource;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
      child: SafeArea(
        child: SfCalendar(
          view: CalendarView.day,
          firstDayOfWeek: 1,
          todayHighlightColor: Colors.red,
          showNavigationArrow: true,
          dataSource: dataSource,
          onLongPress: onCalendarLongPressed,
          timeSlotViewSettings: TimeSlotViewSettings(timeFormat: 'HH:mm'),
        ),
      ),
    );
  }
}
