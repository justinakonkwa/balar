import 'dart:ui';

import 'package:flutter_translate/flutter_translate.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TranslatePreferences implements ITranslatePreferences {
  final String? savedLanguage;

  TranslatePreferences(this.savedLanguage);

  Future<void> clear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('language');
  }

  @override
  Future<Locale?> getPreferredLocale() async {
    return savedLanguage != null ? Locale(savedLanguage!) : null;
  }

  @override
  Future<void> savePreferredLocale(Locale locale) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', locale.languageCode);
  }
}
