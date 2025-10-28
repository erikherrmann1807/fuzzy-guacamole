import 'package:flutter/material.dart';
import 'package:fuzzy_guacamole/styles/colors.dart';
import 'package:fuzzy_guacamole/utils/utils.dart';
import 'package:fuzzy_guacamole/widgets/default_button.dart';

class MonthYearDialog extends StatefulWidget {
  const MonthYearDialog({
    super.key,
    required this.initialMonth,
    required this.onSelected,
  });

  final DateTime initialMonth;
  final void Function(DateTime newDate) onSelected;

  @override
  State<MonthYearDialog> createState() => _MonthYearDialogState();
}

class _MonthYearDialogState extends State<MonthYearDialog> {
  late int selectedMonthIndex;
  late int selectedYear;

  @override
  void initState() {
    super.initState();
    selectedMonthIndex = widget.initialMonth.month - 1;
    selectedYear = widget.initialMonth.year;
  }

  @override
  Widget build(BuildContext context) {
    final months = CalendarUtils.allMonths();
    final currentYear = DateTime.now().year;
    final years = List.generate(41, (i) => currentYear - 20 + i);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(),
          color: MyColors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(1.5, 2),
              spreadRadius: 1,
              blurStyle: BlurStyle.solid,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Monat und Jahr wählen",
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: selectedMonthIndex,
                            items: List.generate(months.length, (i) {
                              return DropdownMenuItem<int>(
                                value: i,
                                child: Text(months[i]),
                              );
                            }),
                            onChanged: (newIndex) {
                              if (newIndex != null) {
                                setState(() => selectedMonthIndex = newIndex);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: selectedYear,
                            items: years.map((y) {
                              return DropdownMenuItem<int>(
                                value: y,
                                child: Text(y.toString()),
                              );
                            }).toList(),
                            onChanged: (newYear) {
                              if (newYear != null) {
                                setState(() => selectedYear = newYear);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 100,
                        height: 40,
                        child: DefaultButton(
                          onTap: () {
                            final newDate = DateTime(
                              selectedYear,
                              selectedMonthIndex + 1,
                            );
                            widget.onSelected(newDate);
                            Navigator.of(context).pop();
                          },
                          title: 'OK',
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 100,
                        height: 40,
                        child: DefaultButton(
                          onTap: () => Navigator.of(context).pop(),
                          title: 'Abbrechen',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
