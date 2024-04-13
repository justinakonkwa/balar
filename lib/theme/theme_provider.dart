import 'package:balare/theme/Theme_preference.dart';
import 'package:balare/theme/theme.dart';
import 'package:flutter/material.dart';


class ThemeProvider extends ChangeNotifier{
  ThemePreferences themePreferences = ThemePreferences();
  bool currentTheme = false;

  ThemeData get themeData {
    if(currentTheme){
      return  darkMode;
    }else{
      return lightMode;
    }
  }

  changeTheme(bool value) async {
    await themePreferences.setTheme(value);
    currentTheme = value;
    notifyListeners();
  }

  initializeTheme() async{
    currentTheme =await themePreferences.getTheme();
    notifyListeners();
  }


}




