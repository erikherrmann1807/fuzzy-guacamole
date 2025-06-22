part of 'calendar_view.dart';

class WeekView extends StatelessWidget {
  const WeekView({required this.onCalendarLongPressed, super.key});
  final CalendarLongPressCallback onCalendarLongPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
      child: SafeArea(
        child: SfCalendar(
          view: CalendarView.week,
          firstDayOfWeek: 1,
          todayHighlightColor: Colors.red,
          showNavigationArrow: true,
          dataSource: _events,
          onLongPress: onCalendarLongPressed,
          timeSlotViewSettings: TimeSlotViewSettings(timeFormat: 'HH:mm'),
        ),
      ),
    );
  }
}
