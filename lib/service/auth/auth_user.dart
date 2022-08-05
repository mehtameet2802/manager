import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/cupertino.dart';

@immutable
class AuthUser {
  final String? id;
  final String? email;
  final bool isEmailVerified;
  // final String? image;

  const AuthUser({
    required this.id,
    required this.email,
    required this.isEmailVerified,
    // required this.image,
  });

  factory AuthUser.fromFirebase(User user) => AuthUser(
      id: user.uid,
      email: user.email,
      isEmailVerified: user.emailVerified,
      // image: user.photoURL,
  );
}
