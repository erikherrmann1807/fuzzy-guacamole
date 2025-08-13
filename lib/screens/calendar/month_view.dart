part of 'calendar_screen.dart';

class EventCalendarView extends StatelessWidget {
  const EventCalendarView({required this.onCalendarLongPressed, super.key, required this.dataSource});
  final CalendarLongPressCallback onCalendarLongPressed;
  final DataSource dataSource;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
      child: SafeArea(
        child: SfCalendar(
          view: CalendarView.month,
          controller: calendarController,
          firstDayOfWeek: 1,
          todayHighlightColor: Colors.red,
          cellBorderColor: Colors.grey,
          dataSource: dataSource,
          onLongPress: onCalendarLongPressed,
          showTodayButton: true,
          timeSlotViewSettings: TimeSlotViewSettings(timeFormat: 'HH:mm'),
          appointmentTimeTextFormat: 'HH:mm',
          selectionDecoration: BoxDecoration(border: BoxBorder.all(color: Colors.blueAccent)),
          headerStyle: CalendarHeaderStyle(backgroundColor: Colors.white),
          monthViewSettings: MonthViewSettings(
            appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
            showAgenda: true,
            agendaStyle: AgendaStyle(
              appointmentTextStyle: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.white),
              dateTextStyle: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 14,
                fontWeight: FontWeight.w300,
                color: Colors.black,
              ),
              dayTextStyle: TextStyle(
                fontStyle: FontStyle.normal,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
