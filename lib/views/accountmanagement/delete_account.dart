part of 'account_management_screen.dart';

class DeleteAccount {
  final DatabaseService _databaseService = DatabaseService();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isPasswordValid = false;

  Future<void> deleteAccountDialog(BuildContext ctx) async {
    return showDialog<void>(
      context: ctx,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Delete Account'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    Text(
                      'Um Ihren Account zu löschen müssen Sie '
                      'Ihre E-Mail und Ihr Passwort angeben.',
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: emailController,
                        validator: MultiValidator([
                          RequiredValidator(errorText: 'Enter email address'),
                          EmailValidator(errorText: 'Please correct email filled'),
                        ]).call,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email, color: Colors.lightBlue),
                          errorStyle: TextStyle(fontSize: 18.0),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                            borderRadius: BorderRadius.all(Radius.circular(9.0)),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        obscureText: true,
                        controller: passwordController,
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
                          hintText: 'Password',
                          labelText: 'Password',
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
                  child: const Text('Delete Account', style: TextStyle(color: Colors.red)),
                  onPressed: () async {
                    _isPasswordValid = await authServiceGlobal.value.validatePassword(passwordController.text);
                    setState(() {});
                    if (_isPasswordValid) {
                      authServiceGlobal.value.deleteAccount(email: emailController.text, password: passwordController.text);
                      _databaseService.deleteMember();
                      Navigator.of(context).pop();
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
