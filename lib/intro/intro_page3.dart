// ignore_for_file: avoid_unnecessary_containers

import 'package:balare/widget/app_text.dart';
import 'package:balare/widget/app_text_large.dart';
import 'package:flutter/material.dart';

class IntroPage3 extends StatelessWidget {
  const IntroPage3({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).size.height * 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.47,
              width: 400,
              child: Image.asset('assets/intro3.png'),
            ),
            AppTextLarge(
                text: 'Alertes Instantanées',
                color: Theme.of(context).colorScheme.onBackground),
            const SizedBox(height: 40),
            AppText(
              textAlign: TextAlign.center,
              text:
                  'Recevez des Alertes dès Qu\'un Médicament Expire ou Qu\'un Stock S\'épuise.',
            )
          ],
        ),
      ),
    );
  }
}
