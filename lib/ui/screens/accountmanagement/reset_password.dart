import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuzzy_guacamole/data/providers/firebase_auth_provider.dart';
import 'package:fuzzy_guacamole/ui/widgets/app_dialog.dart';
import 'package:fuzzy_guacamole/ui/widgets/default_button.dart';

class ResetPasswordDialog extends ConsumerWidget {
  const ResetPasswordDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);

    return AppDialog(
      title: 'Reset Password',
      maxHeight: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text(
            'Um ihr Passwort zurückzusetzen wird Ihnen eine E-Mail '
            'mit einem Link zum Zurücksetzen zugeschickt.',
          ),
          const SizedBox(height: 16),
          if (authState.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(authState.error!, style: const TextStyle(color: Colors.redAccent)),
            ),
          authState.isLoading
              ? const CircularProgressIndicator()
              : DefaultButton(onTap: () => _resetPassword(context, ref), title: 'Reset Password'),
        ],
      ),
    );
  }

  Future<void> _resetPassword(BuildContext context, WidgetRef ref) async {
    final email = ref.read(authViewModelProvider).user?.email;
    if (email == null) return;
    final success = await ref.read(authViewModelProvider.notifier).resetPassword(email);
    if (success && context.mounted) {
      Navigator.of(context).pop();
    }
  }
}
