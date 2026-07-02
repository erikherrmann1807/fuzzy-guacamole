import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuzzy_guacamole/data/providers/locale_provider.dart';
import 'package:fuzzy_guacamole/ui/widgets/default_button.dart';

class SettingsMenu extends ConsumerWidget {
  const SettingsMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeController = ref.read(localeProvider.notifier);

    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          DefaultButton(onTap: () => localeController.setLocale('de'), title: 'Deutsch'),
          DefaultButton(onTap: () => localeController.setLocale('en'), title: 'Englisch'),
        ],
      ),
    );
  }
}
