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
import 'package:fuzzy_guacamole/ui/screens/tasks/daily_tasks_section.dart';
import 'package:mocktail/mocktail.dart';

import 'in_memory_cache.dart';

class MockNotificationService extends Mock implements NotificationService {}

void main() {
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

  Future<void> pumpCard(WidgetTester tester) async {
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
          home: const Scaffold(body: DailyTasksCard()),
        ),
      ),
    );
    // Streams (Cache + Firestore) verarbeiten.
    await tester.pump();
    await tester.pump();
  }

  // Fügt über den Add-Dialog eine Aufgabe hinzu.
  Future<void> addTask(WidgetTester tester, String title) async {
    await tester.tap(find.byIcon(Icons.add_circle));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), title);
    await tester.tap(find.descendant(of: find.byType(AddDailyTaskDialog), matching: find.byIcon(Icons.add_circle)));
    // Aufgabe anlegen, Dialog schließen (inkl. Dismiss-Animation) und Stream verarbeiten.
    await tester.pumpAndSettle();
  }

  testWidgets('zeigt den Leer-Zustand ohne Aufgaben', (tester) async {
    await pumpCard(tester);

    expect(find.text('Noch keine täglichen Aufgaben.'), findsOneWidget);
    expect(find.text('Tägliche Aufgaben'), findsOneWidget);
  });

  testWidgets('legt eine neue tägliche Aufgabe an', (tester) async {
    await pumpCard(tester);

    await addTask(tester, 'Zähne putzen');

    expect(find.text('Zähne putzen'), findsOneWidget);
    expect(find.text('Noch keine täglichen Aufgaben.'), findsNothing);
  });

  testWidgets('hakt eine Aufgabe für heute ab und wieder los', (tester) async {
    await pumpCard(tester);
    await addTask(tester, 'Zähne putzen');

    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.pump();

    final done = tester.widget<Text>(find.text('Zähne putzen'));
    expect(done.style?.decoration, TextDecoration.lineThrough);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);

    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.pump();

    final undone = tester.widget<Text>(find.text('Zähne putzen'));
    expect(undone.style?.decoration, isNull);
  });

  testWidgets('löscht eine Aufgabe', (tester) async {
    await pumpCard(tester);
    await addTask(tester, 'Zähne putzen');

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pump();
    await tester.pump();

    expect(find.text('Zähne putzen'), findsNothing);
    expect(find.text('Noch keine täglichen Aufgaben.'), findsOneWidget);
    verify(() => notifications.cancelTaskReminder(any())).called(1);
  });

  testWidgets('leerer Titel legt keine Aufgabe an', (tester) async {
    await pumpCard(tester);

    await tester.tap(find.byIcon(Icons.add_circle));
    await tester.pumpAndSettle();
    // Ohne Text bleibt der Dialog offen und legt nichts an.
    await tester.tap(find.descendant(of: find.byType(AddDailyTaskDialog), matching: find.byIcon(Icons.add_circle)));
    await tester.pump();

    expect(find.byType(AddDailyTaskDialog), findsOneWidget);
  });
}
