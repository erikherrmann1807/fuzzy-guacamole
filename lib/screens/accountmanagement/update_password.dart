part of 'account_management_screen.dart';

class UpdatePassword {
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController oldPasswordController = TextEditingController();
  bool _isPasswordValid = false;

  Future<void> updatePasswordDialog(BuildContext ctx) async {
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
                constraints: const BoxConstraints(maxHeight: 450),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Update Password', style: Theme.of(context).textTheme.headlineSmall),
                    SizedBox(height: 16),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Text(
                              'Um Ihr Passwort zu ändern benötigen Sie '
                              'ein neues Passwort, das aktuelle Passwort '
                              'und Ihre E-Mail Adresse.',
                            ),
                            SizedBox(height: 16),
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
                                cursorColor: MyColors.raisinBlack,
                                decoration: InputDecoration(
                                  hintText: 'Old Password',
                                  labelText: 'Old Password',
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
                                cursorColor: MyColors.raisinBlack,
                                decoration: InputDecoration(
                                  hintText: 'New Password',
                                  labelText: 'New Password',
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
                                      oldPasswordController.text,
                                    );
                                    setState(() {});
                                    if (_isPasswordValid) {
                                      authServiceGlobal.value.updateUserPassword(
                                        newPassword: newPasswordController.text,
                                      );
                                      Navigator.of(context).pop();
                                    }
                                  },
                                  title: 'Update Password',
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
