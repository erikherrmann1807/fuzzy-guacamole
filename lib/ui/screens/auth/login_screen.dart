import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:fuzzy_guacamole/data/providers/firebase_auth_provider.dart';
import 'package:fuzzy_guacamole/routes.dart';
import 'package:fuzzy_guacamole/styles/colors.dart';
import 'package:fuzzy_guacamole/ui/widgets/default_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authViewModelProvider);
    final viewModel = ref.read(authViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
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
                    controller: emailController,
                    validator: MultiValidator([
                      RequiredValidator(errorText: 'Enter email address'),
                      EmailValidator(errorText: 'Please correct email filled'),
                    ]).call,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email, color: MyColors.raisinBlack),
                      errorStyle: const TextStyle(fontSize: 18.0),
                      border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(9.0))),
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
                      PatternValidator(r"^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$", errorText: 'Wrong Password'),
                    ]).call,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.password, color: MyColors.raisinBlack),
                      border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(9))),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: state.isLoading
                        ? const CircularProgressIndicator()
                        : DefaultButton(
                            onTap: () async {
                              if (_formKey.currentState!.validate()) {
                                await viewModel.login(emailController.text.trim(), passwordController.text.trim());
                              }
                            },
                            title: "Login",
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                if (state.error != null)
                  Center(
                    child: Text(state.error!, style: const TextStyle(color: Colors.redAccent)),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Got no Account?', style: TextStyle(color: Colors.black)),
                    TextButton(
                      child: const Text('You can register here!'),
                      onPressed: () => Navigator.pushReplacementNamed(context, Routes.register),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
