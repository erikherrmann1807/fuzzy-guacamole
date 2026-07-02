import 'package:fuzzy_guacamole/data/models/user_model.dart';
import 'package:fuzzy_guacamole/data/services/database_service.dart';

class UserRepository {
  final DatabaseService db;
  UserRepository(this.db);

  Future<Member?> fetch() => db.getMember();
  Future<void> updateName(String name) => db.updateMemberName(name);
  Future<void> create(Member member) => db.createMember(member);
  Future<void> delete() => db.deleteMember();
}
