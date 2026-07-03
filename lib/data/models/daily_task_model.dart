import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Eine wiederkehrende Tagesaufgabe ("Daily Task"), die an jedem Tag erscheint.
///
/// Anders als ein Termin ist sie keinem festen Datum zugeordnet, sondern gehört
/// zu einer festen Liste täglicher Aufgaben. Der Erledigt-Status wird pro Tag
/// geführt: [lastCompletedDate] hält den (auf Mitternacht normalisierten) Tag
/// fest, an dem die Aufgabe zuletzt abgehakt wurde. Am nächsten Tag erscheint
/// sie dadurch automatisch wieder unerledigt.
@immutable
class DailyTask {
  final String? taskId;
  final String title;

  /// Optionale tägliche Erinnerung; es zählen nur Stunde und Minute.
  final DateTime? reminderTime;

  /// Auf Mitternacht normalisierter Tag der letzten Erledigung; `null` = nie.
  final DateTime? lastCompletedDate;

  /// Erstellungszeitpunkt, dient der stabilen Sortierung der Liste.
  final DateTime? createdAt;

  const DailyTask({this.taskId, required this.title, this.reminderTime, this.lastCompletedDate, this.createdAt});

  /// Ob die Aufgabe am (auf Mitternacht normalisierten) [day] erledigt ist.
  bool isDoneOn(DateTime day) {
    final done = lastCompletedDate;
    return done != null && done.year == day.year && done.month == day.month && done.day == day.day;
  }

  DailyTask copyWith({
    String? taskId,
    String? title,
    DateTime? reminderTime,
    bool clearReminder = false,
    DateTime? lastCompletedDate,
    bool clearCompleted = false,
    DateTime? createdAt,
  }) {
    return DailyTask(
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      reminderTime: clearReminder ? null : (reminderTime ?? this.reminderTime),
      lastCompletedDate: clearCompleted ? null : (lastCompletedDate ?? this.lastCompletedDate),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'reminderTime': reminderTime == null ? null : Timestamp.fromDate(reminderTime!),
    'lastCompletedDate': lastCompletedDate == null
        ? null
        : Timestamp.fromDate(DateTime(lastCompletedDate!.year, lastCompletedDate!.month, lastCompletedDate!.day)),
    'createdAt': createdAt == null ? FieldValue.serverTimestamp() : Timestamp.fromDate(createdAt!),
  };

  factory DailyTask.fromJson(Map<String, dynamic> json, {String? id}) {
    return DailyTask(
      taskId: id,
      title: json['title'] as String? ?? '',
      reminderTime: _parseDate(json['reminderTime']),
      lastCompletedDate: _parseDate(json['lastCompletedDate']),
      // Bei serverTimestamp und ausstehendem lokalen Write kann null ankommen.
      createdAt: _parseDate(json['createdAt']),
    );
  }

  /// Akzeptiert Firestore-`Timestamp` und ISO-String (lokaler Cache).
  static DateTime? _parseDate(Object? value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    throw FormatException('Ungültiges Datumsformat: $value');
  }
}

/// Stabile Sortierung der Aufgabenliste nach Erstellungszeit; noch nicht vom
/// Server bestätigte Einträge (createdAt == null) rutschen ans Ende.
int compareTasksByCreatedAt(DailyTask a, DailyTask b) {
  final aTime = a.createdAt;
  final bTime = b.createdAt;
  if (aTime == null || bTime == null) return aTime == null ? (bTime == null ? 0 : 1) : -1;
  return aTime.compareTo(bTime);
}
