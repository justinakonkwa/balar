// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, use_build_context_synchronously

import 'package:balare/Modeles/user_modele/user_modele.dart';
import 'package:balare/authantification/login_page.dart';
import 'package:balare/authantification/service_otp.dart';
import 'package:balare/widget/app_text.dart';
import 'package:balare/widget/app_text_large.dart';
import 'package:balare/widget/bouton_next.dart';
import 'package:balare/widget/constantes.dart';
import 'package:balare/widget/loading_widget.dart';
import 'package:balare/widget/message_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController =
      TextEditingController(text: '+243');
  final TextEditingController _passwordController = TextEditingController();
  bool visibility = false;
  bool isLoading = false;
  String? fcmToken;

  @override
  void initState() {
    super.initState();
    _retrieveFCMToken();
  }

  Future<void> _retrieveFCMToken() async {
    fcmToken = await FirebaseMessaging.instance.getToken();
    print('FCM Token: $fcmToken');
  }

  Future<void> _verifierNumeroDeTelephone() async {
    if (_nameController.text.isNotEmpty &&
        _phoneNumberController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      setState(() => isLoading = true);
      // Vérifier la longueur du mot de passe
      if (_passwordController.text.length < 4) {
        setState(() => isLoading = false);

        print(
            'Mot de passe trop court. Veuillez choisir un mot de passe d\'au moins 4 caractères.');
        return showMessageDialog(
          context,
          title: "Erreur",
          widget: Padding(
            padding: const EdgeInsets.all(10.0),
            child: AppText(
                textAlign: TextAlign.center,
                text:
                    'Mot de passe trop court. Veuillez choisir un mot de passe d\'au moins 4 caractère'),
          ),
          isConfirmation: false,
          isSale: false,
        );
      }
      try {
        // Vérifier si le numéro de téléphone existe déjà
        bool phoneNumberExists =
            await _checkIfPhoneNumberExists(_phoneNumberController.text);
        if (phoneNumberExists) {
          setState(() => isLoading = false);
          // Afficher un message indiquant que le compte existe déjà;
          return showMessageDialog(
            context,
            title: "Erreur",
            widget: Padding(
              padding: const EdgeInsets.all(10.0),
              child: AppText(
                  textAlign: TextAlign.center,
                  text:
                      'Ce numéro de téléphone a déjà un compte. Veuillez vous connecter'),
            ),
            isConfirmation: false,
            isSale: false,
          );
        }

        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: _phoneNumberController.text,
          verificationCompleted: (PhoneAuthCredential credential) async {
            // Auto-retrieval of the SMS code completed
            await _connexionAvecCredential(credential);
          },
          verificationFailed: (FirebaseAuthException e) {
            // Handle verification failure
            print('Échec de la vérification : ${e.message}');
          },
          codeSent: (String verificationId, int? resendToken) {
            setState(() => isLoading = false);
            closeLoadingDialog(context);
            showModalBottomSheet(
              context: context,
              isScrollControlled: false,
              builder: (BuildContext context) {
                return VerificationOTPPage(
                  phoneNumber: _phoneNumberController.text,
                  verificationId: verificationId,
                  name: _nameController.text,
                  password: _passwordController.text,
                  isSignUp: true,
                  fcmToken: fcmToken ?? '',
                );
              },
            );
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            // Handle timeout event
          },
        );
      } catch (e) {
        print('Erreur pendant la vérification du numéro de téléphone : $e');
      }
    } else {
      showMessageDialog(
        context,
        title: "Erreur",
        widget: Padding(
          padding: const EdgeInsets.all(10.0),
          child: AppText(
              textAlign: TextAlign.center, text: 'complèter vos cordonnées.'),
        ),
        isConfirmation: false,
        isSale: false,
      );
    }
  }

  Future<bool> _checkIfPhoneNumberExists(String phoneNumber) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: phoneNumber)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print(
          'Erreur lors de la vérification de l\'existence du numéro de téléphone : $e');
      return false;
    }
  }

  Future<void> _connexionAvecCredential(PhoneAuthCredential credential) async {
    try {
      UserCredential authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Récupérer le token FCM
      String? fcmToken = await FirebaseMessaging.instance.getToken();

      // Création de l'utilisateur à enregistrer dans Firestore
      UserManager user = UserManager(
        uid: authResult.user!.uid,
        name: _nameController.text,
        phoneNumber: _phoneNumberController.text,
        password: _passwordController.text,
        fcmToken: fcmToken,
      );

      // Enregistrer l'utilisateur dans Firestore avec son UID
      await FirebaseFirestore.instance
          .collection('users')
          .doc(authResult.user!.uid)
          .set(user.toMap());

      // Naviguer vers la page suivante après l'inscription réussie
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      print('Erreur pendant la connexion : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Stack(
            alignment: Alignment(0, -1.08),
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.tertiary,
                    width: 2.0,
                  ),
                  color: Theme.of(context).colorScheme.background,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                      top: 10,
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                AppTextLarge(
                                  text: 'CREE VOTRE COMPTE',
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                  size: 16,
                                ),
                                Spacer(),
                                IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.red,
                                    size: 30,
                                  ),
                                )
                              ],
                            ),
                            sizedbox,
                            sizedbox,
                            SizedBox(
                              height: 40,
                              child: CupertinoTextField(
                                controller: _nameController,
                                style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground),
                                // keyboardType: TextInputType.phone,
                                placeholder: 'Entrer votre nom',
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                prefix: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: Icon(CupertinoIcons.person),
                                ),
                              ),
                            ),
                            sizedbox,
                            sizedbox,
                            SizedBox(
                              height: 40,
                              child: CupertinoTextField(
                                controller: _phoneNumberController,
                                style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground),
                                keyboardType: TextInputType.phone,
                                placeholder: 'Phone Number',
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                prefix: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: Icon(CupertinoIcons.phone),
                                ),
                              ),
                            ),
                            sizedbox,
                            sizedbox,
                            SizedBox(
                              height: 40,
                              child: CupertinoTextField(
                                controller: _passwordController,
                                style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground),
                                obscureText: visibility,
                                // keyboardType: TextInputType.phone,
                                placeholder: 'Password',
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                prefix: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10.0, right: 10.0),
                                  child: Icon(CupertinoIcons.lock_shield),
                                ),
                                suffix: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10.0, right: 10.0),
                                  child: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        visibility = !visibility;
                                      });
                                    },
                                    icon: visibility
                                        ? Icon(
                                            CupertinoIcons.eye,
                                          )
                                        : Icon(
                                            CupertinoIcons.eye_slash,
                                          ),
                                  ),
                                ),
                                onEditingComplete: () {
                                  if (_phoneNumberController.text.isNotEmpty &&
                                      _passwordController.text.isNotEmpty &&
                                      _nameController.text.isNotEmpty) {
                                    _verifierNumeroDeTelephone();
                                  } else {
                                    setState(() => isLoading = false);
                                  }
                                },
                              ),
                            ),
                            sizedbox,
                            sizedbox,
                            NextButton(
                              width: double.maxFinite,
                              onTap: _verifierNumeroDeTelephone,
                              child: isLoading
                                  ? CupertinoActivityIndicator(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground)
                                  : AppText(
                                      text: "CREE COMPTE",
                                      color: Colors.white,
                                    ),
                            ),
                            // InkWell(
                            //   onTap: () {
                            //     _verifierNumeroDeTelephone();
                            //   },
                            //   child: Container(
                            //     decoration: BoxDecoration(
                            //       borderRadius: BorderRadius.circular(10),
                            //       color: Theme.of(context).colorScheme.primary,
                            //     ),
                            //     alignment: Alignment.center,
                            //     width: double.infinity,
                            //     height: 50,
                            //     child: isLoading
                            //         ? CupertinoActivityIndicator(
                            //             color: Theme.of(context)
                            //                 .colorScheme
                            //                 .onBackground)
                            //         : AppText(
                            //             text: "CREE COMPTE",
                            //             color: Colors.white,
                            //           ),
                            //   ),
                            // ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                AppText(
                                    text: "avez-vous un compte?",
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground),
                                Spacer(),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (BuildContext context) {
                                        return LoginPage();
                                      },
                                    );
                                  },
                                  child: AppTextLarge(
                                    text: "Se connecter",
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    size: 14,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                height: 8,
                width: 50,
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 2),
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white),
              ),
            ],
          );
        },
      ),
    );
  }
}
