import 'package:flutter/material.dart';

import 'generic_dialog.dart';

Future<bool> informationDialog(BuildContext context,String text) {
  return showGenericDialog(
    context: context,
    title: 'Information',
    content: text,
    optionBuilder: () => {
      'Cancel': false,
      'Ok': true,
    },
  ).then((value) => value ?? false);
}