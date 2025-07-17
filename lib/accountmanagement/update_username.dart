part of 'account_management_screen.dart';

class UpdateUsername {
  TextEditingController usernameController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();

  Future<void> updateUsernameDialog(BuildContext ctx) async {
    return showDialog<void>(
      context: ctx,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Username'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(
                  'Geben Sie in folgendem Feld Ihren neuen Nutzernamen ein '
                  'und bestätigen Sie die Änderung mit dem Button am Ende',
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: usernameController,
                    validator: MultiValidator([
                      RequiredValidator(errorText: 'Enter Username'),
                      PatternValidator(
                        r"^(?=[a-zA-Z0-9._]{8,20}$)(?!.*[_.]{2})[^_.].*[^_.]$",
                        errorText:
                            'The Username needs to be 8-20 Characters long.\n'
                            'No "_" or "." at the beginning.\n'
                            'No "__" or "_." or "._" or ".." or " " inside.\n'
                            'No "_" or "." at the end.',
                      ),
                    ]).call,
                    decoration: InputDecoration(
                      hintText: 'Username',
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person, color: Colors.lightBlue),
                      errorStyle: TextStyle(fontSize: 18.0),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                        borderRadius: BorderRadius.all(Radius.circular(9.0)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Update Username', style: TextStyle(color: Colors.red)),
              onPressed: () {
                authService.value.updateUsername(username: usernameController.text);
                _databaseService.updateMemberName(usernameController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
