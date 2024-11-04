// import 'package:flutter/cupertino.dart';
import 'package:balare/language/language_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

void showI18nDialog({required BuildContext context}) {
  showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
            title: Text(translate('language.message')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  title: Text(translate('language.name.en')),
                  onTap: () {
                    Navigator.pop(context, 'en_US');
                    TranslatePreferences('en_US');
                  },
                ),
                ListTile(
                  title: Text(translate('language.name.fr')),
                  onTap: () {
                    Navigator.pop(context, 'fr');
                    TranslatePreferences('fr');
                  },
                ),
              ],
            ),
            actions: [],
          )).then((String? value) {
    if (value != null) changeLocale(context, value);
  });
}
