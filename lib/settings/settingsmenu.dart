import 'package:flutter/material.dart';
import 'package:fuzzy_guacamole/drawer.dart';
import 'package:fuzzy_guacamole/home/main.dart';

class SettingsMenu extends StatefulWidget {
  const SettingsMenu({super.key});

  @override
  _SettingsMenuState createState() => _SettingsMenuState();
}

class _SettingsMenuState extends State<SettingsMenu> {
  /*void onViewChanged(String view) {
    switch (view) {
      case 'month':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyHomePage(initialView: 'month')),
        );
        break;
      case 'day':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyHomePage(initialView: 'day')),
        );
        break;
      case 'week':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyHomePage(initialView: 'week')),
        );
        break;
      case 'settings':
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SettingsMenu()));
        break;
      default:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyHomePage(initialView: 'month')),
        );
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //drawer: MyDrawer(onViewChanged: onViewChanged),
      appBar: AppBar(title: const Text('Einstellungen')),
    );
  }
}
