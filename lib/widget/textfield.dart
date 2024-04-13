import 'package:balare/widget/app_text.dart';
import 'package:balare/widget/colors.dart';
import 'package:balare/widget/constantes.dart';
import 'package:flutter/material.dart';


textfield( BuildContext context, bool model, String text, String text2, controller, double width) {
  return model
      ? Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          width: width,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.all(
              width: 1,
              color: AppColors.desactivColor,
            ),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(
              fontFamily: 'Montserrat',
            ),
            decoration: InputDecoration(
                hintText: text2,
                hintStyle: const TextStyle(
                  fontFamily: 'Montserrat',
                ),
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none),
          ),
        )
      : Container(
          alignment: Alignment.topLeft,
          width: 160,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.all(width: 1, color: Colors.grey),
          ),
          child: Row(
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  border: Border.all(width: 1, color: Colors.grey),
                ),
                child: Center(
                  child: AppText(
                    text: text,
                    color: Theme.of(context).colorScheme.onBackground,
                    size: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                width: 100,
                height: 50,
                child: TextField(
                  controller: controller,
                  style: const TextStyle(fontFamily: 'Montserrat'),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      hintText: text2,
                      hintStyle: const TextStyle(
                        fontFamily: 'Montserrat',
                      ),
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none),
                ),
              ),
            ],
          ),
        );
}
