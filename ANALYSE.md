# ANALYSE.md – Bestandsaufnahme (Phase 0)

Stand: 2026-07-02, Branch `test/claude` (Baseline: `flutter analyze` = 10 Findings, `flutter test` = 10/11 grün, 1 rot)

## 1. Projektüberblick

**Typ:** Flutter-App (Google-Kalender-Klon) mit Firebase-Backend (Auth + Firestore) und Wetter-API.

**Struktur (lib/):**

| Ordner | Inhalt |
|---|---|
| `data/models` | `Meeting` (appointment_model), `Member` (user_model) |
| `data/providers` | Riverpod-Provider (Auth, Firestore, Weather, Locale) |
| `data/repositories` | `AuthRepository`, `MeetingRepository`, `UserRepository`, `WeatherApiComRepo` |
| `data/services` | `AuthService` (FirebaseAuth), `DatabaseService` (Firestore), `LocationService` |
| `ui/viewmodels` | `AuthViewModel`, `MeetingsViewModel`, `ProfileViewModel` (alle `StateNotifier`) |
| `ui/screens` | Auth, Kalender (nur Monatsansicht), Termineditor, Account-Management, Settings (Platzhalter) |
| `ui/widgets` | AppBar, DefaultButton, EventWidget, WeatherCard, MonthYearDialog |
| `l10n` | begonnene Lokalisierung (nur 1 Key `helloWorld`, DE/EN) |
| Wurzel | `constants.dart`, `routes.dart`, `drawer.dart` (ungenutzt), `utils/utils.dart`, `styles/` |

**State-Management:** `flutter_riverpod` (StateNotifier + Provider). `riverpod_annotation`/`riverpod_generator` sind deklariert, werden aber **nicht genutzt** (kein Code-Gen im Einsatz). → Bei Riverpod bleiben, Nutzung vereinheitlichen.

**Packages-Auffälligkeiten (pubspec.yaml):**
- `fake_cloud_firestore` und `mocktail` stehen in `dependencies` statt `dev_dependencies` → landen im Release-Build.
- `device_preview` deklariert, aber nirgends importiert (tot).
- `riverpod_annotation`/`generator`/`custom_lint`/`riverpod_lint` deklariert, ungenutzt bzw. nicht in analysis_options aktiviert.
- `.env` ist als Asset gebundelt (API-Keys landen im App-Bundle – bei GitIgnore ok fürs Repo, aber bewusst sein).
- `intl: any` – ungepinnt.

## 2. Findings nach Schweregrad

### 🔴 Kritisch (Bugs / Architekturbrüche)

1. **Globale mutable Top-Level-Variablen als Editor-State** (`calendar_screen.dart:35–46`):
   `_selectedAppointment`, `_startDate`, `_endTime`, `_subject`, `selectedDate`, `currentMonth`, `datesGrid` … sind **globale Variablen**, die von `MonthlyScreen`, `HomeScreen`, `MeetingEditor` und `_PriorityPicker` quer beschrieben werden. `late`-Variablen (`_isAllDay`, `_startTime` …) können uninitialisiert gelesen werden (`LateInitializationError`, z. B. wenn `MeetingEditor` direkt über die Route geöffnet wird). Kein MVVM, nicht testbar, State „klebt" zwischen Screens.

2. **`MeetingEditor` baut eine eigene, verschachtelte `MaterialApp`** (`appointment_editor.dart:219`): bricht Theme, Lokalisierung und Navigation-Stack der Haupt-App.

3. **`AuthViewModel.updatePassword`: Ergebnis von `copyWith` wird verworfen** (`auth_viewmodel.dart:106`): `state.copyWith(...)` statt `state = state.copyWith(...)` → Ladezustand bleibt bei Fehler hängen, Fehler wird verschluckt.

4. **`AuthState.copyWith` kann `user` nicht auf `null` setzen** (`user: user ?? this.user`): `deleteAccount(... user: null)` behält den alten User im State → UI glaubt weiter, eingeloggt zu sein.

5. **Registrierungs-Flow defekt/rennanfällig** (`register_screen.dart:147–158`):
   - Fehler von `createAccount` werden ignoriert, danach wird trotzdem navigiert.
   - `AuthViewModel.createAccount` setzt `state.user` nie → `databaseServiceProvider`/`userRepositoryProvider` bleiben `null` → Firestore-`Member`-Dokument wird **nicht** angelegt (nur wenn Riverpod zufällig schon rebuildet hat). `AuthLayout` zeigt dann trotz Login den LoginScreen (member == null).
   - `AuthViewModel` hört `authStateChanges` nicht ab – Statuswechsel von Firebase werden nicht reflektiert.

6. **`DeleteAccount`-Dialog:** `userRepo!` Null-Assertion kann crashen; Firestore-Userdokument wird gelöscht, aber die `meetings`-Subcollection bleibt verwaist; `BuildContext` über async-Gaps (4× vom Analyzer moniert).

7. **Kaputter Test:** `database_service_test.dart` – „Get all Meetings…" seedet unter UID `user_123`, `DatabaseService` wird aber mit `uid: ''` gebaut → schlägt fehl (aktuell rot in CI mit `flutter test`). `FakeAuthService`/`FakeUser` werden dort angelegt, aber nie wirklich gebraucht.

8. **`main()`: `dotenv.load()` läuft vor `WidgetsFlutterBinding.ensureInitialized()`** – rootBundle-Zugriff vor Binding-Init ist undefiniert/plattformabhängig.

### 🟠 Hoch (fehlerträchtig, Wartbarkeit)

9. **`labelColors.indexOf(meeting.labelColor)` kann `-1` liefern** (MonthlyScreen/HomeScreen `editMeeting`) → `labelNames[-1]` = RangeError, sobald eine Farbe nicht exakt matcht.
10. **`TextEditingController` wird in `build()` neu erzeugt** (Editor: Titel/Notizen) → Cursor springt, Controller werden nie disposed.
11. **`AuthLayout`:** `FutureBuilder(db.getMember())` feuert bei **jedem** Rebuild einen Firestore-Read (Kontingent!); nackter `CircularProgressIndicator` ohne `Scaffold`/`Material` als Zwischenzustand.
12. **`authServiceGlobal` (globaler `ValueNotifier`)** in `auth_service.dart`, genutzt von `reset_password.dart` – umgeht Riverpod-DI, zweite AuthService-Instanz.
13. **Dialog-Klassen sind keine Widgets** (`ResetPassword`, `UpdateUsername`, `DeleteAccount`, `UpdatePassword`): einfache Klassen mit Controllern ohne Dispose, `StatefulBuilder`-Flickwerk, Logik in der View.
14. **`MeetingsViewModel` nutzt `ref.listen` im Konstruktor** – funktioniert, ist aber fragil; Fehlerbehandlung bei add/update/remove fehlt komplett (Fehler verschwinden im Nirwana, kein Error-State).
15. **Meeting-Persistenz als `DateTime.toString()`**-Strings statt Firestore-`Timestamp` – sortier-/query-unfreundlich, zeitzonen-fragil.
16. **`ProfileViewModel.updateName` ohne try/catch** – unbehandelte Exceptions; `profile.error` blockiert den kompletten `EventCalendarScreen` ohne Retry.

### 🟡 Mittel (Clean Code, tote Pfade, L10n)

17. **Tote Codepfade:** `drawer.dart` (`MyDrawer`) wird nirgends verwendet (enthält auskommentierten Code, leere onTaps für Tag/Woche/Monat); `Routes.login` ist in keiner Routentabelle registriert; `DatabaseService.getUsername`/`UserRepository.getUsername` ungenutzt; `AuthService.authStateChanges` ungenutzt; unused imports in `main.dart` (2× Analyzer-Warning).
18. **Hartkodierte, gemischte DE/EN-Strings überall** („Hallo👋", 'Add title', 'Keine Termine', 'Got no Account?', Monatsnamen englisch, Wochentage deutsch, `Tag $i/$n`). L10n-Ansatz (gen-l10n, `app_de.arb` als Template) existiert, enthält aber nur `helloWorld`. Settings-Menü ist Platzhalter mit „Hallo Welt"-Button.
19. **`utils/utils.dart` mischt Schichten:** Kalender-Helper + Locale-Persistenz (`setGerman`/`setEnglish` nehmen `WidgetRef`!) in einer Datei; Locale-Handling gehört in Repository/ViewModel.
20. **Kalender:** Montag als Wochenstart hartkodiert; `generateDatesGrid` mischt `DateTime.now().hour/minute` in Datumszellen (Ursache: `selectedDate` soll „aktuelle Uhrzeit" tragen – unsauber); Magic Number 42.
21. **Widget-Anti-Pattern:** `WeatherCard`/`_TodayAgendaCard` bekommen `WidgetRef` als Konstruktor-Parameter statt `ConsumerWidget` zu sein; `EventWidget` ist `StatefulWidget` ohne State; `DefaultButton` verzweigt auf `title == "Logout"` (String-Magie).
22. **Kein Theming:** Farben/Styles direkt verdrahtet, kein `ThemeData`/`ThemeMode` → Voraussetzung für Dark Mode fehlt.
23. **Analyzer:** 10 Findings (unused imports, `use_build_context_synchronously` 5×, `constant_identifier_names` 2×, private Typ in öffentlicher API).
24. **Duplizierte Logik:** Agenda-Rendering (MonthlyScreen ↔ HomeScreen) nahezu identisch; `weekdayShortDe` doppelt (utils + home_screen); Passwort-Regex 4× kopiert; Dialog-Container-Deko 6× kopiert.

### 🔵 Niedrig
25. `Member.toJson` überschreibt `createdAt` bei jedem Schreiben mit `serverTimestamp`.
26. `WeatherApiComRepo` wirft nackte `Exception`; `lang: 'de'` hartkodiert.
27. CI (`flutter-ci.yml`) läuft nur auf `main`, `dart analyze --no-fatal-warnings` lässt Warnings durch; `dart format .` ohne `--set-exit-if-changed` (nur kosmetisch).

## 3. Test-Analyse

**Vorhanden:**
- `test/auth_service_test.dart` – 7 Tests, alle grün. Sinnvolle Happy-Path-Abdeckung des `AuthService` via mocktail (create/signIn/signOut/reset/updateUsername/updatePassword/delete). **Lücken:** keine Fehlerpfade (FirebaseAuthException), `validatePassword` ungetestet.
- `test/database_service_test.dart` – 4 Tests, **1 rot**: „Get all Meetings…" (UID-Mismatch `''` vs. `user_123`, s. Finding 7). Add/Delete/Update grün via `fake_cloud_firestore`. Ungenutzte Mocks (`FakeAuthService`, `FakeUser`) = totes Test-Setup.

**Fehlende Abdeckung (Lücken):**
- ViewModels (Auth/Meetings/Profile): 0 Tests – gerade die Fehler-/Loading-State-Bugs (Finding 3, 4) wären hier aufgefallen.
- Repositories: 0 Tests.
- `CalendarUtils` (Datums-Grid, Mehrtages-Mapping, Clamping): 0 Tests – pure Funktionen, ideal testbar.
- Widget-Tests: 0 (kein einziger).
- Serialisierung `Meeting.toJson/fromJson`, `Member`: 0 Tests.

## 4. Konsequenzen für Phase 1 (Reihenfolge)

1. Editor-/Kalender-State aus globalen Variablen in ViewModels überführen (Fix 1, 2, 9, 10).
2. Auth-Flow reparieren: `authStateChanges` abonnieren, `copyWith` fixen, Registrierung transaktional (Fix 3–5, 8, 12).
3. Account-Dialoge zu Widgets mit ViewModel-Anbindung umbauen (Fix 6, 13).
4. Meeting-Persistenz auf `Timestamp` umstellen, Fehler-States in `MeetingsViewModel` (14, 15).
5. Tote Pfade entfernen, Analyzer auf 0, `dart format`, pubspec bereinigen (17, 23, Packages).
6. Kaputten DB-Test fixen, Test-Setup entrümpeln (7); Utils-/Serialisierungs-Tests ergänzen.

Theming (22), L10n (18) und Wochenstart (20) werden in Phase 2.1/2.6 gelöst, aber in Phase 1 strukturell vorbereitet (keine neuen Hardcodings).
