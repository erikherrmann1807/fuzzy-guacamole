import 'package:flutter/material.dart';
import 'package:fuzzy_guacamole/widgets/default_button.dart';

class SettingsMenu extends StatefulWidget {
  const SettingsMenu({super.key});

  @override
  _SettingsMenuState createState() => _SettingsMenuState();
}

class _SettingsMenuState extends State<SettingsMenu> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: DefaultButton(onTap: () => {}, title: "Hier passiert nichts"),
    );
  }
}
