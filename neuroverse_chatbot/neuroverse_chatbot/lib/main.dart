import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:neuroverse_chatbot/services/firebase_options.dart'; // updated import

import 'screens/signup_screen.dart';
import 'screens/terms_screen.dart';
import 'screens/appointment_screen.dart';
import 'screens/admin_home_screen.dart';
import 'screens/onboarding_get_started_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/login_signup_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'screens/admin_home_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(NeuroVerseApp());
}

class NeuroVerseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NeuroVerse Chatbot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Arial',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/get-started': (context) => OnboardingGetStartedScreen(),     
        '/welcome': (context) => WelcomeScreen(), 
        '/login': (context) => LoginSignupScreen(),      
        '/home': (context) => HomeScreen(),  
        '/signup': (context) => SignupScreen(),
        '/terms': (context) => TermsScreen(),
        '/appointments': (context) => AppointmentScreen(),
        '/admin': (context) => AdminHomeScreen(),
        
      },
    );
  }
}