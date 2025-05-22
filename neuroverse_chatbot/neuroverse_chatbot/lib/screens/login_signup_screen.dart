import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'home_screen.dart';
import 'signup_screen.dart';


class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({Key? key}) : super(key: key);

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _emailError = false;
  bool _passwordError = false;

  Future<void> _loginUser() async {
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();

  setState(() {
    _emailError = email.isEmpty;
    _passwordError = password.isEmpty;
  });

  if (_emailError || _passwordError) {
    _showSnackBar('Please fill in all required fields.', ContentType.warning);
    return;
  }

  try {
    final auth = FirebaseAuth.instance;

    // ✅ Try to sign in using Firebase Authentication
    await auth.signInWithEmailAndPassword(email: email, password: password);

    _showSnackBar('Login Successful! 🎉', ContentType.success);
    await Future.delayed(const Duration(milliseconds: 500));

    if (email == 'admin@nverse.com') {
      Navigator.pushReplacementNamed(context, '/admin');
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  } catch (e) {
    print('Login error: $e');
    _showSnackBar('Invalid email or password.', ContentType.failure);
  }
}


  void _showSnackBar(String message, ContentType type) {
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      duration: const Duration(seconds: 3),
      content: AwesomeSnackbarContent(
        title: type == ContentType.success ? 'Success!' : 'Oops!',
        message: message,
        contentType: type,
        color: type == ContentType.success ? const Color(0xFF317773) : Colors.redAccent,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF317773);

    return Scaffold(
      backgroundColor: const Color(0xFFE5EAD7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              const SizedBox(height: 50),
              Hero(
                tag: 'appLogoHero',
                child: Image.asset('assets/images/app_logo.png', height: 100),
              ),
              const SizedBox(height: 16),
              const Text(
                'Welcome to NeuroVerse',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: primaryTeal,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildField(
                      controller: _emailController,
                      hint: 'Email',
                      prefix: Icons.email,
                      error: _emailError,
                    ),
                    const SizedBox(height: 20),
                    _buildField(
                      controller: _passwordController,
                      hint: 'Password',
                      prefix: Icons.lock,
                      obscure: true,
                      error: _passwordError,
                      suffix: Icons.visibility,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Forgot Email/Password?',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 14,
                            color: primaryTeal,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _loginUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryTeal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'LOGIN',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Urbanist',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SignupScreen()),
                          );
                        },
                        child: const Text(
                          'New here? Create an account',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontFamily: 'Urbanist',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: primaryTeal,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData prefix,
    bool obscure = false,
    IconData? suffix,
    bool error = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(fontFamily: 'Urbanist', fontSize: 16),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        hintStyle: const TextStyle(fontFamily: 'Urbanist'),
        prefixIcon: Icon(prefix, color: const Color(0xFF317773)),
        suffixIcon: suffix != null
            ? Icon(suffix, color: const Color(0xFF317773))
            : null,
        errorText: error ? 'Required Field' : null,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: error ? Colors.red : Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: error ? Colors.red : Colors.grey.shade300),
        ),
      ),
    );
  }
}
