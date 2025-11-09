library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:fuzzy_guacamole/data/providers/firebase_auth_provider.dart';
import 'package:fuzzy_guacamole/data/providers/firebase_firestore_provider.dart';
import 'package:fuzzy_guacamole/data/repositories/database/user_repository.dart';
import 'package:fuzzy_guacamole/data/services/auth_service.dart';
import 'package:fuzzy_guacamole/data/services/database_service.dart';
import 'package:fuzzy_guacamole/routes.dart';
import 'package:fuzzy_guacamole/styles/colors.dart';
import 'package:fuzzy_guacamole/ui/viewmodels/auth_viewmodel.dart';
import 'package:fuzzy_guacamole/ui/viewmodels/profile_viewmodel.dart';
import 'package:fuzzy_guacamole/ui/widgets/default_button.dart';

part 'reset_password.dart';
part 'update_username.dart';
part 'delete_account.dart';
part 'update_password.dart';

class AccountManagementScreen extends ConsumerWidget {
  AccountManagementScreen({super.key});
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(authViewModelProvider.notifier);
    void popPage() {
      Navigator.of(context).pushNamedAndRemoveUntil('/authLayout', (route) => false);
    }

    Future<void> logout() async {
      await viewModel.logout();
      popPage();
    }

    return Container(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DefaultButton(onTap: () => ResetPassword().resetPasswordDialog(context, ref), title: 'Passwort zurücksetzen'),
            SizedBox(height: 20.0),
            DefaultButton(onTap: () => UpdateUsername().updateUsernameDialog(context, ref), title: 'Update Username'),
            SizedBox(height: 20.0),
            DefaultButton(onTap: () => DeleteAccount().deleteAccountDialog(context, ref), title: 'Delete Account'),
            SizedBox(height: 20.0),
            DefaultButton(onTap: () => UpdatePassword().updatePasswordDialog(context, ref), title: 'Update Password'),
            SizedBox(height: 20.0),
            DefaultButton(onTap: () => logout(), title: "Logout"),
          ],
        ),
      ),
    );
  }
}
