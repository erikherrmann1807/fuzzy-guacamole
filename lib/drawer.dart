import 'package:flutter/material.dart';
import 'package:fuzzy_guacamole/calendarviews/calendarviewday.dart';
import 'package:fuzzy_guacamole/calendarviews/calendarviewmonth.dart';
import 'package:fuzzy_guacamole/calendarviews/calendarviewweek.dart';
import 'package:fuzzy_guacamole/settings/settingsmenu.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  _MyDrawerState createState() => _MyDrawerState();

}

class _MyDrawerState extends State<MyDrawer>{

  bool checkboxValue1 = false;
  bool checkboxValue2 = false;
  bool checkboxValue3 = false;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.black26,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 8, bottom: 8),
                  child: Text(
                    'Flutter Kalender',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(width: 10,),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Erik',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                )
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
              setState(() {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CalendarViewDay()));
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_view_week_sharp),
            title: const Text('Woche'),
            onTap: () {
              setState(() {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CalendarViewWeek()));
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_view_month_sharp),
            title: const Text('Monat'),
            onTap: () {
              setState(() {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CalendarViewMonth()));
              });
            },
          ),
          const Divider(color: Colors.grey,),
          CheckboxListTile(
            controlAffinity: ListTileControlAffinity.leading,
            //checkColor: ,
            title: const Text('Label 1'),
            value: checkboxValue1,
            onChanged: (bool? value) {
              setState(() {
                checkboxValue1 = value!;
              });
            },
          ),
          CheckboxListTile(
            controlAffinity: ListTileControlAffinity.leading,
            //checkColor: ,
            title: const Text('Label 2'),
            value: checkboxValue2,
            onChanged: (bool? value) {
              setState(() {
                checkboxValue2 = value!;
              });
            },
          ),
          CheckboxListTile(
            controlAffinity: ListTileControlAffinity.leading,
            //checkColor: ,
            title: const Text('Label 3'),
            value: checkboxValue3,
            onChanged: (bool? value) {
              setState(() {
                checkboxValue3 = value!;
              });
            },
          ),
          const Divider(color: Colors.grey,),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Einstellung'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsMenu()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline_rounded),
            title: const Text('Hilfe'),
            onTap: () {},
          )
        ],
      ),
    );
  }
}