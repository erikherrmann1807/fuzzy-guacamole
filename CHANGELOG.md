# Changelog

Alle nennenswerten Änderungen der Refactoring- und Ausbau-Phasen (Branch `test/claude`, Juli 2026).

## Phase 3 – Tests

- Unit-Tests: `NotificationService` (stabile IDs, Scheduling, Exact-Alarm-Fallback), `LocalCacheService`, Offline-/Sync-Logik der Repositories, `MeetingsViewModel`/`DailyTasksViewModel`/`CalendarViewModel`, Settings (Repository, ViewModel, LocaleController).
- Widget-Tests: Daily-Tasks-Pop-up (anzeigen, anlegen, abhaken, löschen) und Tagesansicht (Stundenraster, Ganztages-Chips, Tag-Navigation, Überlappungs-Layout).
- Test-Stack: `mocktail`, `fake_cloud_firestore`, Hive in Temp-Verzeichnissen, In-Memory-Cache-Fake für Widget-Tests.

## Phase 2.6 – Settings-Menü

- Dark Mode (Hell/Dunkel/System) über `ThemeMode` in der `MaterialApp`.
- Erster Wochentag (Montag/Samstag/Sonntag) wirkt auf Monatsraster und Wochentags-Header.
- Sprachauswahl (de/en) als Dropdown; alles über `SettingsRepository`/`SettingsViewModel` mit `shared_preferences` persistiert und beim Start geladen.

## Phase 2.5 – Offline-Support

- Neuer `LocalCacheService` (Hive) mit nutzergetrennten Boxen für Termine und Aufgaben.
- Repositories arbeiten Read-Through/Write-Back: Cache wird sofort ausgeliefert, Firestore-Snapshots sind Source of Truth und aktualisieren den Cache (Last-Write-Wins); Mutationen landen sofort im Cache.
- Firestore-Writes warten nicht mehr auf die Server-Bestätigung (offline würden sie nie abschließen); die UI wird über die lokal sofort feuernden Snapshot-Streams aktualisiert.
- Account-Löschung leert auch den lokalen Cache. Neue Pakete: `hive`, `hive_flutter` (pure Dart, unit-testbar).

## Phase 2.4 – Tagesansicht

- Neue `DailyScreen`: 24-Stunden-Raster, überlappende Termine teilen sich die Breite (Spalten-Layout), Ganztages-Termine als Chips, „Jetzt“-Indikator am heutigen Tag.
- Navigation: vorheriger/nächster Tag (Monat bleibt synchron), Öffnen per zweitem Tipp auf den ausgewählten Tag im Monatsraster oder per Button in der Agenda.

## Phase 2.3 – Daily Tasks

- Neues Modell `DailyTask` + `TaskRepository` + Firestore-Subcollection `users/{uid}/tasks`.
- Pop-up-Dialog pro Kalendertag: Aufgaben anzeigen, anlegen (optional mit Erinnerungszeit), abhaken, löschen; erreichbar vom Home-Screen (heute), aus der Monats-Agenda und der Tagesansicht.
- Erinnerungen laufen über den `NotificationService` aus Phase 2.2; erledigte Aufgaben brechen ihre Erinnerung ab.

## Phase 2.2 – Lokale Termin-Erinnerungen

- Neuer testbarer `NotificationService` (`flutter_local_notifications` + `timezone` + `flutter_timezone`): zeitzonenkorrektes `zonedSchedule`, Fallback auf ungenaue Alarme ohne Exact-Alarm-Berechtigung, stabile Notification-IDs (FNV-1a über Dokument-IDs), lokalisierte Texte ohne BuildContext. Kein FCM, kein Server.
- Termine haben ein optionales `reminderMinutes` (Editor-Dropdown); Erinnerungen werden beim Anlegen/Bearbeiten/Löschen synchronisiert und dürfen das Speichern nie scheitern lassen.
- Android: Berechtigungen (POST_NOTIFICATIONS u. a.) + Scheduling-Receiver im Manifest; Berechtigungsanfrage nach dem Login.

## Phase 2.1 – Lokalisierung

- Komplette App auf `flutter_localizations` + ARB/gen-l10n umgestellt (Deutsch/Englisch, ~90 Schlüssel inkl. Pluralformen), Datums-/Zeitformate über `intl` mit aktueller Locale.
- Sprache zur Laufzeit umschaltbar und persistiert (`SettingsRepository`/`LocaleController`).

## Phase 1 – MVVM-Refactoring & Bugfixes

- Konsequente Trennung View → ViewModel (StateNotifier mit Loading-/Error-State) → Repository → Service; globale mutable Zustände und verschachtelte `MaterialApp`s entfernt.
- Bugfixes aus der Analyse: kaputte Registrierung (Race bei der Member-Erstellung), fehlerhafte `copyWith`-Implementierungen, `-1`-Index-Zugriffe, Controller-Erstellung im `build`, uvm.
- Firestore-Datumsfelder als `Timestamp` mit tolerantem Reader für Alt-Daten; Tests repariert und erweitert.

## Phase 0 – Bestandsaufnahme

- `ANALYSE.md`: Projektstruktur, 27 priorisierte Findings (Bugs, Dead Code, fehlendes Error-Handling, Testlücken) als Grundlage der Folgephasen.
