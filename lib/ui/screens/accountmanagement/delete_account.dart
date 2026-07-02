import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:fuzzy_guacamole/constants.dart';
import 'package:fuzzy_guacamole/data/providers/firebase_auth_provider.dart';
import 'package:fuzzy_guacamole/data/providers/firebase_firestore_provider.dart';
import 'package:fuzzy_guacamole/l10n/l10n_extensions.dart';
import 'package:fuzzy_guacamole/routes.dart';
import 'package:fuzzy_guacamole/ui/widgets/app_dialog.dart';
import 'package:fuzzy_guacamole/ui/widgets/default_button.dart';

class DeleteAccountDialog extends ConsumerStatefulWidget {
  const DeleteAccountDialog({super.key});

  @override
  ConsumerState<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<DeleteAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final l10n = context.l10n;

    return AppDialog(
      title: l10n.deleteAccount,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Text(l10n.deleteAccountInfo),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              validator: MultiValidator([
                RequiredValidator(errorText: l10n.enterEmail),
                EmailValidator(errorText: l10n.invalidEmail),
              ]).call,
              decoration: dialogInputDecoration(label: l10n.email, icon: Icons.email),
            ),
            const SizedBox(height: 16),
            TextFormField(
              obscureText: true,
              controller: _passwordController,
              validator: MultiValidator([
                RequiredValidator(errorText: l10n.enterPassword),
                PatternValidator(passwordPattern, errorText: l10n.invalidPassword),
              ]).call,
              decoration: dialogInputDecoration(label: l10n.password, icon: Icons.password),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent)),
              ),
            authState.isLoading
                ? const CircularProgressIndicator()
                : DefaultButton(onTap: _deleteAccount, title: l10n.deleteAccount, destructive: true),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteAccount() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final viewModel = ref.read(authViewModelProvider.notifier);
    final l10n = context.l10n;

    // Erst re-authentifizieren, damit keine Daten gelöscht werden,
    // wenn das Passwort falsch ist.
    final isValid = await viewModel.validatePassword(_passwordController.text);
    if (!isValid || !ref.read(authViewModelProvider).isValid) {
      setState(() => _errorMessage = l10n.wrongEmailOrPassword);
      return;
    }

    final userRepo = ref.read(userRepositoryProvider);
    if (userRepo == null) {
      setState(() => _errorMessage = l10n.noUserSignedIn);
      return;
    }

    try {
      await userRepo.delete();
    } catch (e) {
      setState(() => _errorMessage = l10n.deleteUserDataFailed(e.toString()));
      return;
    }

    final success = await viewModel.deleteAccount(_emailController.text.trim(), _passwordController.text);
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pushNamedAndRemoveUntil(Routes.auth, (route) => false);
    } else {
      setState(() => _errorMessage = ref.read(authViewModelProvider).error);
    }
  }
}
