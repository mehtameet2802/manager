import 'package:flutter/material.dart';
import 'package:manager/utilities/dialogs/generic_dialog.dart';

Future<bool> deleteDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Delete',
    content: 'Are you sure you want to delete the item',
    optionBuilder: () => {
      'Cancel': false,
      'Delete': true,
    },
  ).then((value) => value ?? false);
}
