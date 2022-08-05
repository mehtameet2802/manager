import 'package:flutter/material.dart';

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize();
}

class AuthEventRegister extends AuthEvent {
  final String email;
  final String password;

  const AuthEventRegister(
    this.email,
    this.password,
  );
}

class AuthEventShouldRegister extends AuthEvent {
  const AuthEventShouldRegister();
}

class AuthEventLogin extends AuthEvent {
  final String email;
  final String password;

  const AuthEventLogin(
    this.email,
    this.password,
  );
}

class AuthEventNotLoggedIn extends AuthEvent {
  const AuthEventNotLoggedIn();
}

class AuthEventSendEmailVerification extends AuthEvent {
  const AuthEventSendEmailVerification();
}

class AuthEventLogout extends AuthEvent {
  const AuthEventLogout();
}

class AuthEventForgotPassword extends AuthEvent {
  final String? email;

  const AuthEventForgotPassword(this.email);
}

// class AuthEventAddItem extends AuthEvent {
//   const AuthEventAddItem();
// }

// class AuthEventUpdateItem extends AuthEvent {
//   final String documentId;
//   final CloudItem item;
//
//   const AuthEventUpdateItem({
//     required this.documentId,
//     required this.item,
//   });
// }
