part of '../calendar_screen.dart';

class MonthlyScreen extends ConsumerStatefulWidget {
  const MonthlyScreen({super.key});

  @override
  ConsumerState<MonthlyScreen> createState() => _MonthlyScreenState();
}

class _MonthlyScreenState extends ConsumerState<MonthlyScreen> {
  late DateTime today;

  @override
  void initState() {
    super.initState();
    datesGrid = CalendarUtils.generateDatesGrid(currentMonth);
    selectedDate = DateTime.now();
    today = DateTime.now();
  }

  void _changeMonth(int offset) {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + offset);
      datesGrid = CalendarUtils.generateDatesGrid(currentMonth);
    });
  }

  void _selectMonth() async {
    await showDialog(
      context: context,
      builder: (context) => MonthYearDialog(
        initialMonth: currentMonth,
        onSelected: (newDate) {
          setState(() {
            currentMonth = newDate;
            datesGrid = CalendarUtils.generateDatesGrid(currentMonth);
          });
        },
      ),
    );
  }


  void editMeeting({required Meeting meeting}) {
    _selectedAppointment = meeting;
    _isAllDay = meeting.isAllDay;
    _selectedColorIndex = labelColors.indexOf(meeting.labelColor);
    _subject = meeting.eventName;
    _notes = meeting.description;
    _startDate = meeting.start;
    _endDate = meeting.end;
    _startTime = TimeOfDay(hour: _startDate.hour, minute: _startDate.minute);
    _endTime = TimeOfDay(hour: _endDate.hour, minute: _endDate.minute);

    Navigator.pushNamed(context, '/meetingEditor');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(meetingsViewModelProvider);
    Size size = MediaQuery.sizeOf(context);

    if (state.loading) {
      return const Center(child: CircularProgressIndicator(),);
    }

    if (state.error != null) {
      return Center(child: Text('Fehler beim Laden: ${state.error}'),);
    }

    final meetings = state.items;
    final meetingsByDay = CalendarUtils.buildMeetingsMapSpanning(meetings, (m) => m.start, (m) => m.end);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => _changeMonth(-1)),
              TextButton(
                onPressed: () => _selectMonth(),
                child: Text('${CalendarUtils.monthName(currentMonth.month)} ${currentMonth.year}', style: calendarHeader),
              ),
              IconButton(icon: const Icon(Icons.arrow_forward_ios), onPressed: () => _changeMonth(1)),
            ],
          ),
          Row(
            children: ['Mo.', 'Di.', 'Mi.', 'Do.', 'Fr.', 'Sa.', 'So.']
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
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
              itemCount: datesGrid.length,
              itemBuilder: (context, index) {
                DateTime date = datesGrid[index];
                final bool isCurrentMonth = date.month == currentMonth.month;
                final bool isSelected = DateUtils.isSameDay(selectedDate, date);
                final bool isTodayCell = DateUtils.isSameDay(date, today);

                final key = DateTime(date.year, date.month, date.day);
                final todayMeetings = meetingsByDay[key] ?? [];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDate = date;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final size = constraints.maxWidth;
                        final badgeSize = size * 0.4;
                        final offset = size * 0.05;

                        return Stack(
                          children: [
                            CircleAvatar(
                              backgroundColor: isSelected
                                  ? MyColors.raisinBlack
                                  : (isTodayCell
                                        ? MyColors.todayColor
                                        : (isCurrentMonth ? MyColors.grey : Colors.transparent)),
                              child: Text(
                                date.day.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: isSelected ? Colors.white : (isCurrentMonth ? Colors.black : Colors.grey),
                                ),
                              ),
                            ),
                            if (todayMeetings.isNotEmpty)
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
                                        todayMeetings.length.toString(),
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
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(1.5, 2),
                    spreadRadius: 2,
                    blurStyle: BlurStyle.solid,
                  ),
                ],
              ),
              constraints: const BoxConstraints(maxHeight: 300),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Agenda für ${selectedDate.day}.${selectedDate.month}.${selectedDate.year}',
                    style: agendaDateText,
                  ),
                  const Gap(4),
                  Expanded(
                    child: Builder(
                      builder: (_) {
                        final key = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
                        final today = meetingsByDay[key] ?? [];
                        if (today.isEmpty) {
                          return const Center(child: Text('Keine Termine'));
                        }
                        return ListView.separated(
                          itemCount: today.length,
                          separatorBuilder: (_, __) => Gap(14),
                          itemBuilder: (context, idx) {
                            final mt = today[idx];

                            final clamp = CalendarUtils.clampToDay(mt.start, mt.end, selectedDate);
                            final startTime = (mt.isAllDay || clamp.fillsFullDay)
                                ? 'Ganztägig '
                                : '${CalendarUtils.formatHHmm(clamp.displayStart)}-';
                            final endTime = (mt.isAllDay || clamp.fillsFullDay)
                                ? ''
                                : CalendarUtils.formatHHmm(clamp.displayEnd);
                            final suffix = CalendarUtils.multiDaySuffix(mt.start, mt.end, selectedDate);

                            return EventWidget(
                              startTime: startTime,
                              endTime: endTime,
                              description: mt.description,
                              eventName: '${mt.eventName}$suffix',
                              function: () => editMeeting(meeting: mt),
                              priority: mt.priority,
                              labelColor: mt.labelColor,
                              isAllDay: mt.isAllDay,
                            );
                          },
                        );
                      },
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


}
