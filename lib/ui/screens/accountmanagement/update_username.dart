import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:fuzzy_guacamole/constants.dart';
import 'package:fuzzy_guacamole/data/providers/firebase_auth_provider.dart';
import 'package:fuzzy_guacamole/data/providers/firebase_firestore_provider.dart';
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

    return AppDialog(
      title: 'Update Username',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const Text(
              'Geben Sie in folgendem Feld Ihren neuen Nutzernamen ein '
              'und bestätigen Sie die Änderung mit dem Button am Ende',
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _usernameController,
              validator: MultiValidator([
                RequiredValidator(errorText: 'Enter Username'),
                PatternValidator(
                  usernamePattern,
                  errorText:
                      'The Username needs to be 8-20 Characters long.\n'
                      'No "_" or "." at the beginning.\n'
                      'No "__" or "_." or "._" or ".." inside.\n'
                      'No "_" or "." at the end.',
                ),
              ]).call,
              decoration: dialogInputDecoration(label: 'Username', icon: Icons.person),
            ),
            const SizedBox(height: 16),
            if (authState.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(authState.error!, style: const TextStyle(color: Colors.redAccent)),
              ),
            authState.isLoading
                ? const CircularProgressIndicator()
                : DefaultButton(onTap: _updateUsername, title: 'Update Username'),
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
