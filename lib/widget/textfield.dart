import 'package:balare/widget/app_text.dart';
import 'package:balare/widget/colors.dart';
import 'package:balare/widget/constantes.dart';
import 'package:flutter/material.dart';


textfield( BuildContext context,  String text,  controller, double width, Icon icon) {
  return
       Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          width: width,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.all(
              width: 1,
              color:Theme.of(context).highlightColor,
            ),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(
              fontFamily: 'Montserrat',
            ),

            decoration: InputDecoration(
                hintText: text,
                hintStyle: const TextStyle(
                  fontFamily: 'Montserrat',
                ),
                prefixIcon:icon,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none),


          ),
        );

}
