// lib/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'dart:async';
import 'onboarding_get_started_screen.dart'; // updated screen to go next

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 7), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingGetStartedScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'appLogoHero',
              child: Image.asset(
                'assets/images/app_logo.png',
                width: 120,
                height: 120,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'NeuroVerse',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
