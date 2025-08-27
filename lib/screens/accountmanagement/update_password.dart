part of 'account_management_screen.dart';

class UpdatePassword {
  TextEditingController newPasswordController = TextEditingController();

  TextEditingController oldPasswordController = TextEditingController();

  bool _isPasswordValid = false;

  Future<void> updatePasswordDialog(BuildContext ctx) async {
    return showDialog<void>(
      context: ctx,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Update Password'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    Text(
                      'um Ihr Passwort zu ändern benötigen Sie '
                      'ein neues Passwort, das aktuelle Passwort '
                      'und Ihre E-Mail Adresse.',
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        obscureText: true,
                        controller: oldPasswordController,
                        validator: MultiValidator([
                          RequiredValidator(errorText: 'Enter password'),
                          PatternValidator(
                            r"^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$",
                            errorText: _isPasswordValid
                                ? ''
                                : 'Password muss contain minimum eight characters, '
                                      'at least one letter and one number',
                          ),
                        ]).call,
                        decoration: InputDecoration(
                          hintText: 'Old Password',
                          labelText: 'Old Password',
                          prefixIcon: Icon(Icons.password, color: Colors.grey),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                            borderRadius: BorderRadius.all(Radius.circular(9)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        obscureText: true,
                        controller: newPasswordController,
                        validator: MultiValidator([
                          RequiredValidator(errorText: 'Enter password'),
                          PatternValidator(
                            r"^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$",
                            errorText:
                                'Password muss contain minimum eight characters, '
                                'at least one letter and one number',
                          ),
                        ]).call,
                        decoration: InputDecoration(
                          hintText: 'New Password',
                          labelText: 'New Password',
                          prefixIcon: Icon(Icons.password, color: Colors.grey),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                            borderRadius: BorderRadius.all(Radius.circular(9)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Update Password', style: TextStyle(color: Colors.red)),
                  onPressed: () async {
                    _isPasswordValid = await authServiceGlobal.value.validatePassword(oldPasswordController.text);
                    setState(() {});
                    if (_isPasswordValid) {
                      authServiceGlobal.value.updateUserPassword(newPassword: newPasswordController.text);
                      Navigator.pop;
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
