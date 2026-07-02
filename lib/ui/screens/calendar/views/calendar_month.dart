import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuzzy_guacamole/data/providers/firebase_firestore_provider.dart';
import 'package:fuzzy_guacamole/l10n/l10n_extensions.dart';
import 'package:fuzzy_guacamole/styles/colors.dart';
import 'package:fuzzy_guacamole/styles/styles.dart';
import 'package:fuzzy_guacamole/ui/screens/appointments/appointment_editor.dart';
import 'package:fuzzy_guacamole/ui/viewmodels/calendar_viewmodel.dart';
import 'package:fuzzy_guacamole/ui/widgets/agenda_list.dart';
import 'package:fuzzy_guacamole/ui/widgets/month_view_widgets/month_year_dialog.dart';
import 'package:fuzzy_guacamole/utils/utils.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

/// Monatsansicht des Kalenders mit Agenda für den ausgewählten Tag.
class MonthlyScreen extends ConsumerWidget {
  const MonthlyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetingsState = ref.watch(meetingsViewModelProvider);
    final calendar = ref.watch(calendarViewModelProvider);
    final calendarVm = ref.read(calendarViewModelProvider.notifier);
    final size = MediaQuery.sizeOf(context);
    final locale = Localizations.maybeLocaleOf(context)?.toString();

    if (meetingsState.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (meetingsState.error != null) {
      return Center(child: Text(context.l10n.loadingError(meetingsState.error!)));
    }

    final meetingsByDay = CalendarUtils.buildMeetingsMapSpanning(meetingsState.items, (m) => m.start, (m) => m.end);
    final selectedDayMeetings = meetingsByDay[calendar.selectedDate] ?? [];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: calendarVm.goToPreviousMonth),
              TextButton(
                onPressed: () => _showMonthPicker(context, calendar.visibleMonth, calendarVm),
                child: Text(DateFormat.yMMMM(locale).format(calendar.visibleMonth), style: calendarHeader),
              ),
              IconButton(icon: const Icon(Icons.arrow_forward_ios), onPressed: calendarVm.goToNextMonth),
            ],
          ),
          Row(
            children: _weekdayHeaders(locale)
                .map(
                  (day) => Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      child: Center(child: Text(day, style: viewHeaderText)),
                    ),
                  ),
                )
                .toList(),
          ),
          Expanded(
            child: _MonthGrid(
              calendar: calendar,
              meetingsByDay: meetingsByDay,
              onDateSelected: calendarVm.selectDate,
            ),
          ),
          const Divider(),
          SizedBox(
            child: Container(
              width: size.width,
              height: size.height * 0.3,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(),
                color: MyColors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(color: Colors.black, offset: Offset(1.5, 2), spreadRadius: 2, blurStyle: BlurStyle.solid),
                ],
              ),
              constraints: const BoxConstraints(maxHeight: 300),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.agendaForDate(DateFormat.yMd(locale).format(calendar.selectedDate)),
                    style: agendaDateText,
                  ),
                  const Gap(4),
                  Expanded(
                    child: selectedDayMeetings.isEmpty
                        ? Center(child: Text(context.l10n.noAppointments))
                        : DayAgendaList(
                            meetings: selectedDayMeetings,
                            day: calendar.selectedDate,
                            onMeetingTap: (meeting) => openMeetingEditor(context, meeting: meeting),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Kurze Wochentagsnamen, beginnend bei Montag.
  List<String> _weekdayHeaders(String? locale) {
    final format = DateFormat.E(locale);
    // 5.1.2026 ist ein Montag.
    final monday = DateTime(2026, 1, 5);
    return List.generate(7, (i) => '${format.format(monday.add(Duration(days: i)))}.');
  }

  Future<void> _showMonthPicker(BuildContext context, DateTime visibleMonth, CalendarViewModel vm) {
    return showDialog(
      context: context,
      builder: (context) => MonthYearDialog(initialMonth: visibleMonth, onSelected: vm.showMonth),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({required this.calendar, required this.meetingsByDay, required this.onDateSelected});

  final CalendarState calendar;
  final Map<DateTime, List<Object>> meetingsByDay;
  final void Function(DateTime) onDateSelected;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final datesGrid = calendar.datesGrid;

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
      itemCount: datesGrid.length,
      itemBuilder: (context, index) {
        final date = datesGrid[index];
        final isCurrentMonth = date.month == calendar.visibleMonth.month;
        final isSelected = DateUtils.isSameDay(calendar.selectedDate, date);
        final isTodayCell = DateUtils.isSameDay(date, today);
        final dayMeetings = meetingsByDay[date] ?? [];

        return GestureDetector(
          onTap: () => onDateSelected(date),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cellSize = constraints.maxWidth;
                final badgeSize = cellSize * 0.4;
                final offset = cellSize * 0.05;

                return Stack(
                  children: [
                    CircleAvatar(
                      backgroundColor: isSelected
                          ? MyColors.raisinBlack
                          : (isTodayCell ? MyColors.todayColor : (isCurrentMonth ? MyColors.grey : Colors.transparent)),
                      child: Text(
                        date.day.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: isSelected ? Colors.white : (isCurrentMonth ? Colors.black : Colors.grey),
                        ),
                      ),
                    ),
                    if (dayMeetings.isNotEmpty)
                      Positioned(
                        bottom: offset,
                        right: offset,
                        child: Container(
                          width: badgeSize,
                          height: badgeSize,
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(badgeSize / 2),
                          ),
                          child: Center(
                            child: FittedBox(
                              child: Text(
                                dayMeetings.length.toString(),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
