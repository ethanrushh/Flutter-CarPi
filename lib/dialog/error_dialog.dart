import 'package:flutter/material.dart';
import 'package:carpi/dialog/generic_dialog.dart';

Future<void> showErrorDialog(BuildContext context, String message) {
  return showGenericDalog(
    context: context, 
    title: 'Error', 
    content: message, 
    optionsBuilder: () => {
      'OK': null
    }
  );
}
