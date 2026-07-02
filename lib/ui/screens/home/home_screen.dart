import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuzzy_guacamole/data/models/appointment_model.dart';
import 'package:fuzzy_guacamole/data/providers/firebase_firestore_provider.dart';
import 'package:fuzzy_guacamole/l10n/l10n_extensions.dart';
import 'package:fuzzy_guacamole/styles/colors.dart';
import 'package:fuzzy_guacamole/styles/styles.dart';
import 'package:fuzzy_guacamole/ui/screens/appointments/appointment_editor.dart';
import 'package:fuzzy_guacamole/ui/widgets/agenda_list.dart';
import 'package:fuzzy_guacamole/ui/widgets/home_widgets/weather_widget.dart';
import 'package:fuzzy_guacamole/utils/utils.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const WeatherCard(),
              const SizedBox(height: 16),
              _SectionTitle(context.l10n.currentTasks),
              const SizedBox(height: 8),
              const _TodayAgendaCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayAgendaCard extends ConsumerWidget {
  const _TodayAgendaCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(meetingsViewModelProvider);
    final size = MediaQuery.sizeOf(context);
    final locale = Localizations.maybeLocaleOf(context)?.toString();

    Widget content;
    if (state.loading) {
      content = Row(
        children: [
          const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(width: 12),
          Text(context.l10n.loadingTodaysAppointments),
        ],
      );
    } else if (state.error != null) {
      content = Text(context.l10n.loadingError(state.error!));
    } else {
      final byDay = CalendarUtils.buildMeetingsMapSpanning<Meeting>(state.items, (m) => m.start, (m) => m.end);
      final today = DateTime.now();
      final todayEvents = byDay[CalendarUtils.dateOnly(today)] ?? [];

      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 16),
              const SizedBox(width: 6),
              Text('${DateFormat.E(locale).format(today)} ${today.day}', style: currentTasksDateText),
              const Spacer(),
              const _AddMeetingButton(),
            ],
          ),
          const SizedBox(height: 10),
          if (todayEvents.isEmpty)
            Text(context.l10n.noAppointmentsToday, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))
          else ...[
            Text(
              context.l10n.appointmentsTodayCount(todayEvents.length),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: DayAgendaList(
                meetings: todayEvents,
                day: today,
                shrinkWrap: true,
                onMeetingTap: (meeting) => openMeetingEditor(context, meeting: meeting),
              ),
            ),
          ],
        ],
      );
    }

    return Container(
      width: size.width,
      height: size.height * 0.4,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(),
        color: MyColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(1.5, 2), spreadRadius: 2, blurStyle: BlurStyle.solid),
        ],
      ),
      constraints: const BoxConstraints(maxHeight: 375),
      child: content,
    );
  }
}

class _AddMeetingButton extends StatelessWidget {
  const _AddMeetingButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(color: MyColors.raisinBlack, shape: BoxShape.circle),
      child: IconButton(
        icon: const Icon(Icons.add, color: MyColors.white),
        onPressed: () => openMeetingEditor(context, initialDate: DateTime.now()),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700));
  }
}
