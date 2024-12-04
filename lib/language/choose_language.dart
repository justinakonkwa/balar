import 'package:balare/language/language_preferences.dart';
import 'package:balare/widget/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

void showI18nDialog({required BuildContext context}) {
  showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: AppText(text:translate('language.selection.message',),textAlign: TextAlign.center,),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text(translate('language.fr')), // Français
            onTap: () {
              Navigator.pop(context, 'fr');
              setLanguagePreference('fr'); // Mettre à jour la langue
            },
          ),
          // ListTile(
          //   title: Text(translate('language.ln')), // Lingala
          //   onTap: () {
          //     Navigator.pop(context, 'ln');
          //     setLanguagePreference('ln'); // Mettre à jour la langue
          //   },
          // ),
          ListTile(
            title: Text(translate('language.sw')), // Swahili
            onTap: () {
              Navigator.pop(context, 'sw');
              setLanguagePreference('sw'); // Mettre à jour la langue
            },
          ),
          // ListTile(
          //   title: Text(translate('language.tsh')), // Tshiluba
          //   onTap: () {
          //     Navigator.pop(context, 'ts');
          //     setLanguagePreference('tsh'); // Mettre à jour la langue
          //   },
          // ),
          // ListTile(
          //   title: Text(translate('language.kik')), // Kikongo
          //   onTap: () {
          //     Navigator.pop(context, 'kik');
          //     setLanguagePreference('kg'); // Mettre à jour la langue
          //   },
          // ),
        ],
      ),
      actions: [],
    ),
  ).then((String? value) {
    if (value != null) changeLocale(context, value);
  });
}

// Exemple de la fonction setLanguagePreference
void setLanguagePreference(String languageCode) {
  // Enregistrez le code de langue sélectionné dans les préférences
  // Implémentez votre logique d'enregistrement ici
}
