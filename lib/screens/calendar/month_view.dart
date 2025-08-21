part of 'calendar_screen.dart';

class EventCalendarView extends StatelessWidget {
  const EventCalendarView({required this.onCalendarLongPressed, super.key, required this.dataSource});
  final CalendarLongPressCallback onCalendarLongPressed;
  final DataSource dataSource;

  @override
  Widget build(BuildContext context) {
    return SfCalendarTheme(
        data: SfCalendarThemeData(
          todayHighlightColor: MyColors.todayColor,
          todayBackgroundColor: MyColors.grey,
          viewHeaderDayTextStyle: viewHeaderText,
          viewHeaderBackgroundColor: MyColors.white,
          viewHeaderDateTextStyle: viewHeaderText,
        ),
        child: SafeArea(
          child: SfCalendar(
            view: CalendarView.month,
            controller: calendarController,
            firstDayOfWeek: 1,
            todayTextStyle: todayText,
            cellBorderColor: Colors.grey,
            dataSource: dataSource,
            onLongPress: onCalendarLongPressed,
            showTodayButton: true,
            appointmentTimeTextFormat: 'HH:mm',
            selectionDecoration: BoxDecoration(border: BoxBorder.all(color: Colors.grey)),
            headerStyle: CalendarHeaderStyle(
                backgroundColor: MyColors.white,
                textStyle: viewHeaderText
            ),
            monthViewSettings: MonthViewSettings(
              appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
              showAgenda: true,
              showTrailingAndLeadingDates: false,
              monthCellStyle: MonthCellStyle(
                backgroundColor: MyColors.grey,
              ),
              agendaViewHeight: 250,
              agendaStyle: AgendaStyle(
                  appointmentTextStyle: agendaText,
                  dateTextStyle: agendaDateText,
                  dayTextStyle: agendaDateText,
                  backgroundColor: MyColors.white,
                  placeholderTextStyle: agendaText
              ),
            ),
          ),
        )
    );
  }
}
