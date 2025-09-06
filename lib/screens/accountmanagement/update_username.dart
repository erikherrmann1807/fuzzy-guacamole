part of 'account_management_screen.dart';

class UpdateUsername {
  TextEditingController usernameController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();

  Future<void> updateUsernameDialog(BuildContext ctx) async {
    Size size = MediaQuery.sizeOf(ctx);
    return showDialog<void>(
      context: ctx,
      builder: (BuildContext context) {
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
            constraints: const BoxConstraints(maxHeight: 260),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Update Username', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(
                          'Geben Sie in folgendem Feld Ihren neuen Nutzernamen ein '
                          'und bestätigen Sie die Änderung mit dem Button am Ende',
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
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
                          cursorColor: MyColors.raisinBlack,
                          decoration: InputDecoration(
                            hintText: 'Username',
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.person),
                            errorStyle: TextStyle(fontSize: 14.0),
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
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [DefaultButton(onTap: () => _updateUsername(context), title: 'Update Username')],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _updateUsername(BuildContext context) {
    authServiceGlobal.value.updateUsername(username: usernameController.text);
    _databaseService.updateMemberName(usernameController.text);
    Navigator.of(context).pop();
  }
}
