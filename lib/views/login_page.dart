import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:manager/service/auth/auth_exceptions.dart';
import 'package:manager/service/bloc/auth_event.dart';
import 'package:manager/service/bloc/auth_state.dart';
import 'package:manager/utilities/dialogs/reset_email_sent_dialog.dart';
import '../service/bloc/auth_bloc.dart';
import '../utilities/dialogs/error_dialog.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late bool _passwordVisible;
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _passwordVisible = false;
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          if (state.exception is UserNotFoundAuthException) {
            await errorDialog(
              context,
              'Can not find user with the entered credentials',
            );
          } else if (state.exception is WrongPasswordAuthException) {
            await errorDialog(
              context,
              'Wrong Credentials',
            );
          } else if (state.exception is GenericAuthException) {
            await errorDialog(context, 'Some error occurred');
          }
        }
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 60,
              ),
              Center(
                child: Text(
                  'Manager',
                  style: GoogleFonts.lato(
                    fontSize: 40,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 0),
                child: SizedBox(
                  height: 0.4 * MediaQuery.of(context).size.height,
                  width: double.infinity,
                  child: Image.asset('assets/images/manager.jpg'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: TextField(
                  controller: _email,
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.email),
                      hintText: 'Email',
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(30.0)))),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: TextField(
                  controller: _password,
                  obscureText: !_passwordVisible,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.key),
                    hintText: 'Password',
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(30.0),
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Theme.of(context).primaryColorDark,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextButton(
                onPressed: () {
                  final email = _email.text;
                  final password = _password.text;
                  context.read<AuthBloc>().add(
                        AuthEventLogin(
                          email,
                          password,
                        ),
                      );
                },
                child: const Text(
                  'Login',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      context
                          .read<AuthBloc>()
                          .add(const AuthEventShouldRegister());
                    },
                    child: const Text(
                      'Not Registered?',
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                  const Text(' | '),
                  TextButton(
                    onPressed: () {
                      final email = _email.text;
                      if (email.isEmpty) {
                        resetEmailSentDialog(context);
                      } else {
                        context
                            .read<AuthBloc>()
                            .add(AuthEventForgotPassword(email));
                      }
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
