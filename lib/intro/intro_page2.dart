// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers, sized_box_for_whitespace


import 'package:balare/widget/app_text.dart';
import 'package:balare/widget/app_text_large.dart';
import 'package:flutter/material.dart';


class IntroPage2 extends StatelessWidget {
  const IntroPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).size.height * 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.47,
              width: 400,
              child: Center(
                child: Image.asset('assets/intro1.png'),
              ),
            ),
            AppTextLarge(
                text: 'Analyse Quotidienne',color: Theme.of(context).colorScheme.onBackground ),

          SizedBox(height: 40),
            AppText(
              textAlign: TextAlign.center,
              text:
                  ' Gardez une Vue Claire sur Votre Stock et les Dates d\'Expiration des Médicaments'
            )
          ],
        ),
      ),
    );
  }
}

class TypewriterAnimation extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration duration;

  TypewriterAnimation({
    required this.text,
    required this.style,
    required this.duration,
  });

  @override
  _TypewriterAnimationState createState() => _TypewriterAnimationState();
}

class _TypewriterAnimationState extends State<TypewriterAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _textAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _textAnimation = IntTween(begin: 0, end: widget.text.length)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _textAnimation,
      builder: (context, child) {
        String animatedText = widget.text.substring(0, _textAnimation.value);

        return Text(
          animatedText,
          style: widget.style,
        );
      },
    );
  }
}
