library;

import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:fuzzy_guacamole/services/auth_service.dart';

import '../services/database_service.dart';

part 'reset_password.dart';
part 'update_username.dart';
part 'delete_account.dart';
part 'update_password.dart';

class AccountManagementScreen extends StatelessWidget {
  AccountManagementScreen({super.key});
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account Management')),
      body: SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              TextButton(
                child: Text('Passwort zurücksetzen'),
                onPressed: () => ResetPassword().resetPasswordDialog(context),
              ),
              SizedBox(height: 20.0),
              TextButton(
                child: Text('Update Username'),
                onPressed: () => UpdateUsername().updateUsernameDialog(context),
              ),
              SizedBox(height: 20.0),
              TextButton(child: Text('Delete Account'), onPressed: () => DeleteAccount().deleteAccountDialog(context)),
              SizedBox(height: 20.0),
              TextButton(
                child: Text('Passwort ändern'),
                onPressed: () => UpdatePassword().updatePasswordDialog(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
