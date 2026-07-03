import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuzzy_guacamole/data/models/daily_task_model.dart';
import 'package:fuzzy_guacamole/data/providers/firebase_firestore_provider.dart';
import 'package:fuzzy_guacamole/l10n/l10n_extensions.dart';
import 'package:fuzzy_guacamole/styles/colors.dart';
import 'package:fuzzy_guacamole/ui/widgets/app_dialog.dart';
import 'package:fuzzy_guacamole/utils/utils.dart';

/// Inline-Karte für die Startseite: zeigt die wiederkehrenden Daily Tasks,
/// erlaubt das Abhaken für heute und das Anlegen neuer täglicher Aufgaben.
class DailyTasksCard extends ConsumerWidget {
  const DailyTasksCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dailyTasksViewModelProvider);
    final today = CalendarUtils.dateOnly(DateTime.now());

    Widget body;
    if (state.loading) {
      body = const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (state.error != null) {
      body = Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(context.l10n.errorWithMessage(state.error!), style: const TextStyle(color: Colors.red)),
      );
    } else if (state.items.isEmpty) {
      body = Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(context.l10n.noDailyTasks));
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: state.items.map((task) => _TaskRow(task: task, today: today)).toList(),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(),
        color: MyColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(1.5, 2), spreadRadius: 2, blurStyle: BlurStyle.solid),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.checklist, size: 16),
              const SizedBox(width: 6),
              Expanded(child: Text(context.l10n.dailyTasksSectionTitle, style: const TextStyle(fontWeight: FontWeight.w600))),
              IconButton(
                tooltip: context.l10n.addDailyTask,
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.add_circle, color: MyColors.raisinBlack),
                onPressed: () => showAddDailyTaskDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 4),
          body,
        ],
      ),
    );
  }
}

class _TaskRow extends ConsumerWidget {
  const _TaskRow({required this.task, required this.today});

  final DailyTask task;
  final DateTime today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(dailyTasksViewModelProvider.notifier);
    final isDone = task.isDoneOn(today);
    final reminderTime = task.reminderTime;

    return Row(
      children: [
        Checkbox(
          value: isDone,
          activeColor: MyColors.raisinBlack,
          onChanged: (_) => viewModel.toggleDone(task, today),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: TextStyle(
                  fontSize: 15,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                  color: isDone ? Colors.grey : Colors.black,
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

/// Öffnet den Dialog zum Anlegen einer neuen täglichen Aufgabe.
Future<void> showAddDailyTaskDialog(BuildContext context) {
  return showDialog(context: context, builder: (context) => const AddDailyTaskDialog());
}

/// Pop-up zum Anlegen einer neuen wiederkehrenden Tagesaufgabe.
class AddDailyTaskDialog extends ConsumerStatefulWidget {
  const AddDailyTaskDialog({super.key});

  @override
  ConsumerState<AddDailyTaskDialog> createState() => _AddDailyTaskDialogState();
}

class _AddDailyTaskDialogState extends ConsumerState<AddDailyTaskDialog> {
  final TextEditingController _titleController = TextEditingController();
  TimeOfDay? _reminderTimeOfDay;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: context.l10n.addDailyTaskTitle,
      maxHeight: 220,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _titleController,
              autofocus: true,
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
      ),
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
    // Nur Stunde/Minute sind für die tägliche Erinnerung relevant; das Datum
    // ist ein beliebiger Platzhalter (heute).
    final now = DateTime.now();
    final reminderTime = time == null ? null : DateTime(now.year, now.month, now.day, time.hour, time.minute);

    final errorText = context.l10n.saveTaskFailed;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final ok = await ref.read(dailyTasksViewModelProvider.notifier).add(title, reminderTime: reminderTime);
    if (!mounted) return;
    if (ok) {
      navigator.pop();
    } else {
      messenger.showSnackBar(SnackBar(content: Text(errorText)));
    }
  }
}
