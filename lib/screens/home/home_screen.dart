part of '../calendar/calendar_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              WeatherCard(ref: ref),
              const SizedBox(height: 16),
              _SectionTitle('Current tasks'),
              const SizedBox(height: 8),
              _TodayAgendaCard(ref: ref),
            ],
          ),
        ),
      ),
    );
  }
}

/// ------------------------ HEUTE-AGENDA (ersetzt Platzhalter) ------------------------

class _TodayAgendaCard extends StatelessWidget {
  final WidgetRef ref;
  const _TodayAgendaCard({required this.ref});

  @override
  Widget build(BuildContext context) {
    final meetingsAsync = ref.watch(meetingStreamProvider);
    Size size = MediaQuery.sizeOf(context);

    return Container(
      width: size.width,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(),
        color: MyColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(1.5, 2), spreadRadius: 2, blurStyle: BlurStyle.solid),
        ],
      ),
      constraints: const BoxConstraints(maxHeight: 260),
      child: meetingsAsync.when(
        loading: () => Row(
          children: const [
            SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 12),
            Text('Lade heutige Termine …'),
          ],
        ),
        error: (err, _) => Text('Fehler beim Laden: $err'),
        data: (meetings) {
          final byDay = CalendarUtils.buildMeetingsMapSpanning<Meeting>(meetings, (m) => m.start, (m) => m.end);
          final today = DateTime.now();
          final dayKey = CalendarUtils.dateOnly(today);
          final todays = byDay[dayKey] ?? [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 16),
                  const SizedBox(width: 6),
                  Text('${_weekdayShortDe(today.weekday)} ${today.day}', style: currentTasksDateText),
                  const Spacer(),
                  const _RoundBtn(icon: Icons.add),
                ],
              ),
              const SizedBox(height: 10),

              if (todays.isEmpty)
                const Text('Keine Termine für Heute', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))
              else ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Du hast ${todays.length} Termin${todays.length == 1 ? '' : 'e'} Heute',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ListView.separated(
                  itemCount: todays.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (_, __) => const Divider(height: 14),
                  itemBuilder: (context, idx) {
                    final mt = todays[idx];
                    final clamp = CalendarUtils.clampToDay(mt.start, mt.end, today);
                    final startTime = (mt.isAllDay || clamp.fillsFullDay)
                        ? 'Ganztägig'
                        : '${CalendarUtils.formatHHmm(clamp.displayStart)}-';
                    final endTime = (mt.isAllDay || clamp.fillsFullDay)
                        ? ''
                        : CalendarUtils.formatHHmm(clamp.displayEnd);

                    final suffix = CalendarUtils.multiDaySuffix(mt.start, mt.end, today);

                    return EventWidget(
                      startTime: startTime,
                      endTime: endTime,
                      description: mt.description,
                      eventName: '${mt.eventName}$suffix',
                      function: () => editMeeting(meeting: mt, context: context),
                      priority: mt.priority,
                      labelColor: mt.labelColor,
                      isAllDay: mt.isAllDay,
                    );
                  },
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  static String _weekdayShortDe(int weekday) {
    const map = {1: 'Mo', 2: 'Di', 3: 'Mi', 4: 'Do', 5: 'Fr', 6: 'Sa', 7: 'So'};
    return map[weekday] ?? '';
  }

  void editMeeting({required Meeting meeting, required BuildContext context}) {
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
}

class _RoundBtn extends StatelessWidget {
  final IconData icon;
  const _RoundBtn({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: MyColors.raisinBlack, shape: BoxShape.circle),
      child: IconButton(
        icon: Icon(icon, color: MyColors.white),
        onPressed: () {
          // TODO: neue Meeting-Erstellung
          Navigator.pushNamed(context, '/meetingEditor');
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700));
  }
}

const _shadows = [BoxShadow(color: Color(0x11000000), blurRadius: 18, offset: Offset(0, 8))];
