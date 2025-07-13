part of 'account_management_screen.dart';

class UpdatePassword {
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  Future<void> updatePasswordDialog(BuildContext ctx) async {
    return showDialog<void>(context: ctx,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Update Username'),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Text('um Ihr Passwort zu ändern benötigen Sie '
                      'ein neues Passwort, das aktuelle Passwort '
                      'und Ihre E-Mail Adresse.'),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
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
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text('Update Password',
                  style: TextStyle(
                      color: Colors.red
                  ),),
                onPressed: () {
                  authService.value.resetPasswordFromCurrentPassword(currentPassword: oldPasswordController.text, newPassword: newPasswordController.text, email: emailController.text);
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        }
    );
  }
}
