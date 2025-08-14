part of 'calendar_screen.dart';

class EventCalendarView extends StatelessWidget {
  const EventCalendarView({required this.onCalendarLongPressed, super.key, required this.dataSource});
  final CalendarLongPressCallback onCalendarLongPressed;
  final DataSource dataSource;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: SfCalendar(
          view: CalendarView.month,
          controller: calendarController,
          firstDayOfWeek: 1,
          viewHeaderStyle: ViewHeaderStyle(
              backgroundColor: MyColors.viewHeader,
            dayTextStyle: viewHeaderText
          ),
          todayHighlightColor: MyColors.todayColor,
          todayTextStyle: todayText,
          cellBorderColor: Colors.grey,
          dataSource: dataSource,
          onLongPress: onCalendarLongPressed,
          showTodayButton: true,
          appointmentTimeTextFormat: 'HH:mm',
          selectionDecoration: BoxDecoration(border: BoxBorder.all(color: MyColors.cellBorderColor)),
          headerStyle: CalendarHeaderStyle(
              backgroundColor: MyColors.appBarColor,
            textStyle: viewHeaderText
          ),
          monthViewSettings: MonthViewSettings(
            appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
            showAgenda: true,
            monthCellStyle: MonthCellStyle(
                backgroundColor: MyColors.calendarBackground,
              leadingDatesBackgroundColor: MyColors.inactiveCells,
              trailingDatesBackgroundColor: MyColors.inactiveCells
            ),
            agendaViewHeight: 250,
            agendaStyle: AgendaStyle(
              appointmentTextStyle: agendaText,
              dateTextStyle: agendaDateText,
              dayTextStyle: agendaDateText,
              backgroundColor: MyColors.agendaBackground,
                placeholderTextStyle: agendaText
            ),
          ),
        ),
      );
  }
}
