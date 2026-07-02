import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fuzzy_guacamole/constants.dart';
import 'package:fuzzy_guacamole/data/models/appointment_model.dart';
import 'package:fuzzy_guacamole/data/models/daily_task_model.dart';
import 'package:fuzzy_guacamole/data/models/user_model.dart';

/// Kapselt alle Firestore-Zugriffe für einen angemeldeten Nutzer ([uid]).
class DatabaseService {
  final FirebaseFirestore db;
  final String uid;

  DatabaseService({FirebaseFirestore? fireStore, required this.uid}) : db = fireStore ?? FirebaseFirestore.instance;

  CollectionReference<Meeting> get _meetingRef => db
      .collection(userCollectionRef)
      .doc(uid)
      .collection(meetingCollectionRef)
      .withConverter<Meeting>(
        fromFirestore: (snap, _) => Meeting.fromJson(snap.data()!, id: snap.id),
        toFirestore: (meet, _) => meet.toJson(),
      );

  CollectionReference<DailyTask> get _taskRef => db
      .collection(userCollectionRef)
      .doc(uid)
      .collection(taskCollectionRef)
      .withConverter<DailyTask>(
        fromFirestore: (snap, _) => DailyTask.fromJson(snap.data()!, id: snap.id),
        toFirestore: (task, _) => task.toJson(),
      );

  CollectionReference<Member> get _userRef => db
      .collection(userCollectionRef)
      .withConverter<Member>(
        fromFirestore: (snap, _) => Member.fromJson(snap.data()!),
        toFirestore: (user, _) => user.toJson(),
      );

  // --- Meetings ---
  Stream<List<Meeting>> get meetingsStream =>
      _meetingRef.snapshots().map((snap) => snap.docs.map((d) => d.data()).toList());

  /// Legt den Termin an und liefert die generierte Dokument-ID zurück
  /// (wird u. a. fürs Notification-Scheduling gebraucht).
  Future<String> addMeeting(Meeting meeting) async {
    final doc = await _meetingRef.add(meeting);
    return doc.id;
  }

  Future<void> deleteMeeting(String meetingId) => _meetingRef.doc(meetingId).delete();

  Future<void> updateMeeting(String meetingId, Meeting meeting) => _meetingRef.doc(meetingId).update(meeting.toJson());

  // --- Daily Tasks ---

  /// Alle Aufgaben eines Kalendertages, stabil nach Erstellungszeit sortiert.
  /// Die Sortierung passiert clientseitig, damit kein Composite-Index nötig ist.
  Stream<List<DailyTask>> tasksForDayStream(DateTime day) {
    final normalized = Timestamp.fromDate(DateTime(day.year, day.month, day.day));
    return _taskRef.where('date', isEqualTo: normalized).snapshots().map((snap) {
      final tasks = snap.docs.map((d) => d.data()).toList();
      tasks.sort((a, b) {
        final aTime = a.createdAt;
        final bTime = b.createdAt;
        if (aTime == null || bTime == null) return aTime == null ? (bTime == null ? 0 : 1) : -1;
        return aTime.compareTo(bTime);
      });
      return tasks;
    });
  }

  /// Legt die Aufgabe an und liefert die generierte Dokument-ID zurück.
  Future<String> addTask(DailyTask task) async {
    final doc = await _taskRef.add(task);
    return doc.id;
  }

  Future<void> updateTask(String taskId, DailyTask task) => _taskRef.doc(taskId).update(task.toJson());

  Future<void> deleteTask(String taskId) => _taskRef.doc(taskId).delete();

  // --- Member / User ---
  Future<void> createMember(Member member) => _userRef.doc(uid).set(member);

  /// Löscht das Nutzerdokument inklusive der Meetings- und Tasks-Subcollections,
  /// damit keine verwaisten Daten zurückbleiben.
  Future<void> deleteMember() async {
    final meetings = await _meetingRef.get();
    final tasks = await _taskRef.get();
    final batch = db.batch();
    for (final doc in meetings.docs) {
      batch.delete(doc.reference);
    }
    for (final doc in tasks.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_userRef.doc(uid));
    await batch.commit();
  }

  Future<void> updateMemberName(String userName) => _userRef.doc(uid).update({'userName': userName});

  Future<Member?> getMember() async {
    final doc = await _userRef.doc(uid).get();
    return doc.exists ? doc.data() : null;
  }
}
