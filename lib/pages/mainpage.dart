// ignore_for_file: prefer_const_constructors

import 'package:balare/pages/expenses_page.dart';
import 'package:balare/pages/home_page.dart';
import 'package:balare/pages/income_page.dart';
import 'package:balare/pages/user_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    IncomePage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(currentIndex),
      bottomNavigationBar: Container(
        // decoration: BoxDecoration(
        //   border: Border(
        //     top: BorderSide(
        //       color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
        //       width: 1,
        //     ),
        //   ),
        // ),
        child: BottomNavigationBar(
          backgroundColor: Colors.black38,
          selectedItemColor: Theme.of(context).colorScheme.onBackground,
          elevation: 0,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          currentIndex: currentIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(
                CupertinoIcons.house_alt,
              ),
              label: ('Home'),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                CupertinoIcons.cart,
              ),
              label: ('Income'),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                CupertinoIcons.settings,
              ),
              label: ('Profil'),
            ),
          ],
          onTap: (index) {
            setState(
              () {
                currentIndex = index;
              },
            );
          },
        ),
      ),
    );
  }
}
