import 'package:flutter/material.dart';
import 'package:fuzzy_guacamole/constants.dart';
import 'package:fuzzy_guacamole/l10n/l10n_extensions.dart';
import 'package:fuzzy_guacamole/styles/colors.dart';

/// Dialog zur Auswahl der Priorität (Label-Farbe).
/// Gibt den gewählten Index über `Navigator.pop` zurück.
class PriorityPicker extends StatelessWidget {
  const PriorityPicker({super.key, required this.selectedIndex});

  final int selectedIndex;

  static Future<int?> show(BuildContext context, {required int selectedIndex}) {
    return showDialog<int>(
      context: context,
      barrierDismissible: true,
      builder: (_) => PriorityPicker(selectedIndex: selectedIndex),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    const tileHeight = 56.0;
    const listVerticalPadding = 24.0;
    final desiredHeight = listVerticalPadding + tileHeight * labelColors.length;
    final maxHeight = size.height * 0.9;
    final containerHeight = desiredHeight <= maxHeight ? desiredHeight : maxHeight;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: size.width,
        padding: const EdgeInsets.only(left: 12),
        decoration: BoxDecoration(
          border: Border.all(),
          color: MyColors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(1.5, 2), spreadRadius: 2, blurStyle: BlurStyle.solid),
          ],
        ),
        child: SizedBox(
          height: containerHeight,
          width: double.maxFinite,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: listVerticalPadding / 2),
            physics: const ClampingScrollPhysics(),
            itemExtent: tileHeight,
            itemCount: labelColors.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(index == selectedIndex ? Icons.lens : Icons.trip_origin, color: labelColors[index]),
                title: Text(localizedPriorityName(context, labelNames[index])),
                onTap: () => Navigator.of(context).pop(index),
              );
            },
          ),
        ),
      ),
    );
  }
}
