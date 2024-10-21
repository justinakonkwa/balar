// ignore_for_file: prefer_const_constructors

import 'package:balare/widget/app_text.dart';
import 'package:balare/widget/app_text_large.dart';
import 'package:flutter/material.dart';


class IntroPage1 extends StatelessWidget {
  const IntroPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
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
              child: Image.asset('assets/splash1.png'),
            ),
            AppTextLarge(
              text: 'Manage your money',color: Theme.of(context).colorScheme.onBackground,
            ),
             SizedBox(height: 40),
             AppText(
              textAlign: TextAlign.center,
              text:
                  'Stop wondering where your money goes, let Money AI crunch the numbers, focus on living your life.',
          
            )
          ],
        ),
      ),
    );
  }
}
