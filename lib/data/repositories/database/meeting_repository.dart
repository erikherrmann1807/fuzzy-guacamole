import 'package:flutter/foundation.dart';
import 'package:fuzzy_guacamole/data/models/appointment_model.dart';
import 'package:fuzzy_guacamole/data/services/database_service.dart';
import 'package:fuzzy_guacamole/data/services/local_cache_service.dart';

/// Read-Through-/Write-Back-Repository für Termine:
/// liest zuerst aus dem lokalen Cache (sofortige Anzeige, auch offline),
/// hält ihn bei jedem Firestore-Snapshot aktuell (Server gewinnt) und
/// schreibt Mutationen sofort in den Cache, während Firestore sie im
/// Hintergrund synchronisiert.
class MeetingRepository {
  final DatabaseService db;
  final LocalCacheService cache;
  MeetingRepository(this.db, this.cache);

  Stream<List<Meeting>> watchAll() async* {
    try {
      final cached = await cache.readMeetings();
      if (cached.isNotEmpty) yield cached;
    } catch (e) {
      debugPrint('Meeting-Cache konnte nicht gelesen werden: $e');
    }
    yield* db.meetingsStream.map((items) {
      _updateCache(items);
      return items;
    });
  }

  Future<List<Meeting>> fetchOnce() async => await watchAll().first;

  /// Liefert die generierte Dokument-ID des neuen Termins.
  Future<String> add(Meeting m) async {
    final id = await db.addMeeting(m);
    await _guardCache(() => cache.upsertMeeting(id, m.copyWith(meetingId: id)));
    return id;
  }

  Future<void> update(String id, Meeting m) async {
    await db.updateMeeting(id, m);
    await _guardCache(() => cache.upsertMeeting(id, m.copyWith(meetingId: id)));
  }

  Future<void> remove(String id) async {
    await db.deleteMeeting(id);
    await _guardCache(() => cache.removeMeeting(id));
  }

  void _updateCache(List<Meeting> items) {
    // Nicht awaiten: der Stream soll nicht auf Disk-I/O warten.
    _guardCache(() => cache.writeMeetings(items));
  }

  /// Cache-Fehler dürfen Lese-/Schreiboperationen nie scheitern lassen.
  Future<void> _guardCache(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      debugPrint('Meeting-Cache konnte nicht aktualisiert werden: $e');
    }
  }
}
