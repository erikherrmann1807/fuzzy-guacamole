import 'package:flutter/material.dart';
import 'package:fuzzy_guacamole/appointments/appointment_create_screen.dart';

class AppointmentMulm {
  void showMyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Appointment Erstellung'),
        content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AppointmentCreateScreen();
            }
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, 'Cancel'), child: Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, 'Ok'), child: Text('Ok')),
        ],
      ),
    );
  }
}