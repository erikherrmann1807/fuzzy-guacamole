import 'package:flutter/material.dart';
import 'package:fuzzy_guacamole/l10n/l10n_extensions.dart';
import 'package:fuzzy_guacamole/styles/colors.dart';
import 'package:fuzzy_guacamole/styles/styles.dart';
import 'package:gap/gap.dart';

class EventWidget extends StatelessWidget {
  const EventWidget({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.description,
    required this.eventName,
    required this.onTap,
    required this.priority,
    required this.labelColor,
    required this.isAllDay,
  });

  final String startTime;
  final String endTime;
  final String description;
  final String eventName;
  final String priority;
  final Color labelColor;
  final bool isAllDay;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 115,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(),
            color: MyColors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(color: Colors.black, offset: Offset(1.5, 2), spreadRadius: 1, blurStyle: BlurStyle.solid),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(eventName, style: eventTitle, overflow: TextOverflow.ellipsis),
                      Text(description, style: eventText, overflow: TextOverflow.ellipsis, maxLines: 2),
                      const Gap(5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text('$startTime$endTime', style: eventText, overflow: TextOverflow.ellipsis),
                              if (isAllDay) const Icon(Icons.event_repeat),
                            ],
                          ),
                          Chip(
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                            label: Text(localizedPriorityName(context, priority), style: tagText),
                            backgroundColor: labelColor,
                            side: BorderSide.none,
                            shape: const RoundedSuperellipseBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
