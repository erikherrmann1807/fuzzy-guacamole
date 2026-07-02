import 'package:flutter/material.dart';
import 'package:fuzzy_guacamole/styles/colors.dart';

const List<Color> labelColors = [MyColors.highLabel, MyColors.lowLabel];

const List<String> labelNames = ['High', 'Low'];

const String meetingCollectionRef = 'meetings';
const String userCollectionRef = 'users';

/// Mindestens 8 Zeichen, mindestens ein Buchstabe und eine Ziffer.
const String passwordPattern = r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$';

/// 8–20 Zeichen, keine führenden/abschließenden oder doppelten `_`/`.`.
const String usernamePattern = r'^(?=[a-zA-Z0-9._]{8,20}$)(?!.*[_.]{2})[^_.].*[^_.]$';
