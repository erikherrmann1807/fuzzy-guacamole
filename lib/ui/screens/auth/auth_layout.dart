import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuzzy_guacamole/data/providers/firebase_auth_provider.dart';
import 'package:fuzzy_guacamole/data/services/database_service.dart';
import 'package:fuzzy_guacamole/ui/screens/auth/login_screen.dart';
import 'package:fuzzy_guacamole/ui/screens/calendar/calendar_screen.dart';

class AuthLayout extends ConsumerWidget {
  const AuthLayout({super.key, this.pageIfNotConnected});
  final Widget? pageIfNotConnected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authViewModelProvider);
    final databaseService = DatabaseService();

    /*
    if (state.isLoading) {
      return const AppLoadingPage();
    }
     */

    if (state.user == null) {
      return const LoginScreen();
    }

    return FutureBuilder<DocumentSnapshot>(
      future: databaseService.userRef.doc(state.user!.uid).get(),
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
        return pageIfNotConnected ?? const EventCalendarScreen();
      },
    );
  }
}
