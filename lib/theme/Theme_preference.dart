// ignore_for_file: file_names, constant_identifier_names

import 'package:shared_preferences/shared_preferences.dart';

class ThemePreferences {
  static const THEME_STATUS = "Theme_status";

  setTheme(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(THEME_STATUS, value);
  }

   Future<bool> getTheme() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(THEME_STATUS)?? false;
  }
}