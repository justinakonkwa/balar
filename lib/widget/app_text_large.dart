import 'package:flutter/material.dart';

// class du widget qui possede le text en gras et la grande police
// ignore: must_be_immutable
class AppTextLarge extends StatelessWidget {
  AppTextLarge({
    Key? key,
    this.size = 20,
    this.color,
    this.textAlign,
    required this.text,
  }) : super(key: key);
  Color? color;
  double size;
  final String? text;
  TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text!,
      style: TextStyle(
        fontSize: size,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.bold,
        color: color,
        letterSpacing: 0,
        decoration: TextDecoration.none,
      ),
      textAlign: textAlign,
    );
  }
}
