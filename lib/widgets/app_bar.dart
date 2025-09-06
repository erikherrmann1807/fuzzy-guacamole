import 'package:flutter/material.dart';
import 'package:fuzzy_guacamole/styles/colors.dart';
import 'package:fuzzy_guacamole/styles/styles.dart';

AppBar customAppBar(String title) {
  return AppBar(
      title: Text(title, style: appBarText),
    backgroundColor: MyColors.raisinBlack,
  );
}
