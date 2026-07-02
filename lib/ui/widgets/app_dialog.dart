import 'package:flutter/material.dart';
import 'package:fuzzy_guacamole/styles/colors.dart';

/// Einheitlicher Dialograhmen der App (Rahmen, Schatten, Titel).
class AppDialog extends StatelessWidget {
  const AppDialog({super.key, required this.title, required this.child, this.maxHeight = 400});

  final String title;
  final Widget child;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: size.width,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(),
          color: MyColors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(1.5, 2), spreadRadius: 2, blurStyle: BlurStyle.solid),
          ],
        ),
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Flexible(child: SingleChildScrollView(child: child)),
          ],
        ),
      ),
    );
  }
}

/// Einheitliche Dekoration für Text-Eingabefelder in Dialogen.
InputDecoration dialogInputDecoration({required String label, required IconData icon}) {
  return InputDecoration(
    hintText: label,
    labelText: label,
    prefixIcon: Icon(icon, color: MyColors.raisinBlack),
    errorStyle: const TextStyle(fontSize: 14.0),
    labelStyle: const TextStyle(color: MyColors.raisinBlack),
    border: const OutlineInputBorder(
      borderSide: BorderSide(color: MyColors.raisinBlack),
      borderRadius: BorderRadius.all(Radius.circular(9.0)),
    ),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: MyColors.raisinBlack),
      borderRadius: BorderRadius.all(Radius.circular(9.0)),
    ),
  );
}
