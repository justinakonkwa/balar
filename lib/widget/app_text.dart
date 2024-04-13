import 'package:flutter/material.dart';

// class du widget qui possede le text en normal et la police normale pour la plus par des texts dans l'apps
// ignore: must_be_immutable
class AppText extends StatelessWidget {
  AppText({
    Key? key,
    this.color,
    this.maxLines,
    this.textAlign,
    required this.text, this.size,
  }) : super(key: key);
  final String? text;
  Color? color;
  int? maxLines;
  TextAlign? textAlign;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return Text(
      text!,
      maxLines: maxLines,
      style: TextStyle(
        fontFamily: 'Montserrat',
        letterSpacing: 0,
        color: color,
        decoration: TextDecoration.none,
        fontWeight: FontWeight.normal,
      ),
      textAlign: textAlign,
    );
  }
}
