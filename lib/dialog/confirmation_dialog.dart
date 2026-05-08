import 'package:flutter/material.dart';
import 'package:carpi/dialog/generic_dialog.dart';

Future<bool> showConfirmationDialog({
  required String title,
  required String content,
  required String confirmationButtonText,
  required BuildContext context
}) async {
  final result = await showGenericDalog<bool>(context: context, 
    title: title,
    content: content, 
    optionsBuilder: () => {
      'Cancel': false,
      confirmationButtonText: true
    }
  );

  return result ?? false;
}
