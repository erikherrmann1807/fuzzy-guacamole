part of '../../screens/calendar/calendar_screen.dart';

class _PriorityPicker extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PriorityPickerState();
  }
}

class _PriorityPickerState extends State<_PriorityPicker> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.sizeOf(context).height * 0.43,
        child: ListView.builder(
          padding: const EdgeInsets.all(0),
          itemCount: labelColors.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              contentPadding: const EdgeInsets.all(0),
              leading: Icon(index == _selectedColorIndex ? Icons.lens : Icons.trip_origin, color: labelColors[index]),
              title: Text(labelNames[index]),
              onTap: () {
                setState(() {
                  _selectedColorIndex = index;
                });
                Future.delayed(const Duration(milliseconds: 200), () {
                  Navigator.pop;
                });
              },
            );
          },
        ),
      ),
    );
  }
}
