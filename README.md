# fuzzy-guacamole

Ein Kalender mit Terminen, Tagesaufgaben und lokalen Erinnerungen – Flutter-App mit Firebase-Backend (Auth + Firestore).

## Features

- **Termine**: anlegen, bearbeiten, löschen; Prioritäten, Farb-Labels, ganztägige und mehrtägige Termine
- **Monats- und Tagesansicht**: Monatsraster mit Agenda des ausgewählten Tages; Tagesansicht als 24-Stunden-Raster mit nebeneinander angeordneten überlappenden Terminen und Tag-Navigation
- **Daily Tasks**: Tagesaufgaben im Pop-up-Dialog anzeigen, anlegen, abhaken und löschen – optional mit Erinnerung
- **Lokale Erinnerungen**: pro Termin/Aufgabe konfigurierbar, komplett lokal über `flutter_local_notifications` (kein FCM), zeitzonenkorrekt geplant
- **Offline-Support**: Firestore-Offline-Persistenz plus eigener Hive-Cache-Layer (Read-Through/Write-Back in den Repositories)
- **Einstellungen**: Sprache (Deutsch/Englisch, zur Laufzeit umschaltbar), Dark Mode (Hell/Dunkel/System), erster Wochentag – persistiert über `shared_preferences`
- **Account-Verwaltung**: Registrierung, Login, Passwort ändern/zurücksetzen, Account löschen

## Architektur

MVVM mit Riverpod:

```
lib/
├── data/
│   ├── models/          # Meeting, DailyTask, Member (immutable)
│   ├── providers/       # Riverpod-Provider (Auth, Firestore, Notifications, Locale)
│   ├── repositories/    # Auth-, Meeting-, Task-, User-, Settings-Repository
│   └── services/        # AuthService, DatabaseService, NotificationService, LocalCacheService
├── l10n/                # ARB-Dateien + generierte Lokalisierung (de/en)
├── ui/
│   ├── screens/         # Views (ConsumerWidgets, kein Business-Code)
│   ├── viewmodels/      # StateNotifier mit Loading-/Error-State (kein BuildContext)
│   └── widgets/         # wiederverwendbare Widgets
└── utils/               # reine Kalender-Hilfsfunktionen
```

- **Views** lesen State aus ViewModels und lösen Aktionen aus.
- **ViewModels** (StateNotifier) enthalten Präsentationslogik, keine Widgets/BuildContexts.
- **Repositories** kapseln Firestore + lokalen Cache (Sync-Logik liegt hier, nicht im ViewModel).
- **Services** sprechen die konkreten APIs (Firebase, Notifications, Hive) an.

## Setup

1. Flutter SDK ≥ 3.8 installieren.
2. `.env` im Projekt-Root anlegen (wird als Asset gebundelt, nicht eingecheckt):
   ```
   API_KEY=...
   APP_ID=...
   MESSAGING_SENDER_ID=...
   PROJECT_ID=...
   STORAGE_BUCKET=...
   ```
3. Abhängigkeiten holen und starten:
   ```sh
   flutter pub get
   flutter run
   ```

Nach Änderungen an den ARB-Dateien (`lib/l10n/app_de.arb`, `app_en.arb`):

```sh
flutter gen-l10n
```

## Tests

```sh
flutter analyze
flutter test
```

Der Test-Stack nutzt `mocktail`, `fake_cloud_firestore` und Hive in Temp-Verzeichnissen; Widget-Tests decken u. a. den Daily-Tasks-Dialog und die Tagesansicht ab.

Details zur Historie stehen in [CHANGELOG.md](CHANGELOG.md), die ursprüngliche Bestandsaufnahme in [ANALYSE.md](ANALYSE.md).
