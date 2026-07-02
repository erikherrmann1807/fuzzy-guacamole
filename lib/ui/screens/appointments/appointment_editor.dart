import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuzzy_guacamole/constants.dart';
import 'package:fuzzy_guacamole/data/models/appointment_model.dart';
import 'package:fuzzy_guacamole/data/providers/firebase_firestore_provider.dart';
import 'package:fuzzy_guacamole/styles/colors.dart';
import 'package:fuzzy_guacamole/styles/styles.dart';
import 'package:fuzzy_guacamole/ui/screens/appointments/priority_picker.dart';
import 'package:intl/intl.dart';

/// Öffnet den Termineditor. [meeting] == null bedeutet "neuen Termin anlegen";
/// [initialDate] bestimmt dann den vorausgewählten Tag.
Future<void> openMeetingEditor(BuildContext context, {Meeting? meeting, DateTime? initialDate}) {
  return Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => MeetingEditor(meeting: meeting, initialDate: initialDate)));
}

class MeetingEditor extends ConsumerStatefulWidget {
  const MeetingEditor({super.key, this.meeting, this.initialDate});

  /// Zu bearbeitender Termin; `null` beim Anlegen.
  final Meeting? meeting;

  /// Vorausgewählter Tag für neue Termine.
  final DateTime? initialDate;

  @override
  ConsumerState<MeetingEditor> createState() => _MeetingEditorState();
}

class _MeetingEditorState extends ConsumerState<MeetingEditor> {
  static const Duration _defaultEventDuration = Duration(hours: 1);

  late final TextEditingController _subjectController;
  late final TextEditingController _notesController;

  late DateTime _startDate;
  late DateTime _endDate;
  late bool _isAllDay;
  late int _selectedColorIndex;

  bool get _isEditing => widget.meeting != null;

  @override
  void initState() {
    super.initState();
    final meeting = widget.meeting;
    if (meeting != null) {
      _subjectController = TextEditingController(text: meeting.eventName);
      _notesController = TextEditingController(text: meeting.description);
      _startDate = meeting.start;
      _endDate = meeting.end;
      _isAllDay = meeting.isAllDay;
      // Unbekannte Farben defensiv auf das erste Label abbilden.
      final colorIndex = labelColors.indexOf(meeting.labelColor);
      _selectedColorIndex = colorIndex < 0 ? 0 : colorIndex;
    } else {
      _subjectController = TextEditingController();
      _notesController = TextEditingController();
      final day = widget.initialDate ?? DateTime.now();
      final now = DateTime.now();
      _startDate = DateTime(day.year, day.month, day.day, now.hour, now.minute);
      _endDate = _startDate.add(_defaultEventDuration);
      _isAllDay = false;
      _selectedColorIndex = 0;
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Event details' : 'New event', style: editorAppBarText),
        backgroundColor: MyColors.raisinBlack,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: <Widget>[
          IconButton(
            padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
            icon: const Icon(Icons.done, color: Colors.white),
            onPressed: _save,
          ),
        ],
      ),
      body: Padding(padding: const EdgeInsets.all(5), child: _buildEditor(context)),
      floatingActionButton: _isEditing
          ? FloatingActionButton(
              onPressed: _delete,
              backgroundColor: Colors.red,
              child: const Icon(Icons.delete_outline, color: Colors.white),
            )
          : null,
    );
  }

  Future<void> _save() async {
    final subject = _subjectController.text.trim();
    final meeting = Meeting(
      start: _startDate,
      end: _endDate,
      description: _notesController.text,
      isAllDay: _isAllDay,
      eventName: subject.isEmpty ? '(No title)' : subject,
      labelColor: labelColors[_selectedColorIndex],
      priority: labelNames[_selectedColorIndex],
    );

    final vm = ref.read(meetingsViewModelProvider.notifier);
    final existingId = widget.meeting?.meetingId;
    final success = existingId == null ? await vm.add(meeting) : await vm.update(existingId, meeting);

    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
    } else {
      _showError('Der Termin konnte nicht gespeichert werden.');
    }
  }

  Future<void> _delete() async {
    final id = widget.meeting?.meetingId;
    if (id == null) return;
    final success = await ref.read(meetingsViewModelProvider.notifier).remove(id);
    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
    } else {
      _showError('Der Termin konnte nicht gelöscht werden.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildEditor(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
            leading: const Text(''),
            title: TextField(
              controller: _subjectController,
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
                      activeColor: MyColors.raisinBlack,
                      inactiveTrackColor: MyColors.grey,
                      value: _isAllDay,
                      onChanged: (bool value) => setState(() => _isAllDay = value),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildDateTimeRow(
            date: _startDate,
            onDatePicked: _onStartDatePicked,
            onTimePicked: _onStartTimePicked,
            dateFlex: 7,
          ),
          _buildDateTimeRow(date: _endDate, onDatePicked: _onEndDatePicked, onTimePicked: _onEndTimePicked, dateFlex: 5),
          const Divider(height: 1.0, thickness: 1),
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
            leading: Chip(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              label: Text(labelNames[_selectedColorIndex], style: tagText),
              backgroundColor: labelColors[_selectedColorIndex],
              side: BorderSide.none,
              shape: const RoundedSuperellipseBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
            ),
            onTap: _pickPriority,
          ),
          const Divider(height: 1.0, thickness: 1),
          ListTile(
            contentPadding: const EdgeInsets.all(5),
            leading: const Icon(Icons.subject, color: Colors.black87),
            title: TextField(
              controller: _notesController,
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

  Widget _buildDateTimeRow({
    required DateTime date,
    required Future<void> Function() onDatePicked,
    required Future<void> Function() onTimePicked,
    required int dateFlex,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
      leading: const Text(''),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: dateFlex,
            child: GestureDetector(
              onTap: onDatePicked,
              child: Text(DateFormat('EEE, dd. MMM yyyy', 'de').format(date), textAlign: TextAlign.left),
            ),
          ),
          Expanded(
            flex: 3,
            child: _isAllDay
                ? const Text('')
                : GestureDetector(
                    onTap: onTimePicked,
                    child: Text(DateFormat('HH:mm').format(date), textAlign: TextAlign.right),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickPriority() async {
    final pickedIndex = await PriorityPicker.show(context, selectedIndex: _selectedColorIndex);
    if (pickedIndex != null) {
      setState(() => _selectedColorIndex = pickedIndex);
    }
  }

  Future<void> _onStartDatePicked() async {
    final date = await _showCustomDatePicker(context, _startDate);
    if (date == null) return;
    setState(() {
      final duration = _endDate.difference(_startDate);
      _startDate = DateTime(date.year, date.month, date.day, _startDate.hour, _startDate.minute);
      _endDate = _startDate.add(duration);
    });
  }

  Future<void> _onStartTimePicked() async {
    final time = await _showCustomTimePicker(context, TimeOfDay.fromDateTime(_startDate));
    if (time == null) return;
    setState(() {
      final duration = _endDate.difference(_startDate);
      _startDate = DateTime(_startDate.year, _startDate.month, _startDate.day, time.hour, time.minute);
      _endDate = _startDate.add(duration);
    });
  }

  Future<void> _onEndDatePicked() async {
    final date = await _showCustomDatePicker(context, _endDate);
    if (date == null) return;
    setState(() {
      final duration = _endDate.difference(_startDate);
      _endDate = DateTime(date.year, date.month, date.day, _endDate.hour, _endDate.minute);
      _pullStartBeforeEnd(duration);
    });
  }

  Future<void> _onEndTimePicked() async {
    final time = await _showCustomTimePicker(context, TimeOfDay.fromDateTime(_endDate));
    if (time == null) return;
    setState(() {
      final duration = _endDate.difference(_startDate);
      _endDate = DateTime(_endDate.year, _endDate.month, _endDate.day, time.hour, time.minute);
      _pullStartBeforeEnd(duration);
    });
  }

  /// Zieht den Start vor das Ende, falls das Ende vor den Start rutscht.
  void _pullStartBeforeEnd(Duration previousDuration) {
    if (_endDate.isBefore(_startDate)) {
      _startDate = _endDate.subtract(previousDuration);
    }
  }

  Future<DateTime?> _showCustomDatePicker(BuildContext context, DateTime initialDate) async {
    return showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(),
              color: MyColors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(color: Colors.black, offset: Offset(1.5, 2), spreadRadius: 2, blurStyle: BlurStyle.solid),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Datum auswählen', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 20),
                Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: Theme.of(context).colorScheme.copyWith(
                      primary: MyColors.raisinBlack,
                      onPrimary: Colors.grey,
                      surface: MyColors.white,
                      onSurface: MyColors.raisinBlack,
                    ),
                  ),
                  child: CalendarDatePicker(
                    initialDate: initialDate,
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                    onDateChanged: (DateTime date) => Navigator.of(context).pop(date),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<TimeOfDay?> _showCustomTimePicker(BuildContext context, TimeOfDay initialTime) async {
    final size = MediaQuery.sizeOf(context);

    return showDialog<TimeOfDay>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.all(size.width * 0.05),
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(),
              color: MyColors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(color: Colors.black, offset: Offset(1.5, 2), spreadRadius: 2, blurStyle: BlurStyle.solid),
              ],
            ),
            constraints: const BoxConstraints(maxHeight: 550),
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: MyColors.raisinBlack,
                  onPrimary: Colors.white,
                  surface: MyColors.white,
                  onSurface: MyColors.raisinBlack,
                ),
                timePickerTheme: TimePickerThemeData(
                  backgroundColor: Colors.transparent,
                  hourMinuteTextColor: MyColors.raisinBlack,
                  dayPeriodTextColor: MyColors.raisinBlack,
                  dialHandColor: MyColors.raisinBlack,
                  dialBackgroundColor: Colors.grey.shade100,
                  entryModeIconColor: MyColors.raisinBlack,
                  hourMinuteColor: MyColors.white,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    backgroundColor: MyColors.white,
                    foregroundColor: MyColors.raisinBlack,
                    padding: const EdgeInsets.all(10),
                    textStyle: defaultButtonText,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.black, width: 1),
                    ),
                    shadowColor: Colors.black,
                    elevation: 3,
                  ),
                ),
              ),
              child: TimePickerDialog(initialTime: initialTime, initialEntryMode: TimePickerEntryMode.dialOnly),
            ),
          ),
        );
      },
    );
  }
}
