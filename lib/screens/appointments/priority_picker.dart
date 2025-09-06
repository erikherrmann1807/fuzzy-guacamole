part of '../../screens/calendar/calendar_screen.dart';

class _PriorityPicker extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PriorityPickerState();
}

class _PriorityPickerState extends State<_PriorityPicker> {
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
        padding: EdgeInsets.only(left: 12),
        decoration: BoxDecoration(
          border: Border.all(),
          color: MyColors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(1.5, 2),
              spreadRadius: 2,
              blurStyle: BlurStyle.solid,
            ),
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
                leading: Icon(
                  index == _selectedColorIndex ? Icons.lens : Icons.trip_origin,
                  color: labelColors[index],
                ),
                title: Text(labelNames[index]),
                onTap: () {
                  setState(() => _selectedColorIndex = index);
                  Future.delayed(const Duration(milliseconds: 200), () {
                    Navigator.of(context).pop();
                  });
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
