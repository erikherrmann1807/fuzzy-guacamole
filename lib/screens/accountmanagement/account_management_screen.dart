library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:fuzzy_guacamole/services/auth_service.dart';
import 'package:fuzzy_guacamole/services/database_service.dart';
import 'package:fuzzy_guacamole/widgets/default_button.dart';

part 'reset_password.dart';
part 'update_username.dart';
part 'delete_account.dart';
part 'update_password.dart';

class AccountManagementScreen extends StatelessWidget {
  AccountManagementScreen({super.key});
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    void popPage() {
      Navigator.of(context).pushNamedAndRemoveUntil('/authLayout', (route) => false);
    }

    Future<void> logout() async {
      try {
        await authServiceGlobal.value.signOut();
        popPage();
      } on FirebaseAuthException catch (e) {
        Text(e.message!);
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Account Management')),
      body: SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              DefaultButton(
                  onTap: () => ResetPassword().resetPasswordDialog(context),
                  title: 'Passwort zurücksetzen'
              ),
              SizedBox(height: 20.0),
              DefaultButton(
                  onTap: () => UpdateUsername().updateUsernameDialog(context),
                  title: 'Update Username'
              ),
              SizedBox(height: 20.0),
              DefaultButton(
                  onTap: () => DeleteAccount().deleteAccountDialog(context),
                  title: 'Delete Account'
              ),
              SizedBox(height: 20.0),
              DefaultButton(
                  onTap: () => UpdatePassword().updatePasswordDialog(context),
                  title: 'Change Password'
              ),
              SizedBox(height: 20.0),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
                onTap: () => logout(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
