import 'package:flutter/material.dart';
import 'package:manager/utilities/dialogs/generic_dialog.dart';

Future<void> resetEmailSentDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Password Reset',
    content: 'Please enter your mail id',
    optionBuilder: () => {
      'Ok': null,
    },
  );
}
