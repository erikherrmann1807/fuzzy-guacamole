import 'package:flutter/material.dart';

class Appointment {
  String eventName;
  DateTime start;
  DateTime end;
  Color backgroundColor;
  bool isAllDay;

  Appointment({
    required this.eventName,
    required this.start,
    required this.end,
    required this.backgroundColor,
    required this.isAllDay,
  });

  Map<String, dynamic> toJson() => {
    'eventName': eventName,
    'start': start,
    'end': end,
    'backgroundColor': backgroundColor,
    'isAllDay': isAllDay,
  };

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      eventName: json['eventName'],
      start: json['start'],
      end: json['end'],
      backgroundColor: json['backgroundColor'],
      isAllDay: ['isAllDay'] as bool,
    );
  }
}
