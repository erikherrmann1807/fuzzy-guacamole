import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Ein Kalendertermin ("Meeting").
///
/// Wird in Firestore als `Timestamp` persistiert; [Meeting.fromJson] liest
/// zusätzlich das alte String-Format (`DateTime.toString()`), damit
/// Bestandsdaten weiter funktionieren.
@immutable
class Meeting {
  final String? meetingId;
  final String eventName;
  final String description;
  final DateTime start;
  final DateTime end;
  final Color labelColor;
  final String priority;
  final bool isAllDay;

  /// Minuten vor [start], zu denen erinnert wird; `null` = keine Erinnerung.
  final int? reminderMinutes;

  const Meeting({
    this.meetingId,
    required this.eventName,
    required this.description,
    required this.start,
    required this.end,
    required this.labelColor,
    required this.priority,
    required this.isAllDay,
    this.reminderMinutes,
  });

  /// Zeitpunkt, zu dem die Erinnerung ausgelöst werden soll.
  DateTime? get reminderTime => reminderMinutes == null ? null : start.subtract(Duration(minutes: reminderMinutes!));

  Meeting copyWith({
    String? meetingId,
    String? eventName,
    String? description,
    DateTime? start,
    DateTime? end,
    Color? labelColor,
    String? priority,
    bool? isAllDay,
    int? reminderMinutes,
    bool clearReminder = false,
  }) {
    return Meeting(
      meetingId: meetingId ?? this.meetingId,
      eventName: eventName ?? this.eventName,
      description: description ?? this.description,
      start: start ?? this.start,
      end: end ?? this.end,
      labelColor: labelColor ?? this.labelColor,
      priority: priority ?? this.priority,
      isAllDay: isAllDay ?? this.isAllDay,
      reminderMinutes: clearReminder ? null : (reminderMinutes ?? this.reminderMinutes),
    );
  }

  Map<String, dynamic> toJson() => {
    'eventName': eventName,
    'description': description,
    'start': Timestamp.fromDate(start),
    'end': Timestamp.fromDate(end),
    'labelColor': labelColor.toARGB32(),
    'priority': priority,
    'isAllDay': isAllDay,
    'reminderMinutes': reminderMinutes,
  };

  factory Meeting.fromJson(Map<String, dynamic> json, {String? id}) {
    return Meeting(
      meetingId: id,
      eventName: json['eventName'] as String? ?? '',
      description: json['description'] as String? ?? '',
      start: _parseDate(json['start']),
      end: _parseDate(json['end']),
      labelColor: Color(json['labelColor'] as int),
      priority: json['priority'] as String? ?? '',
      isAllDay: json['isAllDay'] as bool? ?? false,
      reminderMinutes: json['reminderMinutes'] as int?,
    );
  }

  static DateTime _parseDate(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    throw FormatException('Ungültiges Datumsformat: $value');
  }
}
