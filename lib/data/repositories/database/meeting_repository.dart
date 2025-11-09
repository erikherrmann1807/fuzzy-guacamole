// lib/data/repositories/meeting_repository.dart
import 'package:fuzzy_guacamole/data/services/database_service.dart';
import 'package:fuzzy_guacamole/data/models/appointment_model.dart';

class MeetingRepository {
  final DatabaseService db;
  MeetingRepository(this.db);

  Stream<List<Meeting>> watchAll() => db.meetingsStream;
  Future<List<Meeting>> fetchOnce() async => await db.meetingsStream.first;

  Future<void> add(Meeting m) => db.addMeeting(m);
  Future<void> update(String id, Meeting m) => db.updateMeeting(id, m);
  Future<void> remove(String id) => db.deleteMeeting(id);
}
