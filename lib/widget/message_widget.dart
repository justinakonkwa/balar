// ignore_for_file: prefer_const_constructors

import 'package:balare/widget/app_text.dart';
import 'package:balare/widget/app_text_large.dart';
import 'package:balare/widget/constantes.dart';
import 'package:balare/widget/lign.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';


void showCustomSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      content: Row(
        children: [
          Icon(
            Icons.info,
            size: 30,
            color: Colors.white,
          ),
          SizedBox(width: 10),
          Flexible(
            child: AppText(
              text: text,
            ),
          ),
        ],
      ),
      duration: Duration(seconds: 3),
      action: SnackBarAction(
        label: 'Fermer',
        textColor: Colors.white,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    ),
  );
}

/// Message Dialog widget function
/// [context] is the context of the widget
/// [title] is the title of the dialog
/// [message] is the message of the dialog
Future<void> showMessageDialog(BuildContext context,
    {required String title,
    required Widget widget,
    required isConfirmation,
    required isSale,
    String? productId}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        surfaceTintColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.only(top: 20, bottom: 20),
          decoration: BoxDecoration(
            // color: Colors.white,
            borderRadius: borderRadius,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextLarge(
                textAlign: TextAlign.center,
                text: title,
                size: 16,
              ),
              sizedbox,
              widget,
              isConfirmation
                  ? const SizedBox(
                      height: 20,
                    )
                  : SizedBox(),
              isSale ? SizedBox() : Lign(indent: 0, endIndent: 0),
              isConfirmation
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          height: 30,
                          color: Theme.of(context).colorScheme.primary,
                          child: MaterialButton(
                            onPressed: () async {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => StoragePages(),
                              //   ),
                              // );
                              User? user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                String currentUserID = user.uid;

                                return FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(currentUserID)
                                    .collection('stock')
                                    .doc(productId)
                                    .delete()
                                    .then(
                                      (value) => showCustomSnackBar(context,
                                          'le produit a été supprimer'),
                                    )
                                    .catchError(
                                      (error) => print('erreur de suprression'),
                                    );
                              }
                            },
                            child:
                                AppText(text: 'Confirmer', color: Colors.white),
                          ),
                        ),
                        Container(
                          height: 30,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color:
                                      Theme.of(context).colorScheme.primary)),
                          child: MaterialButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: AppText(
                              text: 'Annuler',
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    )
                  : isSale
                      ? SizedBox()
                      : TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: AppText(text: translate('theme.ok')),
                        )
            ],
          ),
        ),
      );
    },
  );
}
