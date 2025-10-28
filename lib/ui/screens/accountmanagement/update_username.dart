part of 'account_management_screen.dart';

class UpdateUsername {
  TextEditingController usernameController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();

  Future<void> updateUsernameDialog(BuildContext ctx, WidgetRef ref) async {
    final viewModel = ref.read(authViewModelProvider.notifier);
    Size size = MediaQuery.sizeOf(ctx);
    return showDialog<void>(
      context: ctx,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Container(
            width: size.width,
            height: size.height * 0.3,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(),
              color: MyColors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(color: Colors.black, offset: Offset(1.5, 2), spreadRadius: 2, blurStyle: BlurStyle.solid),
              ],
            ),
            constraints: const BoxConstraints(maxHeight: 300),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Update Username', style: Theme.of(context).textTheme.headlineSmall),
                Flexible(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          'Geben Sie in folgendem Feld Ihren neuen Nutzernamen ein '
                          'und bestätigen Sie die Änderung mit dem Button am Ende',
                        ),
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
                ref.read(authViewModelProvider).isLoading ? CircularProgressIndicator() :
                DefaultButton(onTap: () => _updateUsername(context, viewModel), title: 'Update Username'),
              ],
            ),
          ),
        );
      },
    );
  }

  void _updateUsername(BuildContext context, AuthViewModel viewModel) async {
    await viewModel.updateUsername(usernameController.text);
    await _databaseService.updateMemberName(usernameController.text);

    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}
