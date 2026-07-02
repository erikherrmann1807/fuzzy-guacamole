import 'package:flutter/material.dart';
import 'package:fuzzy_guacamole/data/models/appointment_model.dart';
import 'package:fuzzy_guacamole/ui/widgets/event_widget.dart';
import 'package:fuzzy_guacamole/utils/utils.dart';
import 'package:gap/gap.dart';

/// Liste der Termine eines Tages – gemeinsam genutzt von Monatsansicht
/// (Agenda) und Home-Screen.
class DayAgendaList extends StatelessWidget {
  const DayAgendaList({
    super.key,
    required this.meetings,
    required this.day,
    required this.onMeetingTap,
    this.shrinkWrap = false,
  });

  final List<Meeting> meetings;
  final DateTime day;
  final void Function(Meeting meeting) onMeetingTap;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: meetings.length,
      shrinkWrap: shrinkWrap,
      separatorBuilder: (_, __) => const Gap(14),
      itemBuilder: (context, idx) {
        final meeting = meetings[idx];
        final clamp = CalendarUtils.clampToDay(meeting.start, meeting.end, day);
        final isFullDay = meeting.isAllDay || clamp.fillsFullDay;
        final startTime = isFullDay ? 'Ganztägig ' : '${CalendarUtils.formatHHmm(clamp.displayStart)}-';
        final endTime = isFullDay ? '' : CalendarUtils.formatHHmm(clamp.displayEnd);

        return EventWidget(
          startTime: startTime,
          endTime: endTime,
          description: meeting.description,
          eventName: '${meeting.eventName}${_multiDaySuffix(meeting)}',
          onTap: () => onMeetingTap(meeting),
          priority: meeting.priority,
          labelColor: meeting.labelColor,
          isAllDay: meeting.isAllDay,
        );
      },
    );
  }

  String _multiDaySuffix(Meeting meeting) {
    final totalDays = CalendarUtils.totalDaysSpanned(meeting.start, meeting.end);
    if (totalDays <= 1) return '';
    final dayIndex = CalendarUtils.dayIndexWithinSpan(meeting.start, day);
    return ' (Tag $dayIndex/$totalDays)';
  }
}
