import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:manager/service/bloc/auth_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../service/bloc/auth_bloc.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({Key? key}) : super(key: key);

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 100,
            ),
            Center(
              child: Text(
                'Verify',
                style: GoogleFonts.lato(
                  fontSize: 40,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Verification email has been sent,\nPlease verify your email',
                style: GoogleFonts.lato(fontSize: 15),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text('To resend verification email click here'),
            TextButton(
              onPressed: () async {
                context.read<AuthBloc>().add(
                      const AuthEventSendEmailVerification(),
                    );
              },
              child: const Text('Resend Email'),
            ),
            TextButton(
              onPressed: () async {
                context.read<AuthBloc>().add(const AuthEventLogout());
              },
              child: const Text('Restart'),
            )
          ],
        ),
      ),
    );
  }
}
