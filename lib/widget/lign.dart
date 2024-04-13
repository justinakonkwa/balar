import 'package:balare/widget/colors.dart';
import 'package:flutter/material.dart';

//page qui posside une class qui m'offret une ligne de separation
class Lign extends StatelessWidget {
  final double indent;
  final double endIndent;
  const Lign({Key? key, required this.indent, required this.endIndent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: Divider(
        height: 10,
        thickness: 0.5,
        indent: indent,
        endIndent: endIndent,
        color:AppColors.desactivColor,
      ),
    );
  }
}
