


import 'package:balare/widget/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';


/// Loading dialog widget function
/// [context] is the context of the widget
/// return [Future<void>]
Future<void> showLoadingDialog(BuildContext context, {String? message}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
               Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              const SizedBox(width: 30),
              AppText(text: message ?? translate('theme.loading'),),
            ],
          ),
        ),
      );
    },
  );
}


/// Close dialog widget function
Future<void> closeLoadingDialog(BuildContext context) async {
  return Navigator.of(context).pop();
}

