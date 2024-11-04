// ignore_for_file: prefer_const_constructors

import 'package:balare/pages/chat.dart';
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
    ChatPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor:Theme.of(context).colorScheme.background,
      body: _widgetOptions.elementAt(currentIndex),
      bottomNavigationBar: Container(
        child: BottomNavigationBar(
          backgroundColor:             Theme.of(context).colorScheme.background,

        selectedItemColor: Theme.of(context).colorScheme.onBackground,
          elevation: 10,
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
                CupertinoIcons.chat_bubble_2,
              ),
              label: ('Chat'),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                CupertinoIcons.person,
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
