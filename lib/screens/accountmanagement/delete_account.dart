part of 'account_management_screen.dart';

class DeleteAccount {
  final DatabaseService _databaseService = DatabaseService();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isPasswordValid = false;

  Future<void> deleteAccountDialog(BuildContext ctx) async {
    Size size = MediaQuery.sizeOf(ctx);
    return showDialog<void>(
      context: ctx,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Container(
                width: size.width,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(),
                  color: MyColors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(color: Colors.black, offset: Offset(1.5, 2), spreadRadius: 2, blurStyle: BlurStyle.solid),
                  ],
                ),
                constraints: const BoxConstraints(maxHeight: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Delete Account', style: Theme.of(context).textTheme.headlineSmall),
                    SizedBox(height: 16),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Text(
                              'Um Ihren Account zu löschen müssen Sie '
                              'Ihre E-Mail und Ihr Passwort angeben.',
                            ),
                            SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: emailController,
                                validator: MultiValidator([
                                  RequiredValidator(errorText: 'Enter email address'),
                                  EmailValidator(errorText: 'Please correct email filled'),
                                ]).call,
                                cursorColor: MyColors.raisinBlack,
                                decoration: InputDecoration(
                                  hintText: 'Email',
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.email, color: MyColors.raisinBlack),
                                  errorStyle: TextStyle(fontSize: 18.0),
                                  labelStyle: TextStyle(color: MyColors.raisinBlack),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: MyColors.raisinBlack),
                                    borderRadius: BorderRadius.all(Radius.circular(9.0)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: MyColors.raisinBlack),
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
                                cursorColor: MyColors.raisinBlack,
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  labelText: 'Password',
                                  prefixIcon: Icon(Icons.password, color: MyColors.raisinBlack),
                                  labelStyle: TextStyle(color: MyColors.raisinBlack),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: MyColors.raisinBlack),
                                    borderRadius: BorderRadius.all(Radius.circular(9.0)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: MyColors.raisinBlack),
                                    borderRadius: BorderRadius.all(Radius.circular(9.0)),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                DefaultButton(
                                  onTap: () async {
                                    _isPasswordValid = await authServiceGlobal.value.validatePassword(
                                      passwordController.text,
                                    );
                                    setState(() {});
                                    if (_isPasswordValid) {
                                      authServiceGlobal.value.deleteAccount(
                                        email: emailController.text,
                                        password: passwordController.text,
                                      );
                                      _databaseService.deleteMember();
                                      Navigator.of(context).pop();
                                    }
                                  },
                                  title: 'Delete Account',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
