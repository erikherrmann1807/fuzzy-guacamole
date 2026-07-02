import 'package:flutter/foundation.dart';
import 'package:fuzzy_guacamole/data/models/user_model.dart';
import 'package:fuzzy_guacamole/data/services/database_service.dart';
import 'package:fuzzy_guacamole/data/services/local_cache_service.dart';

class UserRepository {
  final DatabaseService db;
  final LocalCacheService? cache;
  UserRepository(this.db, {this.cache});

  Future<Member?> fetch() => db.getMember();
  Future<void> updateName(String name) => db.updateMemberName(name);
  Future<void> create(Member member) => db.createMember(member);

  /// Löscht die Nutzerdaten in Firestore und den lokalen Cache dazu.
  Future<void> delete() async {
    await db.deleteMember();
    try {
      await cache?.clearAll();
    } catch (e) {
      debugPrint('Lokaler Cache konnte nicht geleert werden: $e');
    }
  }
}
