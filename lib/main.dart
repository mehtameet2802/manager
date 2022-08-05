import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manager/helpers/loading/loading_screen.dart';
import 'package:manager/service/auth/firebase_auth_provider.dart';
import 'package:manager/service/bloc/auth_bloc.dart';
import 'package:manager/service/bloc/auth_event.dart';
import 'package:manager/service/bloc/auth_state.dart';
import 'package:manager/views/add_item_page.dart';
import 'package:manager/views/inventory_status_page.dart';
import 'package:manager/views/update_item_page.dart';
import 'package:manager/views/home_page.dart';
import 'package:manager/views/login_page.dart';
import 'package:manager/views/register_page.dart';
import 'package:manager/views/verify_email_page.dart';
import 'constants/routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) => runApp(const MyApp()));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const MainPage(),
      ),
      routes: {
        homeRoute: (context) => const HomePage(),
        loginRoute: (context) => const LoginPage(),
        addItemRoute: (context) => const AddItem(),
        registerRoute: (context) => const RegisterPage(),
        updateItemRoute: (context) => const UpdateItem(),
        inventoryRoute: (context) => const InventoryStatusPage(),
      },
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isLoading) {
          LoadingScreen().show(
              context: context,
              text: state.loadingText ?? 'Please wait a moment');
        } else {
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const HomePage();
        } else if (state is AuthStateNeedVerification) {
          return const VerifyEmailPage();
        } else if (state is AuthStateLoggedOut) {
          return const LoginPage();
        } else if (state is AuthStateRegistering) {
          return const RegisterPage();
        } else if (state is AuthStateForgotPassword) {
          return const LoginPage();
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
