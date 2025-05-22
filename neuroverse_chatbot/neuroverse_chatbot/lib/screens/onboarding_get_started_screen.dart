// lib/screens/onboarding_get_started_screen.dart

import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import 'terms_screen.dart';

class OnboardingGetStartedScreen extends StatelessWidget {
  const OnboardingGetStartedScreen({Key? key}) : super(key: key);

  Future<void> _confirmAndOpenTerms(BuildContext context) async {
    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leaving App'),
        content: const Text(
          'You’re about to view our Terms & Conditions. Proceed?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true),  child: const Text('Proceed')),
        ],
      ),
    );
    if (proceed == true) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF28C28),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ↑↑↑ Increase this to push everything down
              const SizedBox(height: 200),

              // White-dots design
              Image.asset(
                'assets/images/background.png',
                width: 40,
                height: 40,
              ),

              const SizedBox(height: 100),

              // Quote
              const Text(
                '“In the midst of winter, I found there was within me an invincible summer.”',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w600,
                  fontSize: 36,
                  height: 44 / 36,
                  letterSpacing: -1.2,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 25),

              // Author
              const Text(
                '—  ALBERT CAMUS',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 140),

              // Get Started
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Centered Terms & Conditions
              Center(
                child: GestureDetector(
                  onTap: () => _confirmAndOpenTerms(context),
                  child: const Text(
                    'Terms & Conditions',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
