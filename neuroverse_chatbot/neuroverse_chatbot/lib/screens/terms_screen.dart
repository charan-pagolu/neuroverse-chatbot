import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        backgroundColor: const Color(0xFFF28C28),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            'Terms & Conditions\n\n'
                '1. Introduction\n'
                'Welcome to NeuroVerse. By using our mental health support platform, '
                'you agree to abide by applicable regulations (e.g. HIPAA for U.S. users)...\n\n'
                '2. Privacy & Data Security\n'
                'All personal data is handled in accordance with government health data regulations...\n\n'
                '3. Use of Service\n'
                'You confirm you are seeking support and will not use this platform for emergencies...',
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
