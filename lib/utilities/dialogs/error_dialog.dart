import 'package:flutter/material.dart';
import 'package:manager/utilities/dialogs/generic_dialog.dart';

Future<void> errorDialog(BuildContext context, String text) {
  return showGenericDialog(
    context: context,
    title: 'An error occurred',
    content: text,
    optionBuilder: () => {
      'Ok': null,
    },
  );
}
