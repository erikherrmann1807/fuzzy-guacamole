library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuzzy_guacamole/constants.dart';
import 'package:fuzzy_guacamole/models/appointment_model.dart';
import 'package:fuzzy_guacamole/providers/firebase_firestore_provider.dart';
import 'package:fuzzy_guacamole/providers/meetings_provider.dart';
import 'package:fuzzy_guacamole/providers/users_provider.dart';
import 'package:fuzzy_guacamole/screens/accountmanagement/account_management_screen.dart';
import 'package:fuzzy_guacamole/screens/auth/app_loading_page.dart';
import 'package:fuzzy_guacamole/screens/settings/settingsmenu.dart';
import 'package:fuzzy_guacamole/styles/colors.dart';
import 'package:fuzzy_guacamole/styles/styles.dart';
import 'package:fuzzy_guacamole/utils/utils.dart';
import 'package:fuzzy_guacamole/widgets/app_bar.dart';
import 'package:fuzzy_guacamole/widgets/default_button.dart';
import 'package:fuzzy_guacamole/widgets/event_widget.dart';
import 'package:fuzzy_guacamole/widgets/home_widgets/weather_widget.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

part '../appointments/appointment_editor.dart';
part '../appointments/priority_picker.dart';
part 'views/calendar_month.dart';
part '../home/home_screen.dart';

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
late DateTime selectedDate;

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
    if (index == 2) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    final username = ref.watch(usernameProvider);
    //TODO: Refresh username, when changed
    return username.when(
      data: (username) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          //drawer: MyDrawer(username: username),
          appBar: _getCurrentAppBar(username),
          body: _getCurrentScreen(),
          bottomNavigationBar: BottomAppBar(
            height: size.height * 0.07,
            shape: CircularNotchedRectangle(),
            notchMargin: 10.0,
            color: MyColors.raisinBlack,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(Icons.home),
                        color: _selectedIndex == 0 ? MyColors.white : MyColors.white,
                        onPressed: () => _onItemTapped(0),
                      ),
                      SizedBox(width: size.width * 0.06),
                      IconButton(
                        icon: Icon(Icons.calendar_month),
                        color: _selectedIndex == 1 ? MyColors.white : MyColors.white,
                        onPressed: () => _onItemTapped(1),
                      ),
                      SizedBox(width: size.width * 0.08),
                    ],
                  ),
                ),
                SizedBox(width: 40),
                Expanded(
                  child: Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(width: size.width * 0.08),
                      IconButton(
                        icon: Icon(Icons.person),
                        color: _selectedIndex == 3 ? MyColors.white : MyColors.white,
                        onPressed: () => _onItemTapped(3),
                      ),
                      SizedBox(width: size.width * 0.06),
                      IconButton(
                        icon: Icon(Icons.settings),
                        color: _selectedIndex == 4 ? MyColors.white : MyColors.white,
                        onPressed: () => _onItemTapped(4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: Transform.translate(
            offset: Offset(0, 5),
            child: FloatingActionButton(
              shape: CircleBorder(),
              backgroundColor: MyColors.raisinBlack,
              onPressed: () => onButtonPress(),
              child: Icon(Icons.add, color: MyColors.white),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        );
      },
      loading: () => AppLoadingPage(),
      error: (err, stack) => Center(child: Text('Fehler: $err')),
    );
  }

  Widget _getCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return HomeScreen();
      case 1:
        return MonthlyScreen();
      case 3:
        return AccountManagementScreen();
      case 4:
        return SettingsMenu();
      default:
        return MonthlyScreen();
    }
  }

  AppBar _getCurrentAppBar(String username) {
    switch (_selectedIndex) {
      case 0:
        return customAppBar('Hallo👋, $username!', _selectedIndex, () => {});
      case 1:
        return customAppBar('Hallo👋, $username!', _selectedIndex, () => resetSelectedDate());
      case 3:
        return customAppBar('Account Management', _selectedIndex, () => {});
      case 4:
        return customAppBar('Settings', _selectedIndex, () => {});
      default:
        return customAppBar('Hallo👋, $username!', _selectedIndex, () => {});
    }
  }

  void resetSelectedDate() {
    setState(() {
      selectedDate = DateTime.now();
    });
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
