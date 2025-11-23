import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuzzy_guacamole/data/providers/firebase_auth_provider.dart';
import 'package:fuzzy_guacamole/data/providers/firebase_firestore_provider.dart';
import 'package:fuzzy_guacamole/ui/screens/auth/login_screen.dart';
import 'package:fuzzy_guacamole/ui/screens/calendar/calendar_screen.dart';

class AuthLayout extends ConsumerWidget {
  const AuthLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseServiceProvider);
    final state = ref.watch(authViewModelProvider);

    if (state.user == null) {
      return const LoginScreen();
    }

    if (db == null) {
      return CircularProgressIndicator();
    }

    return FutureBuilder(
      future: db.getMember(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator(),),
          );
        }
        if (snapshot.hasError) {
          debugPrint("Member-Fehler: ${snapshot.error}");
          return const Text('Fehler beim Laden des Nutzerprofils');
        }
        final member = snapshot.data;
        if (member == null) {
          return LoginScreen();
        }
        return const EventCalendarScreen();
      },
    );
  }
}
