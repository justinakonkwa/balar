// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api

import 'package:balare/authantification/login_page.dart';
import 'package:balare/authantification/main_page.dart';
import 'package:balare/firebase_options.dart';
import 'package:balare/intro/Intro.dart';
import 'package:balare/pages/home_page.dart';
import 'package:balare/mainpage.dart';
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

  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    print("Error initializing Firebase: $e");
    // Optionally, handle the error further, such as showing an error screen or fallback behavior
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? savedLanguage = prefs.getString('language');

  var delegate = await LocalizationDelegate.create(
    fallbackLocale: 'fr',
    supportedLocales: ['fr', 'ln', 'sw', 'ts', 'kik'],
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
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              DefaultCupertinoLocalizations.delegate,
            ],
            supportedLocales: [
              const Locale('fr', ''), // Français
              const Locale('lng', ''), // Lingala
              const Locale('sw', ''), // Swahili
              const Locale('tsh', ''), // Tshiluba
              const Locale('kg', ''), // Kikongo
            ],
            locale: localizationDelegate.currentLocale,
            theme: provider.themeData,
            debugShowCheckedModeBanner: false,
            initialRoute: '/verification',
            routes: {
              '/intro': (context) => Intro(),
              '/home': (context) => HomePage(),
              '/auth': (context) => LoginPage(),
              '/main': (context) => MainPage(),
              '/verification': (context) => AuthVerification(),
            },
          );
        },
      ),
    );
  }
}
