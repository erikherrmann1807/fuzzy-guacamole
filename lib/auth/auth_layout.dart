import 'package:flutter/material.dart';
import 'package:fuzzy_guacamole/auth/app_loading_page.dart';
import 'package:fuzzy_guacamole/auth/auth_service.dart';
import 'package:fuzzy_guacamole/auth/login_screen.dart';
import 'package:fuzzy_guacamole/eventCalendar/calendar_screen.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key, this.pageIfNotConnected});
  final Widget? pageIfNotConnected;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: authService,
      builder: (context, authService, child) {
        return StreamBuilder(
          stream: authService.authStateChanges,
          builder: (context, snapshot) {
            Widget widget;
            if (snapshot.connectionState == ConnectionState.waiting) {
              widget = AppLoadingPage();
            } else if (snapshot.hasData) {
              widget = EventCalendarScreen();
            } else {
              widget = pageIfNotConnected ?? LoginScreen();
            }
            return widget;
          },
        );
      },
    );
  }
}
