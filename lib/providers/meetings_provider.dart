import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fuzzy_guacamole/appointments/appointment_model.dart';
import 'package:fuzzy_guacamole/services/database_service.dart';

part 'meetings_provider.g.dart';

DatabaseService _databaseService = DatabaseService();

@riverpod
Future<List<Meeting>> meetings(ref) async {
  List<Meeting> allMeetings = [];
  _databaseService.startListening((meetings) {
    allMeetings.clear();
    allMeetings.addAll(meetings);
  });
  return allMeetings;
}

@riverpod
Future<String> username(ref) async {
  final username = await _databaseService.getUsername();
  return username;
}
