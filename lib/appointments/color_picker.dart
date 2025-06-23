part of '../eventCalendar/calendar_view.dart';

class _ColorPicker extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ColorPickerState();
  }
}

class _ColorPickerState extends State<_ColorPicker> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.sizeOf(context).height * 0.43,
        child: ListView.builder(
          padding: const EdgeInsets.all(0),
          itemCount: _colorCollection.length - 1,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              contentPadding: const EdgeInsets.all(0),
              leading: Icon(
                index == _selectedColorIndex ? Icons.lens : Icons.trip_origin,
                color: _colorCollection[index],
              ),
              title: Text(_colorNames[index]),
              onTap: () {
                setState(() {
                  _selectedColorIndex = index;
                });
                Future.delayed(const Duration(milliseconds: 200), () {
                  Navigator.pop(context);
                });
              },
            );
          },
        ),
      ),
    );
  }
}
