import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuzzy_guacamole/models/appointment_model.dart';
import 'package:fuzzy_guacamole/providers/firebase_firestore_provider.dart';

final meetingStreamProvider = StreamProvider.autoDispose<List<Meeting>>((ref) {
  final database = ref.watch(fireStoreProvider)!;
  return database.meetingsStream;
});
