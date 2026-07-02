import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:fuzzy_guacamole/constants.dart';
import 'package:fuzzy_guacamole/data/providers/firebase_auth_provider.dart';
import 'package:fuzzy_guacamole/l10n/l10n_extensions.dart';
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
    final l10n = context.l10n;

    return AppDialog(
      title: l10n.updatePassword,
      maxHeight: 450,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Text(l10n.updatePasswordInfo),
            const SizedBox(height: 16),
            TextFormField(
              obscureText: true,
              controller: _oldPasswordController,
              validator: RequiredValidator(errorText: l10n.enterPassword).call,
              decoration: dialogInputDecoration(label: l10n.oldPassword, icon: Icons.password),
            ),
            const SizedBox(height: 16),
            TextFormField(
              obscureText: true,
              controller: _newPasswordController,
              validator: MultiValidator([
                RequiredValidator(errorText: l10n.enterPassword),
                PatternValidator(passwordPattern, errorText: l10n.invalidPassword),
              ]).call,
              decoration: dialogInputDecoration(label: l10n.newPassword, icon: Icons.password),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent)),
              ),
            authState.isLoading
                ? const CircularProgressIndicator()
                : DefaultButton(onTap: _updatePassword, title: l10n.updatePassword),
          ],
        ),
      ),
    );
  }

  Future<void> _updatePassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final viewModel = ref.read(authViewModelProvider.notifier);
    final errorText = context.l10n.wrongCurrentPassword;
    final isValid = await viewModel.validatePassword(_oldPasswordController.text);
    if (!isValid || !ref.read(authViewModelProvider).isValid) {
      setState(() => _errorMessage = errorText);
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
