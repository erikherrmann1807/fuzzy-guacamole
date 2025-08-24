library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuzzy_guacamole/constants.dart';
import 'package:fuzzy_guacamole/models/appointment_model.dart';
import 'package:fuzzy_guacamole/drawer.dart';
import 'package:fuzzy_guacamole/providers/firebase_firestore_provider.dart';
import 'package:fuzzy_guacamole/providers/users_provider.dart';
import 'package:fuzzy_guacamole/screens/auth/app_loading_page.dart';
import 'package:fuzzy_guacamole/screens/calendar/views/calendar_month.dart';
import 'package:fuzzy_guacamole/styles/colors.dart';
import 'package:intl/intl.dart';

part '../appointments/appointment_editor.dart';
part '../appointments/color_picker.dart';

class EventCalendarScreen extends ConsumerStatefulWidget {
  const EventCalendarScreen({super.key});

  @override
  ConsumerState<EventCalendarScreen> createState() => _EventCalendarScreenState();
}

int _selectedColorIndex = 0;
Meeting? _selectedAppointment;
late DateTime _startDate;
late TimeOfDay _startTime;
late DateTime _endDate;
late TimeOfDay _endTime;
late bool _isAllDay;
String _subject = '';
String _notes = '';

class _EventCalendarScreenState extends ConsumerState<EventCalendarScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedAppointment = null;
    _selectedColorIndex = 0;
    _subject = '';
    _notes = '';
    _startDate = DateTime.now();
    _endDate = DateTime.now();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final username = ref.watch(usernameProvider);
    return username.when(
      data: (username) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          drawer: MyDrawer(username: username),
          appBar: AppBar(
            title: Text('Monatsansicht'),
          ),
          body: MonthlyScreen(),
          bottomNavigationBar: BottomNavigationBar(
              items: [
                BottomNavigationBarItem(icon: Icon(Icons.wheelchair_pickup), label: 'Rollstuhl'),
                BottomNavigationBarItem(icon: Icon(Icons.wheelchair_pickup), label: 'Rollstuhl'),
                BottomNavigationBarItem(icon: Icon(Icons.wheelchair_pickup), label: 'Rollstuhl'),
              ],
            currentIndex: _selectedIndex,
            selectedItemColor: MyColors.raisinBlack,
            onTap: _onItemTapped,
          ),
          floatingActionButton: FloatingActionButton(
              backgroundColor: MyColors.raisinBlack,
              onPressed: () => onButtonPress(),
              child: Icon(Icons.add, color: MyColors.white,)),
        );
      },
      loading: () => AppLoadingPage(),
      error: (err, stack) => Center(child: Text('Fehler: $err')),
    );
  }

  void onButtonPress() {
    _selectedAppointment = null;
    _isAllDay = false;
    _selectedColorIndex = 0;
    _subject = '';
    _notes = '';

    _startDate = DateTime.now();
    _endDate = _startDate.add(Duration(hours: 1));

    _startTime = TimeOfDay(hour: _startDate.hour, minute: _startDate.minute);
    _endTime = TimeOfDay(hour: _endDate.hour, minute: _endDate.minute);

    Navigator.pushNamed(context, '/meetingEditor');
  }
}
