import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fuzzy_guacamole/auth/app_loading_page.dart';
import 'package:fuzzy_guacamole/services/auth_service.dart';
import 'package:fuzzy_guacamole/auth/login_screen.dart';
import 'package:fuzzy_guacamole/eventCalendar/calendar_screen.dart';
import 'package:fuzzy_guacamole/services/database_service.dart';

class AuthLayout extends StatelessWidget {
  AuthLayout({super.key, this.pageIfNotConnected});
  final Widget? pageIfNotConnected;
  final DatabaseService databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: authService,
        builder: (context, authService, child) {
          return StreamBuilder(
              stream: authService.authStateChanges,
              builder: (context, snapshot) {
                final user = snapshot.data;

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AppLoadingPage();
                }

                if(user == null) {
                  return LoginScreen();
                }

                return FutureBuilder<DocumentSnapshot>(
                  future: databaseService.userRef.doc(user.uid).get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const AppLoadingPage();
                    }
                    if (snapshot.hasError) {
                      return const Text('Fehler beim Laden');
                    }
                    return EventCalendarScreen();
                  },
                );
              }
          );
        }
    );
  }
}
