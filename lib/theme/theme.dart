// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    background:Color(0xfff5f5f5),
    onBackground:Color(0xff272829),
    primary: Colors.green.shade900,
    inversePrimary: Color(0xffeeeaea),
    secondary: Colors.green.shade900,
    onSecondary: Color(0xff272829)
  ),
  appBarTheme: AppBarTheme(
    elevation: 0,
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    background: Color(0xff272829),
    onBackground:Color(0xfff5f5f5),
    primary:Colors.green,
    inversePrimary: Color(0xff363535),
    secondary: Colors.green,
    onSecondary: Color(0xfff5f5f5),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
  ),
);