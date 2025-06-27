import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fuzzy_guacamole/auth/auth_service.dart';
import 'package:fuzzy_guacamole/settings/settingsmenu.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class MyDrawer extends StatelessWidget {
  final Function(CalendarView) onViewChanged;

  MyDrawer({super.key, required this.onViewChanged});

  bool checkboxValue1 = false;
  bool checkboxValue2 = false;
  bool checkboxValue3 = false;

  @override
  Widget build(BuildContext context) {
    void popPage() {
      Navigator.pop(context);
    }

    void logout() async {
      try {
        await authService.value.signOut();
        popPage();
      } on FirebaseAuthException catch (e) {
        print(e.message);
      }
    }

    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.black26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 8, bottom: 8),
                  child: Text('Flutter Kalender', style: TextStyle(color: Colors.white, fontSize: 20)),
                ),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 40, color: Colors.grey),
                    ),
                    SizedBox(width: 10),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('Erik', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          /*ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Start'),
            onTap: () {
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => MyHomePage()),
              );
            },
          ),*/
          ListTile(
            leading: const Icon(Icons.calendar_view_day),
            title: const Text('Tag'),
            onTap: () {
              popPage();
              onViewChanged(CalendarView.day);
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_view_week_sharp),
            title: const Text('Woche'),
            onTap: () {
              popPage();
              onViewChanged(CalendarView.week);
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_view_month_sharp),
            title: const Text('Monat'),
            onTap: () {
              popPage();
              onViewChanged(CalendarView.month);
            },
          ),
          const Divider(color: Colors.grey),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Einstellung'),
            onTap: () {
              Navigator.pushNamed(context, '/settingsScreen');
            },
          ),
          ListTile(leading: const Icon(Icons.help_outline_rounded), title: const Text('Hilfe'), onTap: () {}),
          const Divider(color: Colors.grey),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
            onTap: () => logout(),
          ),
        ],
      ),
    );
  }
}
