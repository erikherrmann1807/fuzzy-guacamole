import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:fuzzy_guacamole/constants.dart';
import 'package:fuzzy_guacamole/data/providers/firebase_auth_provider.dart';
import 'package:fuzzy_guacamole/ui/widgets/app_dialog.dart';
import 'package:fuzzy_guacamole/ui/widgets/default_button.dart';

class UpdatePasswordDialog extends ConsumerStatefulWidget {
  const UpdatePasswordDialog({super.key});

  @override
  ConsumerState<UpdatePasswordDialog> createState() => _UpdatePasswordDialogState();
}

class _UpdatePasswordDialogState extends ConsumerState<UpdatePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    return AppDialog(
      title: 'Update Password',
      maxHeight: 450,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const Text(
              'Um Ihr Passwort zu ändern benötigen Sie '
              'ein neues Passwort und das aktuelle Passwort.',
            ),
            const SizedBox(height: 16),
            TextFormField(
              obscureText: true,
              controller: _oldPasswordController,
              validator: RequiredValidator(errorText: 'Enter password').call,
              decoration: dialogInputDecoration(label: 'Old Password', icon: Icons.password),
            ),
            const SizedBox(height: 16),
            TextFormField(
              obscureText: true,
              controller: _newPasswordController,
              validator: MultiValidator([
                RequiredValidator(errorText: 'Enter password'),
                PatternValidator(
                  passwordPattern,
                  errorText:
                      'Password must contain minimum eight characters, '
                      'at least one letter and one number',
                ),
              ]).call,
              decoration: dialogInputDecoration(label: 'New Password', icon: Icons.password),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent)),
              ),
            authState.isLoading
                ? const CircularProgressIndicator()
                : DefaultButton(onTap: _updatePassword, title: 'Update Password'),
          ],
        ),
      ),
    );
  }

  Future<void> _updatePassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final viewModel = ref.read(authViewModelProvider.notifier);
    final isValid = await viewModel.validatePassword(_oldPasswordController.text);
    if (!isValid || !ref.read(authViewModelProvider).isValid) {
      setState(() => _errorMessage = 'Das aktuelle Passwort ist nicht korrekt.');
      return;
    }

    final success = await viewModel.updatePassword(_newPasswordController.text);
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop();
    } else {
      setState(() => _errorMessage = ref.read(authViewModelProvider).error);
    }
  }
}
