// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, library_private_types_in_public_api, unused_field
import 'package:balare/authantification/service_otp.dart';
import 'package:balare/authantification/signup_page.dart';
import 'package:balare/widget/app_text.dart';
import 'package:balare/widget/app_text_large.dart';
import 'package:balare/widget/bouton_next.dart';
import 'package:balare/widget/constantes.dart';
import 'package:balare/widget/loading_widget.dart';
import 'package:balare/widget/message_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_translate/flutter_translate.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
    // Ecouter les changements d'état de l'authentification
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        // Utilisateur connecté
        _updateFCMToken(); // Mettre à jour le token FCM
      }
    });
  }

  // Méthode pour mettre à jour le token FCM
  Future<void> _updateFCMToken() async {
    try {
      // Récupérer le token FCM
      String? fcmToken = await FirebaseMessaging.instance.getToken();

      // Vérifier si l'utilisateur est déjà connecté
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Mise à jour du token FCM dans Firestore pour l'utilisateur connecté
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'fcmToken': fcmToken,
        });
      }
    } catch (e) {
      print('Erreur lors de la mise à jour du token FCM : $e');
    }
  }

  // Méthode pour récupérer le token FCM
  Future<void> _retrieveFCMToken() async {
    fcmToken = await FirebaseMessaging.instance.getToken();
    print('FCM Token: $fcmToken');
  }

  _sendOTP() async {
    if (_phoneNumberController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      // AllFonction().closeKeyboard(context);
      setState(() => isLoading = true);
      String phoneNumber = _phoneNumberController.text;

      try {
        QuerySnapshot<Map<String, dynamic>> phoneNumberSnapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .where('phoneNumber', isEqualTo: phoneNumber)
                .get();

        QuerySnapshot<Map<String, dynamic>> passwordSnapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .where('password', isEqualTo: _passwordController.text)
                .get();

        if (phoneNumberSnapshot.docs.isNotEmpty &&
            passwordSnapshot.docs.isNotEmpty) {
          await FirebaseAuth.instance.verifyPhoneNumber(
            phoneNumber: phoneNumber,
            verificationCompleted: (PhoneAuthCredential credential) async {
              // {
              //   String? fcmToken = await FirebaseMessaging.instance.getToken();

              //   // Authentifier l'utilisateur avec les identifiants reçus
              //   User? user = FirebaseAuth.instance.currentUser;

              //   if (user != null) {
              //     // Mise à jour du token FCM dans Firestore pour l'utilisateur connecté
              //     await FirebaseFirestore.instance
              //         .collection('users')
              //         .doc(user.uid)
              //         .update({
              //       'fcmToken': fcmToken,
              //     });
              //   }
              // }
            },
            verificationFailed: (FirebaseAuthException e) {
              print('Erreur d\'envoi de l\'OTP: ${e.message}');
              showMessageDialog(
                context,
                title: translate("Erreur"),
                widget: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: AppText(
                      textAlign: TextAlign.center,
                      text: 'vérifiez votre connexion Internet'),
                ),
                isConfirmation: false,
                isSale: false,
              );

              setState(() => isLoading = false);
            },
            codeSent: (String verificationId, int? resendToken) {
              closeLoadingDialog(context);
              setState(() => isLoading = false);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return VerificationOTPPage(
                      phoneNumber: phoneNumber,
                      verificationId: verificationId,
                      name: '',
                      password: _passwordController.text,
                      isSignUp: false,
                      fcmToken: fcmToken ?? '');
                },
              );
            },
            codeAutoRetrievalTimeout: (String verificationId) {
              print('Délai d\'attente de l\'OTP atteint');
            },
          );
        } else {
          setState(() => isLoading = false);
          if (phoneNumberSnapshot.docs.isEmpty &&
              passwordSnapshot.docs.isEmpty) {
            print('Vos informations sont fausses.');
            showMessageDialog(
              context,
              title: translate("Erreur"),
              widget: Padding(
                padding: const EdgeInsets.all(10.0),
                child: AppText(
                    textAlign: TextAlign.center,
                    text: 'Vos informations sont fausses.'),
              ),
              isConfirmation: false,
              isSale: false,
            );
          } else {
            if (phoneNumberSnapshot.docs.isEmpty) {
              print('Erreur: numéro de téléphone incorrect.');
              showMessageDialog(
                context,
                title: translate("Erreur"),
                widget: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: AppText(
                      textAlign: TextAlign.center,
                      text: 'Votre numéro de téléphone est incorrect.'),
                ),
                isConfirmation: false,
                isSale: false,
              );
            }
            if (passwordSnapshot.docs.isEmpty) {
              print('Erreur: mot de passe incorrect.');
              showMessageDialog(
                context,
                title: "Erreur",
                widget: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: AppText(
                      textAlign: TextAlign.center,
                      text: 'Votre mot de passe est incorrect.'),
                ),
                isConfirmation: false,
                isSale: false,
              );
            }
          }
        }
      } catch (e) {
        print('Erreur lors de la vérification des informations: $e');
        setState(() => isLoading = false);
      }
    } else {
      setState(() => isLoading = false);
      showMessageDialog(
        context,
        title: translate("Erreur"),
        widget: Padding(
          padding: const EdgeInsets.all(10.0),
          child: AppText(
              textAlign: TextAlign.center, text: 'complèter vos cordonnées.'),
        ),
        isConfirmation: false,
        isSale: false,
      );
      print('---enregistrer vos coordonnees');
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
                                  text: ' SE CONNECTER',
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
                            SizedBox(height: 20),
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
                            SizedBox(height: 20),
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
                              ),
                            ),
                            sizedbox,
                            sizedbox,
                            NextButton(
                              width: double.maxFinite,
                              onTap: _sendOTP,
                              child: isLoading
                                  ? CupertinoActivityIndicator(
                                      color: Colors.white)
                                  : AppText(
                                      text: "SE CONNECTER",
                                      color: Colors.white,
                                    ),
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                AppText(
                                  text: "avez-vous un compte?",
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                ),
                                Spacer(),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (BuildContext context) {
                                        return SignUpPage();
                                      },
                                    );
                                  },
                                  child: AppTextLarge(
                                    text: "cree un compte",
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    size: 14,
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 20),
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
