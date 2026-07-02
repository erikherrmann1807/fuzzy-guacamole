import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:fuzzy_guacamole/constants.dart';
import 'package:fuzzy_guacamole/data/providers/firebase_auth_provider.dart';
import 'package:fuzzy_guacamole/data/providers/firebase_firestore_provider.dart';
import 'package:fuzzy_guacamole/l10n/l10n_extensions.dart';
import 'package:fuzzy_guacamole/ui/widgets/app_dialog.dart';
import 'package:fuzzy_guacamole/ui/widgets/default_button.dart';

class UpdateUsernameDialog extends ConsumerStatefulWidget {
  const UpdateUsernameDialog({super.key});

  @override
  ConsumerState<UpdateUsernameDialog> createState() => _UpdateUsernameDialogState();
}

class _UpdateUsernameDialogState extends ConsumerState<UpdateUsernameDialog> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final l10n = context.l10n;

    return AppDialog(
      title: l10n.updateUsername,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Text(l10n.updateUsernameInfo),
            const SizedBox(height: 16),
            TextFormField(
              controller: _usernameController,
              validator: MultiValidator([
                RequiredValidator(errorText: l10n.enterUsername),
                PatternValidator(usernamePattern, errorText: l10n.invalidUsername),
              ]).call,
              decoration: dialogInputDecoration(label: l10n.username, icon: Icons.person),
            ),
            const SizedBox(height: 16),
            if (authState.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(authState.error!, style: const TextStyle(color: Colors.redAccent)),
              ),
            authState.isLoading
                ? const CircularProgressIndicator()
                : DefaultButton(onTap: _updateUsername, title: l10n.updateUsername),
          ],
        ),
      ),
    );
  }

  Future<void> _updateUsername() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final newName = _usernameController.text.trim();
    final success = await ref.read(authViewModelProvider.notifier).updateUsername(newName);
    if (!success) return;

    await ref.read(profileViewModelProvider.notifier).updateName(newName);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
