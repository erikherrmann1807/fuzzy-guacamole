import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:fuzzy_guacamole/appointments/appointment_model.dart';

class AppointmentCreateScreen extends StatefulWidget {
  const AppointmentCreateScreen({super.key});

  @override
  State<AppointmentCreateScreen> createState() => _AppointmentCreateScreenState();
}

class _AppointmentCreateScreenState extends State<AppointmentCreateScreen> {
  late Appointment appointment;
  late TextEditingController _eventNameController;
  late DateTime _selectedStartDate = DateTime.now();
  late DateTime _selectedEndDate = DateTime.now();
  late TimeOfDay _selectedStartTime = TimeOfDay.now();
  late TimeOfDay _selectedEndTime = TimeOfDay.now();
  late Color _backgroundColor;
  late bool isAllDay;

  late bool _isStart = true;
  late DateTime _initialDate;
  late TimeOfDay _initialTime;
  late Color pickerColor = Color(0xff443a49);
  late Color currentColor = Color(0xff443a49);

  @override
  void initState() {
    super.initState();
    _initialDate = DateTime.now();
    _initialTime = TimeOfDay.now();
    _eventNameController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child:
        _appointmentFields(context),
    );
  }

  Widget _appointmentFields(BuildContext context) {
    return SingleChildScrollView(
      child:
      Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Titel'),
            TextFormField(
              decoration: InputDecoration(
                  hintText: 'Event Name'
              ),
              controller: _eventNameController,
            ),
            Text('Startdatum'),
            _dateTimeSectionStart(_isStart),
            Text('Enddatum'),
            _dateTimeSectionEnd(_isStart),
            Text('Hintergrundfarbe'),
            colorPicker(),
            Text('Test')
          ]
      ),
    );
  }

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }
  
  Widget colorPicker() {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.03,
      width: MediaQuery.sizeOf(context).width * 0.15,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: currentColor,
      ),
      child: GestureDetector(
        onTap: _showColorPicker,
      )
    );
  }

  void _showColorPicker() {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text('Wähle eine Hintergrundfarbe'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: changeColor,
            ),
          ),
          actions: [
            ElevatedButton(
                onPressed: () {
                  setState(() => currentColor = pickerColor);
                  Navigator.of(context).pop();
                },
                child: Text('Bestätigen')
            )
          ],
        )
    );
  }

  Widget _dateTimeSectionStart(bool isStartDate) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: () {
                  _isStart = true;
                  _selectDate(context, _isStart);
                },
                child: Text(
                  '${_selectedStartDate.day.toString().padLeft(2, '0')}.'
                      '${_selectedStartDate.month.toString().padLeft(2, '0')}.'
                      '${_selectedStartDate.year}',
                ),
              ),
            ),
          ),
          Text('|'),
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: () {
                  _isStart = true;
                  _selectTime(context, _isStart);
                },
                child: Text(
                  '${_selectedStartTime.hour.toString().padLeft(2, '0')}'
                      ':${_selectedStartTime.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateTimeSectionEnd(bool isStartDate) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: () {
                  _isStart = false;
                  _selectDate(context, _isStart);
                },
                child: Text(
                  '${_selectedEndDate.day.toString().padLeft(2, '0')}.'
                      '${_selectedEndDate.month.toString().padLeft(2, '0')}.'
                      '${_selectedEndDate.year}',
                ),
              ),
            ),
          ),
          Text('|'),
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: () {
                  _isStart = false;
                  _selectTime(context, _isStart);
                },
                child: Text(
                  '${_selectedEndTime.hour.toString().padLeft(2, '0')}'
                      ':${_selectedEndTime.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectTime(BuildContext context, isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _initialTime,
    );
    if (picked != null && picked != _initialTime) {
      if (isStart) {
        setState(() {
          _selectedStartTime = picked;
        });
      }
      else {
        setState(() {
          _selectedEndTime = picked;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _initialDate) {
      if (isStart) {
        setState(() {
          _selectedStartDate = picked;
        });
      }
      else {
        setState(() {
          _selectedEndDate = picked;
        });
      }
    }
  }
}





