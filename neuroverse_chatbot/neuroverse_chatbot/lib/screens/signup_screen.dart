import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_signup_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _firstNameError = false;
  bool _lastNameError = false;
  bool _emailError = false;
  bool _passwordError = false;
  bool _confirmPasswordError = false;
  String _passwordMessage = '';

  late ConfettiController _controllerCenter;

  @override
  void initState() {
    super.initState();
    _controllerCenter = ConfettiController(duration: const Duration(seconds: 2));
    _confirmPasswordController.addListener(_checkPasswordMatch);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _controllerCenter.dispose();
    super.dispose();
  }

  void _checkPasswordMatch() {
    setState(() {
      if (_confirmPasswordController.text == _passwordController.text) {
        _passwordMessage = 'Passwords match ✅';
      } else {
        _passwordMessage = 'Passwords do not match ❌';
      }
    });
  }

  Future<void> _signupUser() async {
  final firstName = _firstNameController.text.trim();
  final lastName = _lastNameController.text.trim();
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();
  final confirmPassword = _confirmPasswordController.text.trim();

  setState(() {
    _firstNameError = firstName.isEmpty;
    _lastNameError = lastName.isEmpty;
    _emailError = email.isEmpty;
    _passwordError = password.isEmpty;
    _confirmPasswordError = confirmPassword.isEmpty;
  });

  if (_firstNameError || _lastNameError || _emailError || _passwordError || _confirmPasswordError) {
    _showSnackBar('Please fill all fields.', ContentType.warning);
    return;
  }

  if (password != confirmPassword) {
    _showSnackBar('Oops! Passwords do not match.', ContentType.failure);
    return;
  }

  try {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;

    // ✅ Firebase Authentication (create user)
    UserCredential userCred = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final userId = userCred.user!.uid;

    // ✅ Store user details (excluding password ideally)
    await firestore.collection('users').doc(userId).set({
      'fullName': '$firstName $lastName',
      'email': email,
      'password': password,  
      'role': email == 'admin@nverse.com' ? 'admin' : 'user',
      'createdAt': Timestamp.now(),
    });

    _controllerCenter.play();
    _showSnackBar('Account created successfully!', ContentType.success);

    await Future.delayed(const Duration(seconds: 2));
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginSignupScreen()),
      (route) => false,
    );
  } catch (e) {
    _showSnackBar('Signup failed. ${e.toString()}', ContentType.failure);
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
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  const Text(
                    'Create Account',
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
                        _buildField(_firstNameController, 'First Name', Icons.person, _firstNameError),
                        const SizedBox(height: 12),
                        _buildField(_lastNameController, 'Last Name', Icons.person, _lastNameError),
                        const SizedBox(height: 12),
                        _buildField(_emailController, 'Email', Icons.email, _emailError),
                        const SizedBox(height: 12),
                        _buildPasswordField(_passwordController, 'Password', _passwordError),
                        const SizedBox(height: 12),
                        _buildPasswordField(_confirmPasswordController, 'Confirm Password', _confirmPasswordError),
                        const SizedBox(height: 8),
                        Text(
                          _passwordMessage,
                          style: TextStyle(
                            color: _passwordMessage.contains('match') ? Colors.green : Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _signupUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryTeal,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'SIGN UP',
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: primaryTeal),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _controllerCenter,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: [primaryTeal, Colors.tealAccent, Colors.greenAccent],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String hint, IconData icon, bool error) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF317773)),
        errorText: error ? 'Required Field' : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: error ? Colors.red : Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String hint, bool error) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        prefixIcon: const Icon(Icons.lock, color: Color(0xFF317773)),
        errorText: error ? 'Required Field' : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: error ? Colors.red : Colors.grey.shade300),
        ),
      ),
    );
  }
}
