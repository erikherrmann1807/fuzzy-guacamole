import 'package:flutter/material.dart';
import 'package:fuzzy_guacamole/styles/colors.dart';
import 'package:fuzzy_guacamole/styles/styles.dart';

AppBar customAppBar(String title, {bool showTodayButton = false, VoidCallback? onTodayPressed}) {
  return AppBar(
    actions: [
      if (showTodayButton)
        IconButton(
          onPressed: onTodayPressed,
          icon: const Icon(Icons.today, color: MyColors.white),
        ),
    ],
    title: Text(title, style: appBarText),
    backgroundColor: MyColors.raisinBlack,
  );
}
