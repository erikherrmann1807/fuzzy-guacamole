import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuzzy_guacamole/data/providers/firebase_auth_provider.dart';
import 'package:fuzzy_guacamole/routes.dart';
import 'package:fuzzy_guacamole/ui/screens/accountmanagement/delete_account.dart';
import 'package:fuzzy_guacamole/ui/screens/accountmanagement/reset_password.dart';
import 'package:fuzzy_guacamole/ui/screens/accountmanagement/update_password.dart';
import 'package:fuzzy_guacamole/ui/screens/accountmanagement/update_username.dart';
import 'package:fuzzy_guacamole/ui/widgets/default_button.dart';

class AccountManagementScreen extends ConsumerWidget {
  const AccountManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> logout() async {
      await ref.read(authViewModelProvider.notifier).logout();
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(Routes.auth, (route) => false);
      }
    }

    return Container(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DefaultButton(
              onTap: () => showDialog(context: context, builder: (_) => const ResetPasswordDialog()),
              title: 'Passwort zurücksetzen',
            ),
            const SizedBox(height: 20.0),
            DefaultButton(
              onTap: () => showDialog(context: context, builder: (_) => const UpdateUsernameDialog()),
              title: 'Update Username',
            ),
            const SizedBox(height: 20.0),
            DefaultButton(
              onTap: () => showDialog(context: context, builder: (_) => const DeleteAccountDialog()),
              title: 'Delete Account',
            ),
            const SizedBox(height: 20.0),
            DefaultButton(
              onTap: () => showDialog(context: context, builder: (_) => const UpdatePasswordDialog()),
              title: 'Update Password',
            ),
            const SizedBox(height: 20.0),
            DefaultButton(onTap: logout, title: 'Logout'),
          ],
        ),
      ),
    );
  }
}
