import 'package:flutter/material.dart';

class Meeting {
  String? id;
  String eventName;
  String description;
  DateTime start;
  DateTime end;
  Color backgroundColor;
  bool isAllDay;

  Meeting({
    this.id,
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
    'start': start.toString(),
    'end': end.toString(),
    'backgroundColor': backgroundColor.toARGB32(),
    'isAllDay': isAllDay,
  };

  factory Meeting.fromJson(Map<String, dynamic> json, {String? id}) {
    return Meeting(
      id: id,
      eventName: json['eventName'] as String,
      description: json['description'] as String,
      start: DateTime.parse(json['start'].toString()),
      end: DateTime.parse(json['end'].toString()),
      backgroundColor: Color(json['backgroundColor']),
      isAllDay: json['isAllDay'] as bool,
    );
  }
}
