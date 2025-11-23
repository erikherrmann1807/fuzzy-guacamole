import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuzzy_guacamole/utils/utils.dart';

final localProvider = FutureProvider<String>((ref) {
  return getLocale();
});
