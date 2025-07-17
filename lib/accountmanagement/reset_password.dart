part of 'account_management_screen.dart';

class ResetPassword {

Future<void> resetPasswordDialog(BuildContext ctx) async {
    return showDialog<void>(context: ctx,
        builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Passwort zurücksetzen'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('Um ihr Passwort zurückzusetzen wird Ihnen eine E-Mail '
                    'mit einem Link zum Zurücksetzen zugeschickt.'),
              ],
            ),
          ),
          actions: [
            TextButton(
                child: const Text('Passwort zurücksetzen',
                style: TextStyle(
                  color: Colors.red
                ),),
                onPressed: () {
                  authService.value.resetPassword(email: authService.value.currentUser!.email!);
                  Navigator.of(context).pop();
                },
            )
          ],
        );
        }
    );
  }
}
