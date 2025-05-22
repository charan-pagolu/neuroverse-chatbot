// welcome_screen.dart

import 'package:flutter/material.dart';
import 'welcome_content.dart';

import 'login_signup_screen.dart';

final List<Map<String, String>> welcomeData = [
  {
    "image": "assets/images/welcome_step1.png",
    "title": "",
  },
  {
    "image": "assets/images/welcome_step2.png",
    "title": "I",
  },
  {
    "image": "assets/images/welcome_step3.png",
    "title": "",
  },
  {
    "image": "assets/images/welcome_step4.png",
    "title": "",
  },
];

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int currentPage = 0;
  final PageController _pageController = PageController();

  void nextPage() {
    if (currentPage < welcomeData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginSignupScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: welcomeData.length,
        onPageChanged: (index) {
          setState(() {
            currentPage = index;
          });
        },
        itemBuilder: (context, index) => WelcomeContent(
          image: welcomeData[index]['image']!,
          title: welcomeData[index]['title']!,
          onNextPressed: nextPage,
        ),
      ),
    );
  }
}
