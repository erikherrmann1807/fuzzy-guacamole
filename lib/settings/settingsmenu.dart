import 'package:flutter/material.dart';

class SettingsMenu extends StatefulWidget {
  const SettingsMenu({super.key});

  @override
  _SettingsMenuState createState() => _SettingsMenuState();
}

class _SettingsMenuState extends State<SettingsMenu> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Einstellungen')),
    );
  }
}
