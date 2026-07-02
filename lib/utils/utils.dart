/// Hilfsfunktionen rund um Kalendertage, Meetings und Agenda.
class CalendarUtils {
  CalendarUtils._(); // static-only

  /// Zellen im Monatsraster: 6 Wochen à 7 Tage.
  static const int gridCellCount = 42;

  /// Nur Datum (00:00) – wichtig für Schlüssel in Maps.
  static DateTime dateOnly(DateTime x) => DateTime(x.year, x.month, x.day);

  /// Start des Tages (00:00).
  static DateTime startOfDay(DateTime x) => DateTime(x.year, x.month, x.day);

  /// Ende des Tages (23:59:59.999).
  static DateTime endOfDay(DateTime x) => DateTime(x.year, x.month, x.day, 23, 59, 59, 999);

  /// Gleicher Kalendertag?
  static bool isSameDate(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  /// Falls ein Event genau um 00:00 endet (exklusives Ende) und nicht am selben Tag
  /// gestartet ist, wird der letzte Tag nicht doppelt gezählt.
  static DateTime effectiveLastDay(DateTime start, DateTime end) {
    final endDate = dateOnly(end);
    final endsAtMidnight =
        end.hour == 0 && end.minute == 0 && end.second == 0 && end.millisecond == 0 && end.microsecond == 0;
    if (endsAtMidnight && !isSameDate(start, end)) {
      return endDate.subtract(const Duration(days: 1));
    }
    return endDate;
  }

  /// Baut eine Map von Kalendertag -> Liste von Meetings/Objekten,
  /// die über mehrere Tage spannen können.
  ///
  /// [getStart] und [getEnd] liefern Start/Ende des Objekts.
  /// Innerhalb eines Tages wird nach Startzeit sortiert.
  static Map<DateTime, List<T>> buildMeetingsMapSpanning<T>(
    List<T> meetings,
    DateTime Function(T) getStart,
    DateTime Function(T) getEnd,
  ) {
    final map = <DateTime, List<T>>{};

    for (final m in meetings) {
      var s = getStart(m);
      var e = getEnd(m);

      // Robustheit: falls Start/Ende vertauscht wurden
      if (e.isBefore(s)) {
        final tmp = s;
        s = e;
        e = tmp;
      }

      DateTime day = dateOnly(s);
      final lastDay = effectiveLastDay(s, e);

      // Meeting auf alle betroffenen Tage abbilden
      while (!day.isAfter(lastDay)) {
        map.putIfAbsent(day, () => []).add(m);
        day = day.add(const Duration(days: 1));
      }
    }

    // Pro Tag nach Startzeit sortieren
    for (final list in map.values) {
      list.sort((a, b) => getStart(a).compareTo(getStart(b)));
    }
    return map;
  }

  /// HH:mm – führende Nullen.
  static String formatHHmm(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Schneidet Start/Ende auf den ausgewählten Tag zu und meldet,
  /// ob damit der **ganze** Tag ausgefüllt ist (für „Ganztägig“-Anzeige).
  static DayClamp clampToDay(DateTime globalStart, DateTime globalEnd, DateTime day) {
    final dayStart = startOfDay(day);
    final dayEnd = endOfDay(day);

    final displayStart = globalStart.isAfter(dayStart) ? globalStart : dayStart;
    final displayEnd = globalEnd.isBefore(dayEnd) ? globalEnd : dayEnd;

    final fillsFullDay = displayStart.isAtSameMomentAs(dayStart) && displayEnd.isAtSameMomentAs(dayEnd);

    return DayClamp(displayStart: displayStart, displayEnd: displayEnd, fillsFullDay: fillsFullDay);
  }

  /// Gesamtzahl der Kalendertage, über die sich ein Event erstreckt.
  static int totalDaysSpanned(DateTime start, DateTime end) =>
      effectiveLastDay(start, end).difference(dateOnly(start)).inDays + 1;

  /// 1-basierter Tag-Index eines Mehrtages-Events am [selectedDay].
  static int dayIndexWithinSpan(DateTime start, DateTime selectedDay) =>
      dateOnly(selectedDay).difference(dateOnly(start)).inDays + 1;

  /// 6x7-Raster der Kalendertage eines Monats, inklusive der angeschnittenen
  /// Tage des Vor- und Folgemonats. Alle Einträge sind reine Daten (00:00).
  /// [firstDayOfWeek] bestimmt, mit welchem Wochentag die Zeilen beginnen.
  static List<DateTime> generateDatesGrid(DateTime month, {int firstDayOfWeek = DateTime.monday}) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstWeekday = DateTime(month.year, month.month, 1).weekday;
    final leadingDays = (firstWeekday - firstDayOfWeek + 7) % 7;

    final dates = <DateTime>[
      for (int i = leadingDays; i > 0; i--) DateTime(month.year, month.month, 1 - i),
      for (int day = 1; day <= daysInMonth; day++) DateTime(month.year, month.month, day),
    ];

    final trailingDays = gridCellCount - dates.length;
    for (int day = 1; day <= trailingDays; day++) {
      dates.add(DateTime(month.year, month.month + 1, day));
    }

    return dates;
  }
}

class DayClamp {
  final DateTime displayStart;
  final DateTime displayEnd;
  final bool fillsFullDay;
  const DayClamp({required this.displayStart, required this.displayEnd, required this.fillsFullDay});
}
