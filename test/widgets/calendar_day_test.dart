import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuzzy_guacamole/data/models/appointment_model.dart';
import 'package:fuzzy_guacamole/data/providers/firebase_firestore_provider.dart';
import 'package:fuzzy_guacamole/data/repositories/database/meeting_repository.dart';
import 'package:fuzzy_guacamole/data/services/database_service.dart';
import 'package:fuzzy_guacamole/l10n/app_localizations.dart';
import 'package:fuzzy_guacamole/styles/colors.dart';
import 'package:fuzzy_guacamole/ui/screens/calendar/views/calendar_day.dart';
import 'package:intl/intl.dart';

import 'in_memory_cache.dart';

void main() {
  late MeetingRepository repo;
  final today = DateTime.now();

  Meeting meeting({required String name, required int startHour, int durationHours = 1, bool isAllDay = false}) {
    final start = DateTime(today.year, today.month, today.day, startHour);
    return Meeting(
      eventName: name,
      description: '',
      start: start,
      end: start.add(Duration(hours: durationHours)),
      labelColor: MyColors.highLabel,
      priority: 'High',
      isAllDay: isAllDay,
    );
  }

  setUp(() {
    repo = MeetingRepository(DatabaseService(fireStore: FakeFirebaseFirestore(), uid: 'user_123'), InMemoryCache());
  });

  Future<void> pumpDayView(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [meetingRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('de'),
          home: const DailyScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  testWidgets('zeigt Stunden-Raster und Termine des ausgewählten Tages', (tester) async {
    await repo.add(meeting(name: 'Standup', startHour: 10));
    await repo.add(meeting(name: 'Review', startHour: 14, durationHours: 2));

    await pumpDayView(tester);

    // Stundenraster vorhanden (24 Zeilen von 00:00 bis 23:00).
    expect(find.text('00:00'), findsOneWidget);
    expect(find.text('23:00'), findsOneWidget);
    // Beide Termine als Blöcke mit Zeitangabe.
    expect(find.text('Standup'), findsOneWidget);
    expect(find.text('Review'), findsOneWidget);
    expect(find.text('10:00 – 11:00'), findsOneWidget);
    expect(find.text('14:00 – 16:00'), findsOneWidget);
  });

  testWidgets('ganztägige Termine erscheinen als Chip über dem Raster', (tester) async {
    await repo.add(meeting(name: 'Urlaub', startHour: 0, durationHours: 8, isAllDay: true));

    await pumpDayView(tester);

    expect(find.textContaining('Urlaub'), findsOneWidget);
    expect(find.textContaining('Ganztägig'), findsOneWidget);
  });

  testWidgets('Navigation zum nächsten/vorherigen Tag aktualisiert Titel und Termine', (tester) async {
    await repo.add(meeting(name: 'Standup', startHour: 10));

    await pumpDayView(tester);
    expect(find.text('Standup'), findsOneWidget);

    final format = DateFormat.yMMMEd('de');
    expect(find.text(format.format(today)), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pump();
    await tester.pump();

    expect(find.text(format.format(today.add(const Duration(days: 1)))), findsOneWidget);
    expect(find.text('Standup'), findsNothing);

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pump();
    await tester.pump();

    expect(find.text(format.format(today)), findsOneWidget);
    expect(find.text('Standup'), findsOneWidget);
  });

  testWidgets('überlappende Termine teilen sich die Breite', (tester) async {
    await repo.add(meeting(name: 'Termin A', startHour: 9, durationHours: 2));
    await repo.add(meeting(name: 'Termin B', startHour: 10, durationHours: 2));

    await pumpDayView(tester);

    final sizeA = tester.getSize(
      find.ancestor(of: find.text('Termin A'), matching: find.byType(GestureDetector)).first,
    );
    final sizeB = tester.getSize(
      find.ancestor(of: find.text('Termin B'), matching: find.byType(GestureDetector)).first,
    );
    final screenWidth = tester.getSize(find.byType(DailyScreen)).width;

    // Beide Blöcke sind (deutlich) schmaler als die halbe Bildschirmbreite + Toleranz
    // und liegen nebeneinander statt übereinander.
    expect(sizeA.width, lessThan(screenWidth / 2));
    expect(sizeB.width, lessThan(screenWidth / 2));
    final leftA = tester.getTopLeft(find.ancestor(of: find.text('Termin A'), matching: find.byType(GestureDetector)).first).dx;
    final leftB = tester.getTopLeft(find.ancestor(of: find.text('Termin B'), matching: find.byType(GestureDetector)).first).dx;
    expect(leftA, isNot(leftB));
  });
}
