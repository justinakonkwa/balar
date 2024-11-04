// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, use_build_context_synchronously

// import 'package:balare/Modeles/Authentification/AuthService.dart';
// import 'package:balare/Modeles/user_modele/user_modele.dart';
// import 'package:balare/authantification/login_page.dart';
// import 'package:balare/authantification/service_otp.dart';
// import 'package:balare/widget/Keyboard_widget.dart';
// import 'package:balare/widget/app_text.dart';
// import 'package:balare/widget/app_text_large.dart';
// import 'package:balare/widget/bouton_next.dart';
// import 'package:balare/widget/constantes.dart';
// import 'package:balare/widget/message_widget.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:country_code_picker/country_code_picker.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_translate/flutter_translate.dart';
// import 'package:pinput/pinput.dart';
//
// class SignupPage extends StatefulWidget {
//   const SignupPage({super.key});
//
//   @override
//   _SignupPageState createState() => _SignupPageState();
// }
//
// class _SignupPageState extends State<SignupPage> {
//   final TextEditingController _phoneNumberController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final AuthService _authService = AuthService();
//   bool isLoading = false;
//   String _countryCode = '+243';
//   bool isPhoneNumberEntered = false; // Variable pour gérer la progression
//   bool _isPasswordVisible = false;
//
//   String? fcmToken;
//
//   @override
//   void initState() {
//     super.initState();
//     _authService.retrieveFCMToken().then((token) {
//       setState(() {
//         fcmToken = token;
//       });
//     });
//   }
//
//   void _verifierNumeroDeTelephone() {
//     _authService.verifierNumeroDeTelephone(
//       phoneNumber: _phoneNumberController.text,
//       password: _passwordController.text,
//       countryCode: _countryCode,
//       context: context,
//       fcmToken: fcmToken,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: isPhoneNumberEntered
//               ? _buildPasswordInput(
//                   context) // Si le numéro est saisi, afficher la saisie du mot de passe
//               : _buildPhoneNumberInput(
//                   context), // Sinon, afficher la saisie du numéro de téléphone
//         ),
//       ),
//     );
//   }
//
//   // Interface de saisie du numéro de téléphone
//   Widget _buildPhoneNumberInput(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         AppTextLarge(
//           size: 25,
//           text: '''Bienvenue chez Balar ! Pour
// commencer, entrez votre
// Numéro de téléphone''',
//           textAlign: TextAlign.center,
//         ),
//         sizedbox,
//         sizedbox,
//         SizedBox(
//           child: Row(
//             children: [
//               Container(
//                 height: 50,
//                 decoration: BoxDecoration(
//                   border: Border.all(
//                     color: Theme.of(context).highlightColor,
//                   ),
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 child: CountryCodePicker(
//                   backgroundColor: Colors.grey,
//                   onChanged: (countryCode) {
//                     setState(() {
//                       _countryCode = countryCode.dialCode!;
//                     });
//                   },
//                   showFlag: true,
//                   showCountryOnly: true,
//                   initialSelection: 'CD',
//                   favorite: ['+243', 'CD'],
//                 ),
//               ),
//               sizedbox2,
//               Expanded(
//                 child: SizedBox(
//                   height: 50,
//                   child: CupertinoTextField(
//                     padding: EdgeInsets.only(left: 30),
//                     controller: _phoneNumberController,
//                     style: TextStyle(
//                       fontFamily: 'Montserrat',
//                       color: Theme.of(context).colorScheme.onBackground,
//                     ),
//
//                     keyboardType:
//                         TextInputType.phone, // Permet l'entrée de chiffres
//                     placeholder: 'Numéro de téléphone',
//                     decoration: BoxDecoration(
//                       border:
//                           Border.all(color: Theme.of(context).highlightColor),
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         sizedbox,
//         CustomKeyboard(
//           onTextInput: (value) {
//             if (_phoneNumberController.text.length < 9) {
//               setState(() {
//                 _phoneNumberController.text += value;
//               });
//             }
//           },
//           onBackspace: () {
//             setState(() {
//               if (_phoneNumberController.text.isNotEmpty) {
//                 _phoneNumberController.text = _phoneNumberController.text
//                     .substring(0, _phoneNumberController.text.length - 1);
//               }
//             });
//           },
//         ),
//         sizedbox,
//         NextButton(
//           width: double.maxFinite,
//           onTap: () {
//             setState(() {
//               isPhoneNumberEntered = true; // Passer à la saisie du mot de passe
//             });
//           },
//           child: isLoading
//               ? CupertinoActivityIndicator(color: Colors.white)
//               : AppText(text: "Continuer", color: Colors.white),
//         ),
//         Row(
//           children: [
//             AppText(
//               text: translate("Avez-vous déjà un compte ?"),
//               color: Theme.of(context).colorScheme.inverseSurface,
//             ),
//             Spacer(),
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context); // Ferme le modal précédent
//                 Navigator.push(
//                   context,
//                   PageRouteBuilder(
//                     pageBuilder: (context, animation, secondaryAnimation) => LoginPage(),
//                     transitionsBuilder: (context, animation, secondaryAnimation, child) {
//                       // Définition de l'animation de transition de gauche à droite
//                       const begin = Offset(-1.0, 0.0); // Départ à gauche de l'écran
//                       const end = Offset.zero;          // Arrivée au centre de l'écran
//                       const curve = Curves.easeInOut;
//
//                       var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
//                       var offsetAnimation = animation.drive(tween);
//
//                       return ScaleTransition(
//                             scale: animation,
//                             child: child,
//                           );
//                     },
//                   ),
//                 );
//               },
//               child: AppText(
//                 text: translate("Se connecter"),
//                 color: Theme.of(context).colorScheme.inverseSurface,
//               ),
//             )
//           ],
//         ),
//       ],
//     );
//   }
//
//   // Interface de saisie du mot de passe avec bouton retour
//   Widget _buildPasswordInput(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         // Bouton de retour
//         Align(
//           alignment: Alignment.topLeft,
//           child: IconButton(
//             icon: Icon(CupertinoIcons.arrow_left_circle),
//             onPressed: () {
//               setState(() {
//                 isPhoneNumberEntered = false; // Revenir à la saisie du numéro
//               });
//             },
//           ),
//         ),
//         sizedbox,
//         sizedbox,
//         sizedbox,
//         AppTextLarge(
//           text: 'Entrez votre code secret',
//           size: 30,
//         ),
//         sizedbox,
//         Pinput(
//           obscureText:
//               !_isPasswordVisible, // Gestion de la visibilité du mot de passe
//           obscuringCharacter: '*', // Afficher les astérisques au lieu de points
//           keyboardType: TextInputType.none,
//           length: 4,
//           controller: _passwordController,
//           onCompleted: (String pin) async {},
//         ),
//         IconButton(
//           icon: Icon(
//             _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
//           ),
//           onPressed: () {
//             setState(() {
//               _isPasswordVisible = !_isPasswordVisible; // Changer la visibilité
//             });
//           },
//         ),
//         sizedbox,
//         CustomKeyboard(
//           onTextInput: (value) {
//             if (_passwordController.text.length < 4) {
//               setState(() {
//                 _passwordController.text += value;
//               });
//             }
//           },
//           onBackspace: () {
//             if (_passwordController.text.isNotEmpty) {
//               _passwordController.text = _passwordController.text
//                   .substring(0, _passwordController.text.length - 1);
//             }
//           },
//         ),
//         sizedbox,
//         NextButton(
//           width: double.maxFinite,
//           onTap: () {
//             _verifierNumeroDeTelephone();
//           },
//           child: isLoading
//               ? CupertinoActivityIndicator(color: Colors.white)
//               : AppText(text: "Continuer", color: Colors.white),
//         ),
//       ],
//     );
//   }
// }


import 'package:balare/Modeles/user_modele/user_modele.dart';
import 'package:balare/authantification/login_page.dart';
import 'package:balare/authantification/service_otp.dart';
import 'package:balare/widget/Keyboard_widget.dart';
import 'package:balare/widget/app_text.dart';
import 'package:balare/widget/app_text_large.dart';
import 'package:balare/widget/bouton_next.dart';
import 'package:balare/widget/constantes.dart';
import 'package:balare/widget/message_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:pinput/pinput.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;
  String _countryCode = '+243';
  bool isPhoneNumberEntered = false; // Variable pour gérer la progression
  bool _isPasswordVisible = false;

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
    if (_phoneNumberController.text.isNotEmpty &&
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
      String formattedPhoneNumber =
          '$_countryCode${_phoneNumberController.text.trim()}';
      print('Numéro de téléphone formaté: $formattedPhoneNumber');

      try {
        // Vérifier si le numéro de téléphone existe déjà
        bool phoneNumberExists =
            await _checkIfPhoneNumberExists(formattedPhoneNumber);
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
          phoneNumber: formattedPhoneNumber,
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
            print(
                "Code envoyé avec succès"); // Ajoute cette ligne pour vérifier

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VerificationOTPPage(
                  phoneNumber: formattedPhoneNumber,
                  verificationId: verificationId,
                  password: _passwordController.text,
                  isSignUp: true,
                  fcmToken: fcmToken ?? '',
                ),
              ),
            );
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            // Handle timeout event
          },
        );
      } catch (e) {
        print('Erreur pendant la vérification du numéro de téléphone : $e');
        // Afficher un message d'erreur convivial
        showMessageDialog(
          context,
          title: "Erreur",
          widget: Padding(
            padding: const EdgeInsets.all(10.0),
            child: AppText(
                textAlign: TextAlign.center,
                text: 'Une erreur est survenue, veuillez réessayer plus tard.'),
          ),
          isConfirmation: false,
          isSale: false,
        );

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
        // name: _nameController.text,
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
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: isPhoneNumberEntered
              ? _buildPasswordInput(
                  context) // Si le numéro est saisi, afficher la saisie du mot de passe
              : _buildPhoneNumberInput(
                  context), // Sinon, afficher la saisie du numéro de téléphone
        ),
      ),
    );
  }

  // Interface de saisie du numéro de téléphone
  Widget _buildPhoneNumberInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppTextLarge(
          size: 25,
          text: '''Bienvenue chez Balar ! Pour
commencer, entrez votre
Numéro de téléphone''',
          textAlign: TextAlign.center,
        ),
        sizedbox,
        sizedbox,
        SizedBox(
          child: Row(
            children: [
              Container(
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).highlightColor,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: CountryCodePicker(
                  backgroundColor: Colors.grey,
                  onChanged: (countryCode) {
                    setState(() {
                      _countryCode = countryCode.dialCode!;
                    });
                  },
                  showFlag: true,
                  showCountryOnly: true,
                  initialSelection: 'CD',
                  favorite: ['+243', 'CD'],
                ),
              ),
              sizedbox2,
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: CupertinoTextField(
                    padding: EdgeInsets.only(left: 30),
                    controller: _phoneNumberController,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: Theme.of(context).colorScheme.onBackground,
                    ),

                    keyboardType:
                        TextInputType.phone, // Permet l'entrée de chiffres
                    placeholder: 'Numéro de téléphone',
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: Theme.of(context).highlightColor),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        sizedbox,
        CustomKeyboard(
          onTextInput: (value) {
            if (_phoneNumberController.text.length < 9) {
              setState(() {
                _phoneNumberController.text += value;
              });
            }
          },
          onBackspace: () {
            setState(() {
              if (_phoneNumberController.text.isNotEmpty) {
                _phoneNumberController.text = _phoneNumberController.text
                    .substring(0, _phoneNumberController.text.length - 1);
              }
            });
          },
        ),
        sizedbox,
        NextButton(
          width: double.maxFinite,
          onTap: () {
            setState(() {
              isPhoneNumberEntered = true; // Passer à la saisie du mot de passe
            });
          },
          child: isLoading
              ? CupertinoActivityIndicator(color: Colors.white)
              : AppText(text: "Continuer", color: Colors.white),
        ),
        Row(
          children: [
            AppText(
              text: translate("Avez-vous déjà un compte ?"),
              color: Theme.of(context).colorScheme.inverseSurface,
            ),
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
              child: AppText(
                text: translate("Se connecter"),
                color: Theme.of(context).colorScheme.inverseSurface,
              ),
            )
          ],
        ),
      ],
    );
  }

  // Interface de saisie du mot de passe avec bouton retour
  Widget _buildPasswordInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Bouton de retour
        Align(
          alignment: Alignment.topLeft,
          child: IconButton(
            icon: Icon(CupertinoIcons.arrow_left_circle),
            onPressed: () {
              setState(() {
                isPhoneNumberEntered = false; // Revenir à la saisie du numéro
              });
            },
          ),
        ),
        sizedbox,
        sizedbox,
        sizedbox,
        AppTextLarge(
          text: 'Entrez votre code secret',
          size: 30,
        ),
        sizedbox,
        Pinput(
          obscureText:
              !_isPasswordVisible, // Gestion de la visibilité du mot de passe
          obscuringCharacter: '*', // Afficher les astérisques au lieu de points
          keyboardType: TextInputType.none,
          length: 4,
          controller: _passwordController,
          onCompleted: (String pin) async {},
        ),
        IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible; // Changer la visibilité
            });
          },
        ),
        sizedbox,
        CustomKeyboard(
          onTextInput: (value) {
            if (_passwordController.text.length < 4) {
              setState(() {
                _passwordController.text += value;
              });
            }
          },
          onBackspace: () {
            if (_passwordController.text.isNotEmpty) {
              _passwordController.text = _passwordController.text
                  .substring(0, _passwordController.text.length - 1);
            }
          },
        ),
        sizedbox,
        NextButton(
          width: double.maxFinite,
          onTap: () {
            _verifierNumeroDeTelephone();
          },
          child: isLoading
              ? CupertinoActivityIndicator(color: Colors.white)
              : AppText(text: "Continuer", color: Colors.white),
        ),
      ],
    );
  }
}
