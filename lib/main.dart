// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api

import 'package:balare/authantification/authent_page.dart';
import 'package:balare/firebase_options.dart';
import 'package:balare/intro/Intro.dart';
import 'package:balare/pages/home_page.dart';
import 'package:balare/pages/mainpage.dart';
import 'package:balare/theme/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:balare/language/language_preferences.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
 // Add this line

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  SharedPreferences prefs = await SharedPreferences.getInstance();

  String? savedLanguage = prefs.getString('language');

  var delegate = await LocalizationDelegate.create(
    fallbackLocale: 'en_US',
    supportedLocales: [
      'en_US',
      'fr',
    ],
    preferences: TranslatePreferences(savedLanguage),
  );

  runApp(
    ChangeNotifierProvider<ThemeProvider>(
      create: (context) => ThemeProvider()..initializeTheme(),
      child: LocalizedApp(
        delegate,
        const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    var localizationDelegate = LocalizedApp.of(context).delegate;
    return LocalizationProvider(
      state: LocalizationProvider.of(context).state,
      child: Consumer<ThemeProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            localizationsDelegates: const  [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              DefaultCupertinoLocalizations.delegate,
            ],
            supportedLocales: localizationDelegate.supportedLocales,
            locale: localizationDelegate.currentLocale,
            theme: provider.themeData,
            debugShowCheckedModeBanner: false,
            initialRoute: '/main',
            routes: {
              '/intro': (context) => Intro(),
              '/home': (context) => HomePage(),
              '/auth':(context)=> AuthantPage(),
              '/main': (context)=> MainPage(),
            },
          );
        },
      ),
    );
  }
}
