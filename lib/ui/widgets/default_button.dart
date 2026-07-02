import 'package:flutter/material.dart';
import 'package:fuzzy_guacamole/styles/colors.dart';
import 'package:fuzzy_guacamole/styles/styles.dart';

class DefaultButton extends StatelessWidget {
  const DefaultButton({super.key, required this.onTap, required this.title, this.destructive = false});

  final VoidCallback onTap;
  final String title;

  /// Hebt destruktive Aktionen (z. B. Logout) farblich hervor.
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        height: MediaQuery.of(context).size.height * 0.05,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          border: Border.all(),
          color: MyColors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(1.5, 2), spreadRadius: 1, blurStyle: BlurStyle.solid),
          ],
        ),
        child: Text(title, style: destructive ? logoutText : defaultButtonText),
      ),
    );
  }
}
