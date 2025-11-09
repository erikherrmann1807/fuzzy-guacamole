import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuzzy_guacamole/data/models/user_model.dart';
import 'package:fuzzy_guacamole/data/providers/firebase_firestore_provider.dart';

class ProfileState {
  final bool loading;
  final Member? member;
  final String? error;
  const ProfileState({this.loading=false, this.member, this.error});
  ProfileState copy({bool? loading, Member? member, String? error}) =>
      ProfileState(loading : loading ?? this.loading,
          member: member ?? this.member,
          error: error);
}

class ProfileViewModel extends StateNotifier<ProfileState> {
  final Ref ref;
  ProfileViewModel(this.ref) : super(const ProfileState());

  Future<void> load() async {
    final repo = ref.read(userRepositoryProvider);
    if (repo == null) { state = const ProfileState(); return; }
    state = state.copy(loading: true, error: null);
    try {
      final member = await repo.fetch();
      state = state.copy(loading: false, member: member);
    } catch (e) {
      state = state.copy(loading: false, error: e.toString());
    }
  }

  Future<void> updateName(String name) async {
    final repo = ref.read(userRepositoryProvider);
    if (repo == null) return;
    await repo.updateName(name);
    await load();
  }
}

// Provider
final profileViewModelProvider =
StateNotifierProvider<ProfileViewModel, ProfileState>(
      (ref) => ProfileViewModel(ref),
);
