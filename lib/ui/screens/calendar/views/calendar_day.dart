import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuzzy_guacamole/data/models/appointment_model.dart';
import 'package:fuzzy_guacamole/data/providers/firebase_firestore_provider.dart';
import 'package:fuzzy_guacamole/l10n/l10n_extensions.dart';
import 'package:fuzzy_guacamole/styles/colors.dart';
import 'package:fuzzy_guacamole/ui/screens/appointments/appointment_editor.dart';
import 'package:fuzzy_guacamole/ui/screens/tasks/daily_tasks_dialog.dart';
import 'package:fuzzy_guacamole/ui/viewmodels/calendar_viewmodel.dart';
import 'package:fuzzy_guacamole/utils/utils.dart';
import 'package:intl/intl.dart';

/// Öffnet die Tagesansicht für den aktuell im [calendarViewModelProvider]
/// ausgewählten Tag.
Future<void> openDayView(BuildContext context) {
  return Navigator.of(context).push(MaterialPageRoute(builder: (context) => const DailyScreen()));
}

/// Tagesansicht: Stunden-Raster mit den Terminen des ausgewählten Tages
/// und Navigation zum vorherigen/nächsten Tag.
class DailyScreen extends ConsumerWidget {
  const DailyScreen({super.key});

  /// Höhe einer Stunde im Raster.
  static const double hourHeight = 64;

  /// Breite der Uhrzeiten-Spalte links.
  static const double gutterWidth = 56;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendar = ref.watch(calendarViewModelProvider);
    final calendarVm = ref.read(calendarViewModelProvider.notifier);
    final meetingsState = ref.watch(meetingsViewModelProvider);
    final locale = Localizations.maybeLocaleOf(context)?.toString();
    final day = calendar.selectedDate;

    final meetingsByDay = CalendarUtils.buildMeetingsMapSpanning(meetingsState.items, (m) => m.start, (m) => m.end);
    final dayMeetings = meetingsByDay[day] ?? <Meeting>[];

    // Ganztägige Termine (Flag oder kompletter Tag) oben als Chips,
    // alle übrigen im Stunden-Raster.
    final allDay = <Meeting>[];
    final timed = <Meeting>[];
    for (final m in dayMeetings) {
      final clamp = CalendarUtils.clampToDay(m.start, m.end, day);
      (m.isAllDay || clamp.fillsFullDay ? allDay : timed).add(m);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.white,
        title: Text(DateFormat.yMMMEd(locale).format(day)),
        actions: [
          IconButton(
            tooltip: context.l10n.previousDay,
            icon: const Icon(Icons.chevron_left),
            onPressed: calendarVm.goToPreviousDay,
          ),
          IconButton(
            tooltip: context.l10n.nextDay,
            icon: const Icon(Icons.chevron_right),
            onPressed: calendarVm.goToNextDay,
          ),
          IconButton(
            tooltip: context.l10n.dailyTasksTooltip,
            icon: const Icon(Icons.checklist),
            onPressed: () => showDailyTasksDialog(context, day),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: MyColors.raisinBlack,
        onPressed: () => openMeetingEditor(context, initialDate: day),
        child: const Icon(Icons.add, color: MyColors.white),
      ),
      body: Column(
        children: [
          if (allDay.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: allDay
                    .map(
                      (m) => ActionChip(
                        avatar: CircleAvatar(backgroundColor: m.labelColor, radius: 6),
                        label: Text('${m.eventName.isEmpty ? context.l10n.noTitle : m.eventName}'
                            ' – ${context.l10n.allDay}'),
                        onPressed: () => openMeetingEditor(context, meeting: m),
                      ),
                    )
                    .toList(),
              ),
            ),
          if (meetingsState.error != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(context.l10n.loadingError(meetingsState.error!)),
            ),
          Expanded(
            child: SingleChildScrollView(
              child: SizedBox(
                height: 24 * hourHeight,
                child: LayoutBuilder(
                  builder: (context, constraints) => Stack(
                    children: [
                      ..._buildHourLines(context),
                      ..._buildEventBlocks(context, timed, day, constraints.maxWidth),
                      if (CalendarUtils.isSameDate(day, DateTime.now())) _buildNowIndicator(constraints.maxWidth),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildHourLines(BuildContext context) {
    return [
      for (int hour = 0; hour < 24; hour++)
        Positioned(
          top: hour * hourHeight,
          left: 0,
          right: 0,
          height: hourHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: gutterWidth,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, top: 2),
                  child: Text(
                    '${hour.toString().padLeft(2, '0')}:00',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ),
              Expanded(child: Container(height: 1, color: Colors.grey.shade300)),
            ],
          ),
        ),
    ];
  }

  List<Widget> _buildEventBlocks(BuildContext context, List<Meeting> timed, DateTime day, double totalWidth) {
    final blocks = _layoutDayEvents(timed, day);
    final areaWidth = totalWidth - gutterWidth - 8;

    return blocks.map((block) {
      final columnWidth = areaWidth / block.columns;
      final top = _minutesSinceMidnight(block.start, day) / 60 * hourHeight;
      final bottom = _minutesSinceMidnight(block.end, day) / 60 * hourHeight;
      final meeting = block.meeting;

      return Positioned(
        top: top,
        left: gutterWidth + block.column * columnWidth,
        width: columnWidth - 4,
        // Sehr kurze Termine bleiben antippbar.
        height: (bottom - top).clamp(24.0, 24 * hourHeight - top),
        child: GestureDetector(
          onTap: () => openMeetingEditor(context, meeting: meeting),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: meeting.labelColor.withValues(alpha: 0.85),
              border: Border.all(color: MyColors.raisinBlack, width: 0.5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meeting.eventName.isEmpty ? context.l10n.noTitle : meeting.eventName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                if (bottom - top >= 40)
                  Text(
                    '${CalendarUtils.formatHHmm(block.start)} – ${CalendarUtils.formatHHmm(block.end)}',
                    style: const TextStyle(fontSize: 11, color: Colors.white),
                  ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildNowIndicator(double totalWidth) {
    final now = DateTime.now();
    final top = (now.hour * 60 + now.minute) / 60 * hourHeight;
    return Positioned(
      top: top - 4,
      left: gutterWidth - 4,
      right: 0,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
          ),
          Expanded(child: Container(height: 2, color: Colors.redAccent)),
        ],
      ),
    );
  }

  static double _minutesSinceMidnight(DateTime time, DateTime day) {
    return time.difference(CalendarUtils.startOfDay(day)).inMinutes.toDouble().clamp(0, 24 * 60);
  }

  /// Ordnet sich überlappende Termine nebeneinander an: Termine werden nach
  /// Startzeit gierig auf freie Spalten verteilt; alle Termine eines
  /// zusammenhängenden Überlappungs-Clusters teilen sich die Breite.
  static List<_EventBlock> _layoutDayEvents(List<Meeting> meetings, DateTime day) {
    final blocks =
        meetings.map((m) {
            final clamp = CalendarUtils.clampToDay(m.start, m.end, day);
            return _EventBlock(meeting: m, start: clamp.displayStart, end: clamp.displayEnd);
          }).toList()
          ..sort((a, b) => a.start.compareTo(b.start));

    final active = <_EventBlock>[];
    final cluster = <_EventBlock>[];

    void closeCluster() {
      final columns = cluster.isEmpty ? 1 : cluster.map((b) => b.column).reduce((a, b) => a > b ? a : b) + 1;
      for (final b in cluster) {
        b.columns = columns;
      }
      cluster.clear();
    }

    for (final block in blocks) {
      active.removeWhere((b) => !b.end.isAfter(block.start));
      if (active.isEmpty) closeCluster();

      final usedColumns = active.map((b) => b.column).toSet();
      var column = 0;
      while (usedColumns.contains(column)) {
        column++;
      }
      block.column = column;
      active.add(block);
      cluster.add(block);
    }
    closeCluster();

    return blocks;
  }
}

class _EventBlock {
  _EventBlock({required this.meeting, required this.start, required this.end});

  final Meeting meeting;
  final DateTime start;
  final DateTime end;
  int column = 0;
  int columns = 1;
}
