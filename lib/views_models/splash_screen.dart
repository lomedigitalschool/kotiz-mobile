import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kotiz_app/main.dart';
import 'package:kotiz_app/views/home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.showHome});

  final bool showHome;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controllerAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _translateAnimation;

  @override
  void initState() {
    super.initState();
    _controllerAnimation = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );
    // definition de l'effet de fade
    _fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controllerAnimation,
        curve: Curves.easeInOutSine,
      ),
    );

    // definition de l' effet de rétrécissement
    _scaleAnimation = Tween(begin: 4.0, end: 1.5).animate(
      CurvedAnimation(parent: _controllerAnimation, curve: Curves.easeIn),
    );

    _translateAnimation =
        Tween<Offset>(begin: Offset(0, 0), end: Offset(0, -0.4)).animate(
          CurvedAnimation(parent: _controllerAnimation, curve: Curves.easeIn),
        );

    // lancement de l'animation
    _controllerAnimation.forward();

    Timer(Duration(seconds: 4), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => widget.showHome ? HomePage() : OnBoarding(),
        ),
      );
    });
  }

  // liberation de la mémoire

  @override
  void dispose() {
    _controllerAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Image.asset("assets/images/onBoardingLogo.png"),
          ),
        ),
      ),
    );
  }
}
