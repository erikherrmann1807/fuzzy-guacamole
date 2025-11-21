import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuzzy_guacamole/data/providers/firebase_auth_provider.dart';
import 'package:fuzzy_guacamole/data/providers/firebase_firestore_provider.dart';
import 'package:fuzzy_guacamole/data/services/database_service.dart';
import 'package:fuzzy_guacamole/ui/screens/auth/login_screen.dart';
import 'package:fuzzy_guacamole/ui/screens/calendar/calendar_screen.dart';

class AuthLayout extends ConsumerWidget {
  const AuthLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseServiceProvider);
    final state = ref.watch(authViewModelProvider);

    /*
    if (state.isLoading) {
      return const AppLoadingPage();
    }
     */

    if (state.user == null || db == null) {
      return const LoginScreen();
    }

    return FutureBuilder(
      future: db.getMember(),
      builder: (context, snapshot) {
        /*
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AppLoadingPage();
        }
         */
        if (snapshot.hasError) {
          return const Text('Fehler beim Laden des Nutzerprofils');
        }
        /*
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text('Nutzerprofil wird erstellt...');
        }
         */
        return const EventCalendarScreen();
      },
    );
  }
}
