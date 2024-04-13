// ignore_for_file: file_names

import 'dart:async';
import 'package:balare/widget/bouton_next.dart';
import 'package:flutter/material.dart';
import 'package:balare/widget/app_text.dart';

import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'intro_page1.dart';
import 'intro_page2.dart';
import 'intro_page3.dart';

class Intro extends StatefulWidget {
  const Intro({super.key});

  @override
  State<Intro> createState() => _IntroState();
}

class _IntroState extends State<Intro> {
  final PageController _controller = PageController(initialPage: 0);

  int _currentPage = 0;
  bool last = false;
  Timer? _timer;
  // void _startTimer() {
  //   Timer.periodic(const Duration(seconds: 5), (timer) {
  //     if (_currentPage < 2) {
  //       _currentPage++;
  //     }
  //     _controller.animateToPage(
  //       _currentPage,
  //       duration: const Duration(milliseconds: 500),
  //       curve: Curves.easeInOut,
  //     );
  //   });
  // }
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentPage < 2) {
        _currentPage++;
        if (_controller.hasClients) {
          // Vérification ajoutée ici
          _controller.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else {
          timer
              .cancel(); // Optionnel: Arrêter le timer si le contrôleur n'a pas de client
        }
      } else {
        timer.cancel(); // Arrêter le timer si nous sommes à la dernière page
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTimer();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            scrollDirection: Axis.horizontal,
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
                last = (index == 2);
              });
            },
            children: const [
              IntroPage1(),
              IntroPage2(),
              IntroPage3(),
            ],
          ),
          Container(
            alignment: const Alignment(0, 0.75),
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20),
              child: last
                  ? NextButton(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/auth');
                      },
                      child: AppText(text: 'commencer', color: Colors.white),
                    )
                  : SizedBox(
                      child: SmoothPageIndicator(
                        controller: _controller,
                        count: 3,
                        effect: WormEffect(
                          activeDotColor: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
            ),
          )
        ],
      ),
    );
  }
}
