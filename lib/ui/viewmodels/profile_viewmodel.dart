import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuzzy_guacamole/data/models/user_model.dart';
import 'package:fuzzy_guacamole/data/providers/firebase_auth_provider.dart';
import 'package:fuzzy_guacamole/data/providers/firebase_firestore_provider.dart';

class ProfileState {
  final bool loading;
  final Member? member;
  final String? error;
  const ProfileState({this.loading = false, this.member, this.error});
  ProfileState copyWith({bool? loading, Member? member, String? error}) =>
      ProfileState(loading: loading ?? this.loading, member: member ?? this.member, error: error);
}

class ProfileViewModel extends StateNotifier<ProfileState> {
  final Ref ref;
  ProfileViewModel(this.ref) : super(const ProfileState());

  Future<void> load() async {
    final repo = ref.read(userRepositoryProvider);
    if (repo == null) {
      state = const ProfileState();
      return;
    }
    state = state.copyWith(loading: true, error: null);
    try {
      var member = await repo.fetch();
      member ??= await _createMissingMember();
      state = state.copyWith(loading: false, member: member);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  /// Selbstheilung: Legt ein fehlendes Profildokument aus den
  /// Auth-Daten neu an (z. B. nach früher fehlgeschlagener Registrierung).
  Future<Member?> _createMissingMember() async {
    final repo = ref.read(userRepositoryProvider);
    final user = ref.read(authViewModelProvider).user;
    if (repo == null || user == null) return null;
    final email = user.email ?? '';
    final member = Member(userName: user.displayName ?? email, email: email);
    await repo.create(member);
    return member;
  }

  Future<void> updateName(String name) async {
    final repo = ref.read(userRepositoryProvider);
    if (repo == null) return;
    state = state.copyWith(loading: true, error: null);
    try {
      await repo.updateName(name);
      final member = await repo.fetch();
      state = state.copyWith(loading: false, member: member);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }
}
