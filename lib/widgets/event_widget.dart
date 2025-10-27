import 'package:flutter/material.dart';
import 'package:fuzzy_guacamole/styles/colors.dart';
import 'package:fuzzy_guacamole/styles/styles.dart';
import 'package:gap/gap.dart';

class EventWidget extends StatefulWidget {
  const EventWidget({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.description,
    required this.eventName,
    required this.function,
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
  final VoidCallback function;

  @override
  State<EventWidget> createState() => _EventWidgetState();
}

class _EventWidgetState extends State<EventWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.function(),
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
                      Text(widget.eventName, style: eventTitle, overflow: TextOverflow.ellipsis),
                      Text(
                        widget.description.isNotEmpty ? widget.description : '',
                        style: eventText,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      Gap(5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${widget.startTime}${widget.endTime}',
                                style: eventText,
                                overflow: TextOverflow.ellipsis,
                              ),
                              widget.isAllDay ? Icon(Icons.event_repeat) : Text(""),
                            ],
                          ),
                          Chip(
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                            label: Text(widget.priority, style: tagText),
                            backgroundColor: widget.labelColor,
                            side: BorderSide.none,
                            shape: RoundedSuperellipseBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
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
