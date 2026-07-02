import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuzzy_guacamole/data/providers/firebase_firestore_provider.dart';
import 'package:fuzzy_guacamole/data/providers/notification_provider.dart';
import 'package:fuzzy_guacamole/l10n/l10n_extensions.dart';
import 'package:fuzzy_guacamole/styles/colors.dart';
import 'package:fuzzy_guacamole/ui/screens/accountmanagement/account_management_screen.dart';
import 'package:fuzzy_guacamole/ui/screens/appointments/appointment_editor.dart';
import 'package:fuzzy_guacamole/ui/screens/auth/app_loading_page.dart';
import 'package:fuzzy_guacamole/ui/screens/calendar/views/calendar_month.dart';
import 'package:fuzzy_guacamole/ui/screens/home/home_screen.dart';
import 'package:fuzzy_guacamole/ui/screens/settings/settingsmenu.dart';
import 'package:fuzzy_guacamole/ui/viewmodels/calendar_viewmodel.dart';
import 'package:fuzzy_guacamole/ui/widgets/app_bar.dart';

/// Haupt-Shell der App: Bottom-Navigation zwischen Home, Monatsansicht,
/// Account-Management und Settings.
class EventCalendarScreen extends ConsumerStatefulWidget {
  const EventCalendarScreen({super.key});

  @override
  ConsumerState<EventCalendarScreen> createState() => _EventCalendarScreenState();
}

enum _Tab { home, calendar, account, settings }

class _EventCalendarScreenState extends ConsumerState<EventCalendarScreen> {
  _Tab _selectedTab = _Tab.home;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        ref.read(profileViewModelProvider.notifier).load();
        // Notification-Berechtigung (Android 13+/iOS) nach dem Login anfragen.
        ref.read(notificationServiceProvider).requestPermissions();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final profile = ref.watch(profileViewModelProvider);

    if (profile.loading) {
      return const AppLoadingPage();
    }
    if (profile.error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(context.l10n.errorWithMessage(profile.error!)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.read(profileViewModelProvider.notifier).load(),
                child: Text(context.l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    final username = profile.member?.userName ?? context.l10n.defaultUsername;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _appBarForTab(username),
      body: _screenForTab(),
      bottomNavigationBar: BottomAppBar(
        height: size.height * 0.08,
        shape: const CircularNotchedRectangle(),
        notchMargin: 10.0,
        color: MyColors.raisinBlack,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.home),
                    color: MyColors.white,
                    onPressed: () => _selectTab(_Tab.home),
                  ),
                  SizedBox(width: size.width * 0.05),
                  IconButton(
                    icon: const Icon(Icons.calendar_month),
                    color: MyColors.white,
                    onPressed: () => _selectTab(_Tab.calendar),
                  ),
                  SizedBox(width: size.width * 0.08),
                ],
              ),
            ),
            const SizedBox(width: 40),
            Expanded(
              child: Row(
                children: [
                  SizedBox(width: size.width * 0.08),
                  IconButton(
                    icon: const Icon(Icons.person),
                    color: MyColors.white,
                    onPressed: () => _selectTab(_Tab.account),
                  ),
                  SizedBox(width: size.width * 0.05),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    color: MyColors.white,
                    onPressed: () => _selectTab(_Tab.settings),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 5),
        child: FloatingActionButton(
          shape: const CircleBorder(),
          backgroundColor: MyColors.raisinBlack,
          onPressed: _createMeeting,
          child: const Icon(Icons.add, color: MyColors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void _selectTab(_Tab tab) => setState(() => _selectedTab = tab);

  Widget _screenForTab() {
    switch (_selectedTab) {
      case _Tab.home:
        return const HomeScreen();
      case _Tab.calendar:
        return const MonthlyScreen();
      case _Tab.account:
        return AccountManagementScreen();
      case _Tab.settings:
        return const SettingsMenu();
    }
  }

  AppBar _appBarForTab(String username) {
    final l10n = context.l10n;
    switch (_selectedTab) {
      case _Tab.home:
        return customAppBar(l10n.greeting(username), showTodayButton: false);
      case _Tab.calendar:
        return customAppBar(
          l10n.greeting(username),
          showTodayButton: true,
          onTodayPressed: () => ref.read(calendarViewModelProvider.notifier).resetToToday(),
        );
      case _Tab.account:
        return customAppBar(l10n.accountManagementTitle, showTodayButton: false);
      case _Tab.settings:
        return customAppBar(l10n.settingsTitle, showTodayButton: false);
    }
  }

  void _createMeeting() {
    final selectedDate = ref.read(calendarViewModelProvider).selectedDate;
    openMeetingEditor(context, initialDate: selectedDate);
  }
}
