import 'package:balare/intro/Intro.dart';
import 'package:balare/pages/home_page.dart';
import 'package:balare/pages/mainpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class AuthVerification extends StatefulWidget {
  const AuthVerification({super.key});

  @override
  State<AuthVerification> createState() => _AuthVerificationState();
}

class _AuthVerificationState extends State<AuthVerification> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            return const MainPage();
          } else {
            return const Intro();
          }
        }),
      ),
    );
  }
}
