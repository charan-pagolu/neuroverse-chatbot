import 'package:flutter/material.dart';

class WelcomeContent extends StatefulWidget {
  final String image;
  final String title;
  final VoidCallback onNextPressed;

  const WelcomeContent({
    Key? key,
    required this.image,
    required this.title,
    required this.onNextPressed,
  }) : super(key: key);

  @override
  State<WelcomeContent> createState() => _WelcomeContentState();
}

class _WelcomeContentState extends State<WelcomeContent> {
  double _textOpacity = 0.0;
  Offset _textOffset = const Offset(0, 0.2); // start 20% below
  double _buttonOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    // Start fade+slide for text after 1 second
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _textOpacity = 1.0;
        _textOffset = Offset.zero;
      });
    });
    // Start fade-in for button after 3 seconds
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _buttonOpacity = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            widget.image,
            fit: BoxFit.cover,
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Column(
                children: [
                  const Spacer(),

                  // ✨ Fade + Slide Up Text
                  AnimatedSlide(
                    offset: _textOffset,
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOut,
                    child: AnimatedOpacity(
                      opacity: _textOpacity,
                      duration: const Duration(milliseconds: 800),
                      child: Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 6,
                              color: Colors.black45,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Fade-in Button
                  AnimatedOpacity(
                    opacity: _buttonOpacity,
                    duration: const Duration(milliseconds: 800),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: widget.onNextPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A7C59), // Calm dark green
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 6,
                        ),
                        child: const Text(
                          'Next',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
