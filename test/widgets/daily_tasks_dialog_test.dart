import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuzzy_guacamole/data/providers/firebase_firestore_provider.dart';
import 'package:fuzzy_guacamole/data/providers/notification_provider.dart';
import 'package:fuzzy_guacamole/data/repositories/database/task_repository.dart';
import 'package:fuzzy_guacamole/data/services/database_service.dart';
import 'package:fuzzy_guacamole/data/services/notification_service.dart';
import 'package:fuzzy_guacamole/l10n/app_localizations.dart';
import 'package:fuzzy_guacamole/ui/screens/tasks/daily_tasks_dialog.dart';
import 'package:mocktail/mocktail.dart';

import 'in_memory_cache.dart';

class MockNotificationService extends Mock implements NotificationService {}

void main() {
  final day = DateTime(2026, 7, 2);
  late MockNotificationService notifications;
  late TaskRepository repo;

  setUp(() {
    notifications = MockNotificationService();
    when(
      () => notifications.syncTaskReminder(
        taskId: any(named: 'taskId'),
        title: any(named: 'title'),
        reminderTime: any(named: 'reminderTime'),
      ),
    ).thenAnswer((_) async {});
    when(() => notifications.cancelTaskReminder(any())).thenAnswer((_) async {});

    repo = TaskRepository(DatabaseService(fireStore: FakeFirebaseFirestore(), uid: 'user_123'), InMemoryCache());
  });

  Future<void> pumpDialog(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          taskRepositoryProvider.overrideWithValue(repo),
          notificationServiceProvider.overrideWithValue(notifications),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('de'),
          home: Scaffold(body: DailyTasksDialog(day: day)),
        ),
      ),
    );
    // Streams (Cache + Firestore) verarbeiten.
    await tester.pump();
    await tester.pump();
  }

  testWidgets('zeigt den Leer-Zustand für einen Tag ohne Aufgaben', (tester) async {
    await pumpDialog(tester);

    expect(find.text('Keine Aufgaben für diesen Tag.'), findsOneWidget);
    expect(find.text('Aufgaben am 2.7.2026'), findsOneWidget);
  });

  testWidgets('legt eine neue Aufgabe an', (tester) async {
    await pumpDialog(tester);

    await tester.enterText(find.byType(TextField), 'Einkaufen');
    await tester.tap(find.byIcon(Icons.add_circle));
    await tester.pump();
    await tester.pump();

    expect(find.text('Einkaufen'), findsOneWidget);
    expect(find.text('Keine Aufgaben für diesen Tag.'), findsNothing);
    // Eingabefeld ist danach wieder leer.
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, isEmpty);
  });

  testWidgets('hakt eine Aufgabe ab (Durchstreichung) und wieder los', (tester) async {
    await pumpDialog(tester);
    await tester.enterText(find.byType(TextField), 'Einkaufen');
    await tester.tap(find.byIcon(Icons.add_circle));
    await tester.pump();
    await tester.pump();

    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.pump();

    final done = tester.widget<Text>(find.text('Einkaufen'));
    expect(done.style?.decoration, TextDecoration.lineThrough);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);

    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.pump();

    final undone = tester.widget<Text>(find.text('Einkaufen'));
    expect(undone.style?.decoration, isNull);
  });

  testWidgets('löscht eine Aufgabe', (tester) async {
    await pumpDialog(tester);
    await tester.enterText(find.byType(TextField), 'Einkaufen');
    await tester.tap(find.byIcon(Icons.add_circle));
    await tester.pump();
    await tester.pump();

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pump();
    await tester.pump();

    expect(find.text('Einkaufen'), findsNothing);
    expect(find.text('Keine Aufgaben für diesen Tag.'), findsOneWidget);
    verify(() => notifications.cancelTaskReminder(any())).called(1);
  });

  testWidgets('leerer Titel legt keine Aufgabe an', (tester) async {
    await pumpDialog(tester);

    await tester.tap(find.byIcon(Icons.add_circle));
    await tester.pump();
    await tester.pump();

    expect(find.text('Keine Aufgaben für diesen Tag.'), findsOneWidget);
  });
}
