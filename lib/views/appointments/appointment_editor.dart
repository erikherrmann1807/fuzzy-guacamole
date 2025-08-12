part of '../eventCalendar/calendar_screen.dart';

class MeetingEditor extends  ConsumerStatefulWidget {
  const MeetingEditor({super.key});

  @override
  ConsumerState<MeetingEditor> createState() => _MeetingEditorState();
}

class _MeetingEditorState extends ConsumerState<MeetingEditor> {

  Widget _getAppointmentEditor(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.all(0),
        children: <Widget>[
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
            leading: const Text(''),
            title: TextField(
              controller: TextEditingController(text: _subject),
              onChanged: (String value) {
                _subject = value;
              },
              keyboardType: TextInputType.multiline,
              maxLines: null,
              style: const TextStyle(fontSize: 25, color: Colors.black, fontWeight: FontWeight.w400),
              decoration: const InputDecoration(border: InputBorder.none, hintText: 'Add title'),
            ),
          ),
          const Divider(height: 1.0, thickness: 1),
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
            leading: const Icon(Icons.access_time, color: Colors.black54),
            title: Row(
              children: <Widget>[
                const Expanded(child: Text('All-day')),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Switch(
                      value: _isAllDay,
                      onChanged: (bool value) {
                        setState(() {
                          _isAllDay = value;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
            leading: const Text(''),
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 7,
                  child: GestureDetector(
                    child: Text(DateFormat('EEE, dd. MMM yyyy', 'de').format(_startDate), textAlign: TextAlign.left),
                    onTap: () async {
                      final DateTime? date = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );

                      if (date != null && date != _startDate) {
                        setState(() {
                          final Duration difference = _endDate.difference(_startDate);
                          _startDate = DateTime(date.year, date.month, date.day, _startTime.hour, _startTime.minute, 0);
                          _endDate = _startDate.add(difference);
                          _endTime = TimeOfDay(hour: _endDate.hour, minute: _endDate.minute);
                        });
                      }
                    },
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: _isAllDay
                      ? const Text('')
                      : GestureDetector(
                          child: Text(DateFormat('HH:mm').format(_startDate), textAlign: TextAlign.right),
                          onTap: () async {
                            final TimeOfDay? time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay(hour: _startTime.hour, minute: _startTime.minute),
                            );

                            if (time != null && time != _startTime) {
                              setState(() {
                                _startTime = time;
                                final Duration difference = _endDate.difference(_startDate);
                                _startDate = DateTime(
                                  _startDate.year,
                                  _startDate.month,
                                  _startDate.day,
                                  _startTime.hour,
                                  _startTime.minute,
                                  0,
                                );
                                _endDate = _startDate.add(difference);
                                _endTime = TimeOfDay(hour: _endDate.hour, minute: _endDate.minute);
                              });
                            }
                          },
                        ),
                ),
              ],
            ),
          ),
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
            leading: const Text(''),
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: GestureDetector(
                    child: Text(DateFormat('EEE, dd. MMM yyyy', 'de').format(_endDate), textAlign: TextAlign.left),
                    onTap: () async {
                      final DateTime? date = await showDatePicker(
                        context: context,
                        initialDate: _endDate,
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );

                      if (date != null && date != _endDate) {
                        setState(() {
                          final Duration difference = _endDate.difference(_startDate);
                          _endDate = DateTime(date.year, date.month, date.day, _endTime.hour, _endTime.minute, 0);
                          if (_endDate.isBefore(_startDate)) {
                            _startDate = _endDate.subtract(difference);
                            _startTime = TimeOfDay(hour: _startDate.hour, minute: _startDate.minute);
                          }
                        });
                      }
                    },
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: _isAllDay
                      ? const Text('')
                      : GestureDetector(
                          child: Text(DateFormat('HH:mm').format(_endDate), textAlign: TextAlign.right),
                          onTap: () async {
                            final TimeOfDay? time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay(hour: _endTime.hour, minute: _endTime.minute),
                            );

                            if (time != null && time != _endTime) {
                              setState(() {
                                _endTime = time;
                                final Duration difference = _endDate.difference(_startDate);
                                _endDate = DateTime(
                                  _endDate.year,
                                  _endDate.month,
                                  _endDate.day,
                                  _endTime.hour,
                                  _endTime.minute,
                                  0,
                                );
                                if (_endDate.isBefore(_startDate)) {
                                  _startDate = _endDate.subtract(difference);
                                  _startTime = TimeOfDay(hour: _startDate.hour, minute: _startDate.minute);
                                }
                              });
                            }
                          },
                        ),
                ),
              ],
            ),
          ),
          const Divider(height: 1.0, thickness: 1),
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
            leading: Icon(Icons.lens, color: colorCollection[_selectedColorIndex]),
            title: Text(colorNames[_selectedColorIndex]),
            onTap: () {
              showDialog<Widget>(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext context) {
                  return _ColorPicker();
                },
              ).then((dynamic value) => setState(() {}));
            },
          ),
          const Divider(height: 1.0, thickness: 1),
          ListTile(
            contentPadding: const EdgeInsets.all(5),
            leading: const Icon(Icons.subject, color: Colors.black87),
            title: TextField(
              controller: TextEditingController(text: _notes),
              onChanged: (String value) {
                _notes = value;
              },
              keyboardType: TextInputType.multiline,
              maxLines: null,
              style: const TextStyle(fontSize: 18, color: Colors.black87, fontWeight: FontWeight.w400),
              decoration: const InputDecoration(border: InputBorder.none, hintText: 'Add description'),
            ),
          ),
          const Divider(height: 1.0, thickness: 1),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text(getTitle()),
          backgroundColor: colorCollection[_selectedColorIndex],
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: <Widget>[
            IconButton(
              padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
              icon: const Icon(Icons.done, color: Colors.white),
              onPressed: () {
                var meeting = Meeting(
                  start: _startDate,
                  end: _endDate,
                  backgroundColor: colorCollection[_selectedColorIndex],
                  description: _notes,
                  isAllDay: _isAllDay,
                  eventName: _subject == '' ? '(No title)' : _subject,
                );

                if (_selectedAppointment == null) {
                  _addMeeting(meeting);
                }
                _updateMeeting(_selectedAppointment?.meetingId, meeting);
                _selectedAppointment = null;

                Navigator.pop(context);
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
          child: Stack(children: <Widget>[_getAppointmentEditor(context)]),
        ),
        floatingActionButton: _selectedAppointment == null
            ? const Text('')
            : FloatingActionButton(
                onPressed: () {
                  if (_selectedAppointment != null) {
                    _deleteMeeting(_selectedAppointment?.meetingId);
                    _selectedAppointment = null;
                    Navigator.pop(context);
                  }
                },
                backgroundColor: Colors.red,
                child: const Icon(Icons.delete_outline, color: Colors.white),
              ),
      ),
    );
  }

  String getTitle() {
    return _subject.isEmpty ? 'New event' : 'Event details';
  }

  void _deleteMeeting(String? meetingId) {
      final database = ref.read(firestoreProvider)!;
      database.deleteMeeting(meetingId);
  }

  void _addMeeting(Meeting meeting) {
    final database = ref.read(firestoreProvider)!;
    database.addMeeting(meeting);
  }

  void _updateMeeting(String? meetingId, Meeting meeting) {
    final database = ref.read(firestoreProvider)!;
    database.updateMeeting(meetingId, meeting);
  }
}
