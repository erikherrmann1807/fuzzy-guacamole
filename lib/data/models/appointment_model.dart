import 'package:flutter/material.dart';

class Meeting {
  String? meetingId;
  String eventName;
  String description;
  DateTime start;
  DateTime end;
  Color labelColor;
  String priority;
  bool isAllDay;

  Meeting({
    this.meetingId,
    required this.eventName,
    required this.description,
    required this.start,
    required this.end,
    required this.labelColor,
    required this.priority,
    required this.isAllDay,
  });

  Map<String, dynamic> toJson() => {
    'eventName': eventName,
    'description': description,
    'start': start.toString(),
    'end': end.toString(),
    'labelColor': labelColor.toARGB32(),
    'priority': priority,
    'isAllDay': isAllDay,
  };

  factory Meeting.fromJson(Map<String, dynamic> json, {String? id}) {
    return Meeting(
      meetingId: id,
      eventName: json['eventName'] as String,
      description: json['description'] as String,
      start: DateTime.parse(json['start'].toString()),
      end: DateTime.parse(json['end'].toString()),
      labelColor: Color(json['labelColor']),
      priority: json['priority'] as String,
      isAllDay: json['isAllDay'] as bool,
    );
  }
}
