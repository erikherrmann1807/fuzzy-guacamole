import 'package:flutter/material.dart';
import 'package:fuzzy_guacamole/styles/colors.dart';
import 'package:fuzzy_guacamole/styles/styles.dart';

AppBar customAppBar(String title, int index, VoidCallback function) {
  return AppBar(
    actions: [
      if (index == 1) IconButton(
          onPressed: function,
          icon: Icon(Icons.today, color: MyColors.white)
      )
    ],
    title: Text(title, style: appBarText),
    backgroundColor: MyColors.raisinBlack,
  );
}
