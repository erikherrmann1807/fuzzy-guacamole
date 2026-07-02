import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuzzy_guacamole/utils/utils.dart';

/// Präsentations-State der Kalenderansichten: sichtbarer Monat und
/// ausgewählter Tag. Ersetzt die früheren globalen Top-Level-Variablen.
class CalendarState {
  /// Erster Tag des aktuell sichtbaren Monats.
  final DateTime visibleMonth;

  /// Ausgewählter Tag (nur Datum, ohne Uhrzeit).
  final DateTime selectedDate;

  CalendarState({required DateTime visibleMonth, required DateTime selectedDate})
    : visibleMonth = DateTime(visibleMonth.year, visibleMonth.month),
      selectedDate = CalendarUtils.dateOnly(selectedDate);

  factory CalendarState.today() {
    final now = DateTime.now();
    return CalendarState(visibleMonth: now, selectedDate: now);
  }

  /// 6x7-Raster der im Monat sichtbaren Kalendertage.
  List<DateTime> get datesGrid => CalendarUtils.generateDatesGrid(visibleMonth);

  CalendarState copyWith({DateTime? visibleMonth, DateTime? selectedDate}) => CalendarState(
    visibleMonth: visibleMonth ?? this.visibleMonth,
    selectedDate: selectedDate ?? this.selectedDate,
  );
}

class CalendarViewModel extends StateNotifier<CalendarState> {
  CalendarViewModel() : super(CalendarState.today());

  void goToPreviousMonth() => _shiftMonth(-1);

  void goToNextMonth() => _shiftMonth(1);

  void _shiftMonth(int offset) {
    final m = state.visibleMonth;
    state = state.copyWith(visibleMonth: DateTime(m.year, m.month + offset));
  }

  void showMonth(DateTime month) => state = state.copyWith(visibleMonth: month);

  void selectDate(DateTime date) => state = state.copyWith(selectedDate: date);

  /// Springt zurück auf "heute" (Monat und Auswahl).
  void resetToToday() => state = CalendarState.today();
}

final calendarViewModelProvider = StateNotifierProvider<CalendarViewModel, CalendarState>(
  (ref) => CalendarViewModel(),
);
