// ignore_for_file: must_be_immutable

import 'package:balare/widget/constantes.dart';
import 'package:flutter/material.dart';

class NextButton extends StatelessWidget {
  NextButton({
    super.key,
    required this.onTap,
    required this.child,
    this.color,
    double? width,
  });

  final void Function()? onTap;
  final Widget child;
  Color? color;
  double? width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        width: width,
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
          ),
          borderRadius: borderRadius,
          color: color ?? Theme.of(context).colorScheme.primary,
        ),
        padding: const EdgeInsets.all(10),
        child: child,
      ),
    );
  }
}
