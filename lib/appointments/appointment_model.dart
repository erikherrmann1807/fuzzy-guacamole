import 'package:flutter/material.dart';

class Meeting {
  String eventName;
  String description;
  DateTime start;
  DateTime end;
  Color backgroundColor;
  bool isAllDay;

  Meeting({
    required this.eventName,
    required this.description,
    required this.start,
    required this.end,
    required this.backgroundColor,
    required this.isAllDay,
  });

  Map<String, dynamic> toJson() => {
    'eventName': eventName,
    'description': description,
    'start': start,
    'end': end,
    'backgroundColor': backgroundColor,
    'isAllDay': isAllDay,
  };

  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      eventName: json['eventName'],
      description: json['description'],
      start: json['start'],
      end: json['end'],
      backgroundColor: json['backgroundColor'],
      isAllDay: ['isAllDay'] as bool,
    );
  }
}
