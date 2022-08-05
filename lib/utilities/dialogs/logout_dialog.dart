import 'package:flutter/material.dart';
import 'package:manager/utilities/dialogs/generic_dialog.dart';

Future<bool> logoutDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Logout',
    content: 'Are you sure you want to logout',
    optionBuilder: () => {
      'Cancel': false,
      'Logout': true,
    },
  ).then((value) => value ?? false);
}
