import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../auth/auth_user.dart';

@immutable
abstract class AuthState {
  final bool isLoading;
  final String? loadingText;

  const AuthState({
    required this.isLoading,
    this.loadingText = 'Please wait a moment',
  });
}

class AuthStateForgotPassword extends AuthState {
  final Exception? exception;
  final bool hasSentEmail;

  const AuthStateForgotPassword({
    required this.exception,
    required this.hasSentEmail,
    required bool isLoading,
    String? text,
  }) : super(isLoading: isLoading,loadingText: text);
}

class AuthStateLoggedIn extends AuthState {
  final AuthUser user;

  const AuthStateLoggedIn({required this.user, required bool isLoading})
      : super(isLoading: isLoading);
}

class AuthStateUninitialized extends AuthState {
  const AuthStateUninitialized({required bool isLoading})
      : super(isLoading: isLoading);
}

class AuthStateRegistering extends AuthState {
  final Exception? exception;

  const AuthStateRegistering({
    required this.exception,
    required bool isLoading,
  }) : super(isLoading: isLoading);
}

class AuthStateNeedVerification extends AuthState {
  const AuthStateNeedVerification({required bool isLoading})
      : super(isLoading: isLoading);
}

class AuthStateLoggedOut extends AuthState with EquatableMixin {
  final Exception? exception;

  const AuthStateLoggedOut({
    required this.exception,
    required bool isLoading,
    String? loadingText,
  }) : super(isLoading: isLoading);

  @override
  List<Object?> get props => [exception, isLoading];
}

// class AuthStateUpdateItem extends AuthState {
//   final String documentId;
//   final CloudItem item;
//
//   const AuthStateUpdateItem({
//     required this.documentId,
//     required this.item,
//     required bool isLoading,
//   }) : super(isLoading: isLoading);
// }
