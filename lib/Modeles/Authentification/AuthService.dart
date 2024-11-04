import 'package:balare/authantification/service_otp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //--------------------- Fonction pour la connexion------------------

  Future<void> requestNotificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // Méthode pour récupérer le token FCM
  Future<String?> retrieveFCMToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      print('Erreur lors de la récupération du token FCM : $e');
      return null;
    }
  }

  // Méthode pour mettre à jour le token FCM dans Firestore
  Future<void> updateFCMToken(User user, String? fcmToken) async {
    if (fcmToken != null) {
      try {
        await _firestore.collection('users').doc(user.uid).update({
          'fcmToken': fcmToken,
        });
        print('Token FCM mis à jour pour l\'utilisateur ${user.uid}');
      } catch (e) {
        print('Erreur lors de la mise à jour du token FCM : $e');
      }
    }
  }

  // Vérification de la connexion internet
  Future<bool> checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Envoi de l'OTP pour l'authentification
  Future<void> sendOTP({
    required String phoneNumber,
    required String password,
    required BuildContext context,
    required Function(String verificationId) onCodeSent,
    required Function(String errorMessage) onError,
  }) async {
    try {
      QuerySnapshot<Map<String, dynamic>> userSnapshot = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .where('password', isEqualTo: password)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        await _firebaseAuth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            await _firebaseAuth.signInWithCredential(credential);
            Navigator.pushReplacementNamed(context, '/home');
          },
          verificationFailed: (FirebaseAuthException e) {
            onError('Erreur OTP : ${e.message}');
          },
          codeSent: (String verificationId, int? resendToken) {
            onCodeSent(verificationId);
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            onError('Le délai pour entrer l\'OTP a expiré.');
          },
        );
      } else {
        onError('Les informations sont incorrectes.');
      }
    } catch (e) {
      onError('Erreur lors de l\'envoi de l\'OTP.');
      print('Erreur lors de la vérification : $e');
    }
  }

  //---------------- Fonction pour la creation de compte---------------------

  Future<void> verifierNumeroDeTelephone({
    required String phoneNumber,
    required String password,
    required String countryCode,
    required BuildContext context,
    String? fcmToken,
  }) async {
    String formattedPhoneNumber = '$countryCode${phoneNumber.trim()}';

    if (password.length < 4) {
      return _showMessageDialog(
        context,
        "Erreur",
        "Mot de passe trop court. Veuillez choisir un mot de passe d'au moins 4 caractères.",
      );
    }

    bool phoneNumberExists =
        await checkIfPhoneNumberExists(formattedPhoneNumber);
    if (phoneNumberExists) {
      return _showMessageDialog(
        context,
        "Erreur",
        "Ce numéro de téléphone a déjà un compte. Veuillez vous connecter.",
      );
    }

    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: formattedPhoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _connexionAvecCredential(
              credential, password, fcmToken, context);
        },
        verificationFailed: (FirebaseAuthException e) {
          _showMessageDialog(
              context, "Erreur", "Échec de la vérification: ${e.message}");
        },
        codeSent: (String verificationId, int? resendToken) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerificationOTPPage(
                phoneNumber: formattedPhoneNumber,
                verificationId: verificationId,
                password: password,
                isSignUp: true,
                fcmToken: fcmToken ?? '',
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      _showMessageDialog(context, "Erreur",
          "Une erreur est survenue, veuillez réessayer plus tard.");
    }
  }

  Future<bool> checkIfPhoneNumberExists(String phoneNumber) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
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

  Future<void> _connexionAvecCredential(
    PhoneAuthCredential credential,
    String password,
    String? fcmToken,
    BuildContext context,
  ) async {
    try {
      UserCredential authResult =
          await _firebaseAuth.signInWithCredential(credential);

      var userMap = {
        'uid': authResult.user!.uid,
        'phoneNumber': authResult.user!.phoneNumber,
        'password': password,
        'fcmToken': fcmToken,
      };

      await _firestore
          .collection('users')
          .doc(authResult.user!.uid)
          .set(userMap);

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      print('Erreur pendant la connexion : $e');
    }
  }

  void _showMessageDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
