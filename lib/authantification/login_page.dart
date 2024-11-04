import 'package:balare/Modeles/Authentification/AuthService.dart';
import 'package:balare/authantification/service_otp.dart';
import 'package:balare/authantification/signup_page.dart';
import 'package:balare/widget/Keyboard_widget.dart';
import 'package:balare/widget/app_text.dart';
import 'package:balare/widget/app_text_large.dart';
import 'package:balare/widget/bouton_next.dart';
import 'package:balare/widget/constantes.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:pinput/pinput.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool isLoading = false;
  bool isPhoneNumberEntered =
      false; // This flag toggles between phone and password input
  String _countryCode = '+243';
  bool _isPasswordVisible = false;
  String? fcmToken;

  @override
  void initState() {
    super.initState();
    _initAuth();
  }

  Future<void> _initAuth() async {
    await _authService.requestNotificationPermission();
    fcmToken = await _authService.retrieveFCMToken();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        _authService.updateFCMToken(user, fcmToken);
      }
    });
  }

  Future<void> _sendOTP() async {
    if (_phoneNumberController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      setState(() => isLoading = true);

      bool isConnected = await _authService.checkInternetConnection();
      if (!isConnected) {
        _showSnackBar(context,
            "Aucune connexion Internet. Veuillez vérifier votre connexion.");
        setState(() => isLoading = false);
        return;
      }

      String formattedPhoneNumber =
          '$_countryCode${_phoneNumberController.text.trim()}';

      _authService.sendOTP(
        phoneNumber: formattedPhoneNumber,
        password: _passwordController.text,
        context: context,
        onCodeSent: (verificationId) {
          setState(() => isLoading = false);
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (BuildContext context) {
              return VerificationOTPPage(
                phoneNumber: formattedPhoneNumber,
                verificationId: verificationId,
                password: _passwordController.text,
                isSignUp: false,
                fcmToken: fcmToken ?? '',
              );
            },
          );
        },
        onError: (errorMessage) {
          _showErrorDialog(errorMessage);
          setState(() => isLoading = false);
        },
      );
    } else {
      _showErrorDialog('Veuillez compléter vos informations.');
      setState(() => isLoading = false);
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Erreur'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
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
                    keyboardType: TextInputType.none,
                    placeholder: 'Phone Number',
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
              text: translate("Vous n'avez pas de compte ?"),
              color: Theme.of(context).colorScheme.inverseSurface,
            ),
            Spacer(),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Ferme le modal précédent
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        SignupPage(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      // Définition de l'animation de transition de gauche à droite
                      const begin =
                          Offset(-1.0, 0.0); // Départ à gauche de l'écran
                      const end = Offset.zero; // Arrivée au centre de l'écran
                      const curve = Curves.easeInOut;

                      var tween = Tween(begin: begin, end: end)
                          .chain(CurveTween(curve: curve));
                      var offsetAnimation = animation.drive(tween);

                      return ScaleTransition(
                        scale: animation,
                        child: child,
                      );
                    },
                  ),
                );
              },
              child: AppText(
                text: translate("S'inscrire"),
                color: Theme.of(context).colorScheme.onSecondary,
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
        AppTextLarge(
          text: 'Entrez votre code secret',
          size: 25,
          textAlign: TextAlign.center,
        ),
        sizedbox,
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
            _sendOTP();
          },
          child: isLoading
              ? CupertinoActivityIndicator(color: Colors.white)
              : AppText(text: "Continuer.", color: Colors.white),
        ),
      ],
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: isPhoneNumberEntered
                ? _buildPasswordInput(context)
                : _buildPhoneNumberInput(context),
          ),
        ),
      ),
    );
  }
}

//import 'package:balare/authantification/service_otp.dart';
// import 'package:balare/authantification/signup_page.dart';
// import 'package:balare/widget/Keyboard_widget.dart';
// import 'package:balare/widget/app_text.dart';
// import 'package:balare/widget/app_text_large.dart';
// import 'package:balare/widget/bouton_next.dart';
// import 'package:balare/widget/constantes.dart';
// import 'package:balare/widget/message_widget.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:country_code_picker/country_code_picker.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_translate/flutter_translate.dart';
// import 'package:pinput/pinput.dart';
//
// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});
//
//   @override
//   _LoginPageState createState() => _LoginPageState();
// }
//
// class _LoginPageState extends State<LoginPage> {
//   final TextEditingController _phoneNumberController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool isLoading = false;
//   String _countryCode = '+243';
//   bool isPhoneNumberEntered = false;
//   bool _isPasswordVisible = false;
//   String? fcmToken;
//
//   @override
//   void initState() {
//     super.initState();
//     _retrieveFCMToken();
//     FirebaseAuth.instance.authStateChanges().listen((User? user) {
//       if (user != null) {
//         _updateFCMToken();
//       }
//     });
//     _requestNotificationPermission();
//   }
//
//   Future<void> _requestNotificationPermission() async {
//     FirebaseMessaging messaging = FirebaseMessaging.instance;
//     await messaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//   }
//
//   // Méthode pour récupérer le token FCM
//   Future<void> _retrieveFCMToken() async {
//     try {
//       fcmToken = await FirebaseMessaging.instance.getToken();
//       print('FCM Token: $fcmToken');
//     } catch (e) {
//       print('Erreur lors de la récupération du token FCM : $e');
//     }
//   }
//
//   // Méthode pour mettre à jour le token FCM
//   Future<void> _updateFCMToken() async {
//     try {
//       String? fcmToken = await FirebaseMessaging.instance.getToken();
//       User? user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(user.uid)
//             .update({
//           'fcmToken': fcmToken,
//         });
//         print('Token FCM mis à jour pour l\'utilisateur ${user.uid}');
//       }
//     } catch (e) {
//       print('Erreur lors de la mise à jour du token FCM : $e');
//     }
//   }
//
//   Future<void> _sendOTP() async {
//     if (_phoneNumberController.text.isNotEmpty &&
//         _passwordController.text.isNotEmpty) {
//       setState(() => isLoading = true);
//
//       // Vérifier la connexion Internet
//       var connectivityResult = await Connectivity().checkConnectivity();
//       if (connectivityResult == ConnectivityResult.none) {
//         _showSnackBar(context,
//             "Aucune connexion Internet. Veuillez vérifier votre connexion.");
//         setState(() => isLoading = false);
//         return; // Sortir de la méthode si pas de connexion
//       }
//
//       // Formater le numéro de téléphone avec le code pays
//       String formattedPhoneNumber =
//           '$_countryCode${_phoneNumberController.text.trim()}';
//       print('Numéro de téléphone formaté: $formattedPhoneNumber');
//
//       try {
//         QuerySnapshot<Map<String, dynamic>> userSnapshot =
//             await FirebaseFirestore.instance
//                 .collection('users')
//                 .where('phoneNumber', isEqualTo: formattedPhoneNumber)
//                 .where('password', isEqualTo: _passwordController.text)
//                 .get();
//
//         if (userSnapshot.docs.isNotEmpty) {
//           await FirebaseAuth.instance.verifyPhoneNumber(
//             phoneNumber: formattedPhoneNumber,
//             verificationCompleted: (PhoneAuthCredential credential) async {
//               await FirebaseAuth.instance.signInWithCredential(credential);
//               _showSnackBar(context, 'Connexion réussie !');
//               Navigator.pushReplacementNamed(context, '/home');
//             },
//             verificationFailed: (FirebaseAuthException e) {
//               print('Erreur OTP : ${e.message}');
//               showMessageDialog(
//                 context,
//                 title: "Erreur",
//                 widget: Padding(
//                   padding: const EdgeInsets.all(10.0),
//                   child: AppText(
//                     textAlign: TextAlign.center,
//                     text: ('OTP invalide. Veuillez réessayer.'),
//                   ),
//                 ),
//                 isConfirmation: false,
//                 isSale: false,
//               );
//               setState(() => isLoading = false);
//             },
//             codeSent: (String verificationId, int? resendToken) {
//               _showSnackBar(context, 'OTP envoyé avec succès !');
//               setState(() => isLoading = false);
//               showModalBottomSheet(
//                 context: context,
//                 isScrollControlled: true,
//                 builder: (BuildContext context) {
//                   return VerificationOTPPage(
//                     phoneNumber: formattedPhoneNumber,
//                     verificationId: verificationId,
//                     password: _passwordController.text,
//                     isSignUp: false,
//                     fcmToken: fcmToken ?? '',
//                   );
//                 },
//               );
//             },
//             codeAutoRetrievalTimeout: (String verificationId) {
//               _showSnackBar(context, 'Le délai pour entrer l\'OTP a expiré.');
//             },
//           );
//         } else {
//           showMessageDialog(
//             context,
//             title: "Erreur",
//             widget: Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: AppText(
//                 textAlign: TextAlign.center,
//                 text:
//                     ('Vauillez verifier vos information vu qu\'ils sont  incorrectes.'),
//               ),
//             ),
//             isConfirmation: false,
//             isSale: false,
//           );
//           setState(() => isLoading = false);
//         }
//       } catch (e) {
//         showMessageDialog(
//           context,
//           title: "Erreur",
//           widget: Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: AppText(
//                 textAlign: TextAlign.center,
//                 text: 'Erreur lors de l\'envoi de l\'OTP.'),
//           ),
//           isConfirmation: false,
//           isSale: false,
//         );
//         print('Erreur lors de la vérification : $e');
//         setState(() => isLoading = false);
//       }
//     } else {
//       showMessageDialog(
//         context,
//         title: "Erreur",
//         widget: Padding(
//           padding: const EdgeInsets.all(10.0),
//           child: AppText(
//               textAlign: TextAlign.center,
//               text: 'Veuillez compléter vos informations au complet.'),
//         ),
//         isConfirmation: false,
//         isSale: false,
//       );
//       setState(() => isLoading = false);
//     }
//   }
//
//   void _showSnackBar(BuildContext context, String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         duration: Duration(seconds: 2),
//       ),
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
//                     keyboardType: TextInputType.none,
//                     placeholder: 'Phone Number',
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
//               text: translate("Vous n'avez pas de compte ?"),
//               color: Theme.of(context).colorScheme.inverseSurface,
//             ),
//             Spacer(),
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 showModalBottomSheet(
//                   context: context,
//                   isScrollControlled: true,
//                   builder: (BuildContext context) {
//                     return SignupPage();
//                   },
//                 );
//               },
//               child: AppText(
//                 text: translate("S'inscrire"),
//                 color: Theme.of(context).colorScheme.onSecondary,
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
//         AppTextLarge(
//           text: 'Entrez votre code secret',
//           size: 25,
//           textAlign: TextAlign.center,
//         ),
//         sizedbox,
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
//             _sendOTP();
//           },
//           child: isLoading
//               ? CupertinoActivityIndicator(color: Colors.white)
//               : AppText(text: "Continuer.", color: Colors.white),
//         ),
//       ],
//     );
//   }
// }
