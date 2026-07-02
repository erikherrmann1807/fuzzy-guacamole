import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuzzy_guacamole/data/providers/locale_provider.dart';
import 'package:fuzzy_guacamole/l10n/l10n_extensions.dart';
import 'package:fuzzy_guacamole/ui/widgets/default_button.dart';

class SettingsMenu extends ConsumerWidget {
  const SettingsMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeController = ref.read(localeProvider.notifier);
    final l10n = context.l10n;

    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          DefaultButton(onTap: () => localeController.setLocale('de'), title: l10n.languageGerman),
          DefaultButton(onTap: () => localeController.setLocale('en'), title: l10n.languageEnglish),
        ],
      ),
    );
  }
}
