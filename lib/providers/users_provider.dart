import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuzzy_guacamole/providers/firebase_firestore_provider.dart';

final usernameProvider = FutureProvider<String>((ref) async {
  final database = ref.watch(fireStoreProvider)!;
  return await database.getUsername();
});
