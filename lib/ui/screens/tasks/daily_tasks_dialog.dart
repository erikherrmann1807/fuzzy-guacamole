import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuzzy_guacamole/data/models/daily_task_model.dart';
import 'package:fuzzy_guacamole/data/providers/firebase_firestore_provider.dart';
import 'package:fuzzy_guacamole/l10n/l10n_extensions.dart';
import 'package:fuzzy_guacamole/styles/colors.dart';
import 'package:fuzzy_guacamole/ui/widgets/app_dialog.dart';
import 'package:fuzzy_guacamole/utils/utils.dart';
import 'package:intl/intl.dart';

/// Öffnet den Daily-Tasks-Dialog für den Kalendertag von [day].
Future<void> showDailyTasksDialog(BuildContext context, DateTime day) {
  return showDialog(context: context, builder: (context) => DailyTasksDialog(day: CalendarUtils.dateOnly(day)));
}

/// Pop-up zum Anzeigen, Anlegen, Abhaken und Löschen der Aufgaben eines Tages.
class DailyTasksDialog extends ConsumerStatefulWidget {
  const DailyTasksDialog({super.key, required this.day});

  /// Auf Mitternacht normalisierter Kalendertag.
  final DateTime day;

  @override
  ConsumerState<DailyTasksDialog> createState() => _DailyTasksDialogState();
}

class _DailyTasksDialogState extends ConsumerState<DailyTasksDialog> {
  final TextEditingController _titleController = TextEditingController();
  TimeOfDay? _reminderTimeOfDay;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dailyTasksViewModelProvider(widget.day));
    final locale = Localizations.maybeLocaleOf(context)?.toString();

    return AppDialog(
      title: context.l10n.dailyTasksTitle(DateFormat.yMd(locale).format(widget.day)),
      maxHeight: 480,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(context.l10n.errorWithMessage(state.error!), style: const TextStyle(color: Colors.red)),
            )
          else if (state.items.isEmpty)
            Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(context.l10n.noTasksForDay))
          else
            ...state.items.map((task) => _TaskRow(task: task, day: widget.day)),
          const Divider(),
          _buildAddRow(context),
        ],
      ),
    );
  }

  Widget _buildAddRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _titleController,
            decoration: InputDecoration(hintText: context.l10n.newTaskHint, isDense: true),
            onSubmitted: (_) => _addTask(),
          ),
        ),
        IconButton(
          tooltip: context.l10n.pickReminderTime,
          icon: Icon(
            _reminderTimeOfDay == null ? Icons.alarm_add_outlined : Icons.alarm_on,
            color: MyColors.raisinBlack,
          ),
          onPressed: _pickReminderTime,
        ),
        IconButton(
          tooltip: context.l10n.addTask,
          icon: const Icon(Icons.add_circle, color: MyColors.raisinBlack),
          onPressed: _addTask,
        ),
      ],
    );
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(context: context, initialTime: _reminderTimeOfDay ?? TimeOfDay.now());
    // Erneutes Öffnen mit Abbruch entfernt eine bereits gewählte Zeit wieder.
    setState(() => _reminderTimeOfDay = picked);
  }

  Future<void> _addTask() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final time = _reminderTimeOfDay;
    final reminderTime = time == null
        ? null
        : DateTime(widget.day.year, widget.day.month, widget.day.day, time.hour, time.minute);

    final errorText = context.l10n.saveTaskFailed;
    final messenger = ScaffoldMessenger.of(context);
    final ok = await ref.read(dailyTasksViewModelProvider(widget.day).notifier).add(title, reminderTime: reminderTime);
    if (!mounted) return;
    if (ok) {
      _titleController.clear();
      setState(() => _reminderTimeOfDay = null);
    } else {
      messenger.showSnackBar(SnackBar(content: Text(errorText)));
    }
  }
}

class _TaskRow extends ConsumerWidget {
  const _TaskRow({required this.task, required this.day});

  final DailyTask task;
  final DateTime day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(dailyTasksViewModelProvider(day).notifier);
    final reminderTime = task.reminderTime;

    return Row(
      children: [
        Checkbox(
          value: task.isDone,
          activeColor: MyColors.raisinBlack,
          onChanged: (_) => viewModel.toggleDone(task),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: TextStyle(
                  fontSize: 15,
                  decoration: task.isDone ? TextDecoration.lineThrough : null,
                  color: task.isDone ? Colors.grey : Colors.black,
                ),
              ),
              if (reminderTime != null)
                Text(
                  context.l10n.taskReminderAt(CalendarUtils.formatHHmm(reminderTime)),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
            ],
          ),
        ),
        IconButton(
          tooltip: context.l10n.deleteTask,
          icon: const Icon(Icons.delete_outline, color: MyColors.raisinBlack),
          onPressed: () async {
            final errorText = context.l10n.deleteTaskFailed;
            final messenger = ScaffoldMessenger.of(context);
            final ok = await viewModel.remove(task);
            if (!ok) {
              messenger.showSnackBar(SnackBar(content: Text(errorText)));
            }
          },
        ),
      ],
    );
  }
}
