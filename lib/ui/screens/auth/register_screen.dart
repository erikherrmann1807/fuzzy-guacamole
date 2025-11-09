import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:fuzzy_guacamole/data/models/user_model.dart';
import 'package:fuzzy_guacamole/data/providers/firebase_auth_provider.dart';
import 'package:fuzzy_guacamole/data/providers/firebase_firestore_provider.dart';
import 'package:fuzzy_guacamole/data/services/auth_service.dart';
import 'package:fuzzy_guacamole/data/services/database_service.dart';
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
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

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
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
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
                      RequiredValidator(errorText: 'Enter Username'),
                      PatternValidator(
                        r"^(?=[a-zA-Z0-9._]{8,20}$)(?!.*[_.]{2})[^_.].*[^_.]$",
                        errorText:
                            'The Username needs to be 8-20 Characters long.\n'
                            'No "_" or "." at the beginning.\n'
                            'No "__" or "_." or "._" or ".." inside.\n'
                            'No "_" or "." at the end.',
                      ),
                    ]).call,
                    decoration: InputDecoration(
                      hintText: 'Username',
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person, color: MyColors.raisinBlack),
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
                    controller: emailController,
                    validator: MultiValidator([
                      RequiredValidator(errorText: 'Enter email address'),
                      EmailValidator(errorText: 'Please correct email filled'),
                    ]).call,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email, color: MyColors.raisinBlack),
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
                      prefixIcon: Icon(Icons.password, color: MyColors.raisinBlack),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                        borderRadius: BorderRadius.all(Radius.circular(9)),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: state.isLoading ? const CircularProgressIndicator() : DefaultButton(
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          register(viewModel);
                        }
                      },
                      title: "Register",
                    ),
                  ),
                ),
                SizedBox(height: 10),
                if (state.error != null)
                  Center(
                    child: Text(state.error!,
                        style: TextStyle(color: Colors.redAccent)
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void register(AuthViewModel viewModel) async {
    await viewModel.createAccount(emailController.text, passwordController.text, usernameController.text);
    final userRepo = ref.read(userRepositoryProvider);
    if (userRepo != null) {
      await userRepo.create(
        Member(
            userName: usernameController.text,
            email: emailController.text
        )
      );
    }
    popPage();
  }

  void popPage() {
    Navigator.pushReplacementNamed(context, '/eventCalendar');
  }
}
