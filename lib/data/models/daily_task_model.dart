import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Eine Tagesaufgabe ("Daily Task"), die einem Kalendertag zugeordnet ist.
///
/// [date] wird auf Mitternacht normalisiert gespeichert, damit Firestore
/// per Gleichheits-Query alle Aufgaben eines Tages liefern kann.
@immutable
class DailyTask {
  final String? taskId;
  final String title;
  final DateTime date;
  final bool isDone;

  /// Zeitpunkt der optionalen Erinnerung; `null` = keine Erinnerung.
  final DateTime? reminderTime;

  /// Erstellungszeitpunkt, dient der stabilen Sortierung innerhalb eines Tages.
  final DateTime? createdAt;

  const DailyTask({
    this.taskId,
    required this.title,
    required this.date,
    this.isDone = false,
    this.reminderTime,
    this.createdAt,
  });

  DailyTask copyWith({
    String? taskId,
    String? title,
    DateTime? date,
    bool? isDone,
    DateTime? reminderTime,
    bool clearReminder = false,
    DateTime? createdAt,
  }) {
    return DailyTask(
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      date: date ?? this.date,
      isDone: isDone ?? this.isDone,
      reminderTime: clearReminder ? null : (reminderTime ?? this.reminderTime),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'date': Timestamp.fromDate(DateTime(date.year, date.month, date.day)),
    'isDone': isDone,
    'reminderTime': reminderTime == null ? null : Timestamp.fromDate(reminderTime!),
    'createdAt': createdAt == null ? FieldValue.serverTimestamp() : Timestamp.fromDate(createdAt!),
  };

  factory DailyTask.fromJson(Map<String, dynamic> json, {String? id}) {
    return DailyTask(
      taskId: id,
      title: json['title'] as String? ?? '',
      date: _parseDate(json['date'])!,
      isDone: json['isDone'] as bool? ?? false,
      reminderTime: _parseDate(json['reminderTime']),
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
