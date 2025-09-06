part of 'account_management_screen.dart';

class ResetPassword {
  Future<void> resetPasswordDialog(BuildContext ctx) async {
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
                Text('Reset Password', style: Theme.of(context).textTheme.headlineSmall),
                SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(
                          'Um ihr Passwort zurückzusetzen wird Ihnen eine E-Mail '
                          'mit einem Link zum Zurücksetzen zugeschickt.',
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [DefaultButton(onTap: () => _resetPassword(context), title: 'Reset Password')],
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
  }

  void _resetPassword(BuildContext context) {
    authServiceGlobal.value.resetPassword(email: authServiceGlobal.value.currentUser!.email!);
    Navigator.of(context).pop();
  }
}
