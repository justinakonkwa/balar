import 'package:balare/Modeles/user_modele/user_modele.dart';
import 'package:balare/widget/Keyboard_widget.dart';
import 'package:balare/widget/app_text.dart';
import 'package:balare/widget/app_text_large.dart';
import 'package:balare/widget/bouton_next.dart';
import 'package:balare/widget/constantes.dart';
import 'package:balare/widget/message_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class VerificationOTPPage extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  // final String name;
  final String password;
  final bool isSignUp;
  final String fcmToken;

  VerificationOTPPage({
    required this.phoneNumber,
    required this.verificationId,
    // required this.name,
    required this.password,
    required this.isSignUp,
    required this.fcmToken,
  });
  _VerificationOTPPageState createState() => _VerificationOTPPageState();
}

class _VerificationOTPPageState extends State<VerificationOTPPage> {
  final TextEditingController _otpController = TextEditingController();
  bool isLoading = false;

  Future<void> _verifyOTP() async {
    setState(() {
      isLoading = true;
    });

    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: widget.verificationId,
      smsCode: _otpController.text,
    );

    try {
      UserCredential authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);
      if (widget.isSignUp) {
        UserManager user = UserManager(
            uid: authResult.user!.uid,
            // name: widget.name,
            phoneNumber: widget.phoneNumber,
            password: widget.password,
            fcmToken: widget.fcmToken);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(authResult.user!.uid)
            .set(user.toMap());
      }
      Navigator.pushReplacementNamed(context, '/verification');
    } catch (e) {
      print('Erreur pendant la connexion : $e');

      showMessageDialog(
        context,
        title: "Erreur",
        widget: Padding(
          padding: const EdgeInsets.all(10.0),
          child: AppText(
              textAlign: TextAlign.center,
              text: 'Code OTP invalide. Veuillez réessayer.'),
        ),
        isConfirmation: false,
        isSale: false,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppText(
              text: 'Saisi  l\'OTP envoyé a ce numéro ${widget.phoneNumber}',
              color: Theme.of(context).colorScheme.onBackground,
            ),
            sizedbox,
            sizedbox,
            const SizedBox(height: 20),
            Pinput(
              keyboardType: TextInputType.none,
              length: 6,
              controller: _otpController,
              onCompleted: (String pin) async {},
            ),
            sizedbox,
            sizedbox,
            CustomKeyboard(
              onTextInput: (value) {
                _otpController.text += value;
              },
              onBackspace: () {
                if (_otpController.text.isNotEmpty) {
                  _otpController.text = _otpController.text
                      .substring(0, _otpController.text.length - 1);
                }
              },
            ),
            const SizedBox(height: 20),
            NextButton(
              width: double.infinity,
              onTap: _verifyOTP,
              child: isLoading
                  ? CupertinoActivityIndicator(color: Colors.white)
                  : AppText(text: "VALIDER", color: Colors.white),
            ),
          ],
        ),
      ),
    ));
  }
}

//
// // // ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors, prefer_const_constructors, use_build_context_synchronously
//
// import 'package:balare/Modeles/user_modele/user_modele.dart';
// import 'package:balare/widget/app_text.dart';
// import 'package:balare/widget/app_text_large.dart';
// import 'package:balare/widget/bouton_next.dart';
// import 'package:balare/widget/message_widget.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// import 'package:pinput/pinput.dart';
//
// // import 'package:cloud_firestore/cloud_firestore.dart';
//
// class VerificationOTPPage extends StatefulWidget {
//   final String phoneNumber;
//   final String verificationId;
//   final String name;
//   final String password;
//   final bool isSignUp;
//   final String fcmToken;
//
//   VerificationOTPPage({
//     required this.phoneNumber,
//     required this.verificationId,
//     required this.name,
//     required this.password,
//     required this.isSignUp, required this.fcmToken,
//   });
//
//   @override
//   _VerificationOTPPageState createState() => _VerificationOTPPageState();
// }
//
// class _VerificationOTPPageState extends State<VerificationOTPPage> {
//   final TextEditingController _otpController = TextEditingController();
//   bool isLoading = false;
//
//   Future<void> _verifyOTP() async {
//     setState(() {
//       isLoading = true;
//     });
//
//     PhoneAuthCredential credential = PhoneAuthProvider.credential(
//       verificationId: widget.verificationId,
//       smsCode: _otpController.text,
//     );
//
//     try {
//       UserCredential authResult =
//       await FirebaseAuth.instance.signInWithCredential(credential);
//       if (widget.isSignUp) {
//         UserManager user = UserManager(
//             uid: authResult.user!.uid,
//             name: widget.name,
//             phoneNumber: widget.phoneNumber,
//             password: widget.password,
//             fcmToken: widget.fcmToken
//         );
//
//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(authResult.user!.uid)
//             .set(user.toMap());
//       }
//       Navigator.pushReplacementNamed(context, '/home');
//     } catch (e) {
//       print('Erreur pendant la connexion : $e');
//
//       showMessageDialog(
//         context,
//         title: "Erreur",
//         widget: Padding(
//           padding: const EdgeInsets.all(10.0),
//           child: AppText(
//               textAlign: TextAlign.center,
//               text: 'Code OTP invalide. Veuillez réessayer.'),
//         ),
//         isConfirmation: false, isSale: false,
//       );
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: MediaQuery.of(context).size.height * 0.4,
//       decoration: BoxDecoration(
//         border: Border.all(
//           color: Theme.of(context).colorScheme.primary,
//           width: 2.0,
//         ),
//         borderRadius: BorderRadius.circular(20),
//         color: Theme.of(context).colorScheme.background,
//       ),
//       child: Padding(
//         padding: const EdgeInsets.only(left: 20, right: 20, bottom: 50),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Container(
//               margin: EdgeInsets.only(top: 10),
//               height: 10,
//               width: 80,
//               decoration: BoxDecoration(
//                 border: Border.all(
//                   color: Theme.of(context).colorScheme.primary,
//                   width: 2.0,
//                 ),
//                 borderRadius: BorderRadius.circular(8.0),
//               ),
//             ),
//             Row(
//               children: [
//                 AppTextLarge(
//                   text: 'VALIDER OTP',
//                   color: Theme.of(context).colorScheme.onBackground,
//                   size: 14,
//                 ),
//                 Spacer(),
//                 IconButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                   icon: Icon(
//                     Icons.close,
//                     color: Colors.red,
//                     size: 30,
//                   ),
//                 )
//               ],
//             ),
//             SizedBox(height: 20),
//             AppText(
//               text: 'Envoi de l\'OTP à ${widget.phoneNumber}',
//               color: Theme.of(context).colorScheme.onBackground,
//             ),
//             SizedBox(height: 20),
//             Pinput(
//               length: 6,
//               controller: _otpController,
//               onCompleted: (String pin) async {
//                 _verifyOTP();
//               },
//             ),
//             Spacer(),
//             NextButton(
//               width: double.infinity,
//               onTap: _verifyOTP,
//               child: isLoading
//                   ? CupertinoActivityIndicator(color: Colors.white)
//                   : AppText(text: "VALIDER", color: Colors.white),
//             ),
//             SizedBox(height: 20),
//             Row(
//               children: [
//                 AppText(
//                   text: "je n'ai pas reçu l'OTP",
//                   color: Theme.of(context).colorScheme.onBackground,
//                 ),
//                 Spacer(),
//                 AppTextLarge(
//                   text: "renvoyer",
//                   color: Colors.black,
//                   size: 14,
//                 ),
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
