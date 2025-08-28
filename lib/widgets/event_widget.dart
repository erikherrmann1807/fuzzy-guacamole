import 'package:flutter/material.dart';
import 'package:fuzzy_guacamole/styles/colors.dart';

class EventWidget extends StatefulWidget {
  const EventWidget({super.key, required this.startTime, required this.endTime, required this.description, required this.eventName, required this.function});
  final String startTime;
  final String endTime;
  final String description;
  final String eventName;
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
        height: 60,
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              //TODO: Create Custom Widget with onTap Event
              Icon(Icons.snowboarding),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(widget.eventName),
                  Text(
                    '${widget.startTime}-${widget.endTime}${widget.description.isNotEmpty ? ' • ${widget.description}' : ''}',
                  ),
                ],
              ),
              Icon(Icons.flag),
            ],
          ),
        ),
      ),
    );
  }
}
