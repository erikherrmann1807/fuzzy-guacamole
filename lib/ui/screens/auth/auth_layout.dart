import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuzzy_guacamole/data/providers/firebase_auth_provider.dart';
import 'package:fuzzy_guacamole/ui/screens/auth/login_screen.dart';
import 'package:fuzzy_guacamole/ui/screens/calendar/calendar_screen.dart';

/// Zeigt je nach Anmeldestatus Login oder die Kalender-App.
/// Ein fehlendes Profildokument wird vom ProfileViewModel selbst angelegt.
class AuthLayout extends ConsumerWidget {
  const AuthLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authViewModelProvider.select((s) => s.user));
    return user == null ? const LoginScreen() : const EventCalendarScreen();
  }
}
