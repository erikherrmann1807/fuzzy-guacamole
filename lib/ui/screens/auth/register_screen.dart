import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:fuzzy_guacamole/constants.dart';
import 'package:fuzzy_guacamole/data/providers/firebase_auth_provider.dart';
import 'package:fuzzy_guacamole/l10n/l10n_extensions.dart';
import 'package:fuzzy_guacamole/routes.dart';
import 'package:fuzzy_guacamole/styles/colors.dart';
import 'package:fuzzy_guacamole/ui/viewmodels/auth_viewmodel.dart';
import 'package:fuzzy_guacamole/ui/widgets/default_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authViewModelProvider);
    final viewModel = ref.read(authViewModelProvider.notifier);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.register)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: usernameController,
                    validator: MultiValidator([
                      RequiredValidator(errorText: l10n.enterUsername),
                      PatternValidator(usernamePattern, errorText: l10n.invalidUsername),
                    ]).call,
                    decoration: InputDecoration(
                      hintText: l10n.username,
                      labelText: l10n.username,
                      prefixIcon: const Icon(Icons.person, color: MyColors.raisinBlack),
                      errorStyle: const TextStyle(fontSize: 18.0),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                        borderRadius: BorderRadius.all(Radius.circular(9.0)),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: emailController,
                    validator: MultiValidator([
                      RequiredValidator(errorText: l10n.enterEmail),
                      EmailValidator(errorText: l10n.invalidEmail),
                    ]).call,
                    decoration: InputDecoration(
                      hintText: l10n.email,
                      labelText: l10n.email,
                      prefixIcon: const Icon(Icons.email, color: MyColors.raisinBlack),
                      errorStyle: const TextStyle(fontSize: 18.0),
                      border: const OutlineInputBorder(
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
                      RequiredValidator(errorText: l10n.enterPassword),
                      PatternValidator(passwordPattern, errorText: l10n.invalidPassword),
                    ]).call,
                    decoration: InputDecoration(
                      hintText: l10n.password,
                      labelText: l10n.password,
                      prefixIcon: const Icon(Icons.password, color: MyColors.raisinBlack),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                        borderRadius: BorderRadius.all(Radius.circular(9)),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: state.isLoading
                        ? const CircularProgressIndicator()
                        : DefaultButton(
                            onTap: () {
                              if (_formKey.currentState!.validate()) {
                                register(viewModel);
                              }
                            },
                            title: l10n.register,
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                if (state.error != null)
                  Center(
                    child: Text(state.error!, style: const TextStyle(color: Colors.redAccent)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> register(AuthViewModel viewModel) async {
    final success = await viewModel.createAccount(
      emailController.text.trim(),
      passwordController.text,
      usernameController.text.trim(),
    );
    // Bei Fehler bleibt der Screen offen und zeigt state.error an.
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, Routes.calendar);
    }
  }
}
