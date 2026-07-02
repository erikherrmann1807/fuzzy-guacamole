import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuzzy_guacamole/l10n/app_localizations.dart';
import 'package:fuzzy_guacamole/ui/widgets/default_button.dart';
import 'package:fuzzy_guacamole/utils/utils.dart';

class SettingsMenu extends ConsumerStatefulWidget {
  const SettingsMenu({super.key});

  @override
  _SettingsMenuState createState() => _SettingsMenuState();
}

class _SettingsMenuState extends ConsumerState<SettingsMenu> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          DefaultButton(onTap: () => {}, title: AppLocalizations.of(context)!.helloWorld),
          DefaultButton(onTap: () => {setGerman(ref)}, title: "Deutsch"),
          DefaultButton(onTap: () => {setEnglish(ref)}, title: "Englisch"),
        ],
      ),
    );
  }
}
