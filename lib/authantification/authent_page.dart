import 'package:balare/authantification/login_page.dart';
import 'package:balare/authantification/signup_page.dart';
import 'package:balare/widget/app_text.dart';
import 'package:balare/widget/bouton_next.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class AuthantPage extends StatefulWidget {
  const AuthantPage({super.key});

  @override
  State<AuthantPage> createState() => _AuthantPageState();
}

class _AuthantPageState extends State<AuthantPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 50, left: 20, right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Expanded(
                child: Center(
                  child: Icon(
                    CupertinoIcons.square_stack_3d_down_right,
                    size: 350,
                  ),
                ),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      NextButton(
                        onTap: () {
                          showModalBottomSheet(
                            backgroundColor:
                                Theme.of(context).colorScheme.background,
                            context: context,
                            isScrollControlled: true,
                            builder: (BuildContext context) {
                              return const LoginPage();
                            },
                          );
                        },
                        color: Colors.transparent,
                        child: AppText(
                          text: 'SE CONNECTER',
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      NextButton(
                        onTap: () {
                          showModalBottomSheet(
                            backgroundColor:
                                Theme.of(context).colorScheme.background,
                            context: context,
                            isScrollControlled: true,
                            builder: (BuildContext context) {
                              return const SignUpPage();
                            },
                          );
                        },
                        child: AppText(
                          text: 'CREE COMPTE',
                          color:  Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
