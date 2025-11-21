part of 'account_management_screen.dart';

class ResetPassword {
  Future<void> resetPasswordDialog(BuildContext ctx, WidgetRef ref) async {
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                Text('Reset Password', style: Theme.of(context).textTheme.headlineSmall),
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Um ihr Passwort zurückzusetzen wird Ihnen eine E-Mail '
                        'mit einem Link zum Zurücksetzen zugeschickt.',
                      ),
                      ref.read(authViewModelProvider).isLoading
                          ? CircularProgressIndicator()
                          : DefaultButton(onTap: () => _resetPassword(context, viewModel), title: 'Reset Password'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _resetPassword(BuildContext context, AuthViewModel viewModel) async {
    await viewModel.resetPassword(authServiceGlobal.value.currentUser!.email!);
    Navigator.of(context).pop();
  }
}
