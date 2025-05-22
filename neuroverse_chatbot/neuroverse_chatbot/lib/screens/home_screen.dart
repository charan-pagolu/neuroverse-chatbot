import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neuroverse_chatbot/screens/chatbot_screen.dart';
import 'package:neuroverse_chatbot/screens/dashboard_screen.dart';
import 'package:neuroverse_chatbot/screens/journal_screen.dart';
import 'package:neuroverse_chatbot/screens/profile_screen.dart';
import 'package:neuroverse_chatbot/services/mood_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  String _selectedMood = '';
  String _greeting = '';
  String _firstName = 'User';

  bool _showChatPrompt = false;
  bool _moodSelected = false;
  bool _shouldShowChatPrompt = true;

  Timer? _quoteTimer;
  int _currentQuoteIndex = 0;

  final List<Map<String, String>> _quotes = [
    {"text": "It is better to conquer yourself than to win a thousand battles", "author": "Buddha"},
    {"text": "The mind is everything. What you think you become.", "author": "Buddha"},
    {"text": "You are not your illness. You have an individual story to tell.", "author": "Julian Seifter"},
    {"text": "Your present circumstances don't determine where you can go; they merely determine where you start.", "author": "Nido Qubein"},
    {"text": "Sometimes the people around you won't understand your journey. They don't need to, it's not for them.", "author": "Joubert Botha"},
  ];

  @override
  void initState() {
    super.initState();
    _setGreeting();
    _fetchFirstName();
    _startQuoteTimer();

    if (_shouldShowChatPrompt) {
      Future.delayed(const Duration(seconds: 5), () {
        if (!_moodSelected && mounted && _shouldShowChatPrompt && _selectedIndex == 0) {
          setState(() => _showChatPrompt = true);
        }
      });
    }
  }

  @override
  void dispose() {
    _quoteTimer?.cancel();
    super.dispose();
  }

  void _setGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      _greeting = "Good Morning";
    } else if (hour < 17) {
      _greeting = "Good Afternoon";
    } else {
      _greeting = "Good Evening";
    }
  }

  void _startQuoteTimer() {
    _quoteTimer?.cancel();
    _quoteTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        setState(() {
          _currentQuoteIndex = (_currentQuoteIndex + 1) % _quotes.length;
        });
      }
    });
  }

  Future<void> _fetchFirstName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final fullName = doc['fullName'] ?? 'User';
      setState(() => _firstName = fullName.split(' ').first);
    }
  }

  void _onMoodSelected(String mood) async {
    setState(() {
      _selectedMood = mood;
      _moodSelected = true;
      _showChatPrompt = false;
      _shouldShowChatPrompt = false;
    });

    final moodService = MoodService();
    await moodService.saveMoodAndPattern(mood);
    List<String> pattern = await moodService.fetchLast3Moods();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatBotScreen(
          selectedMood: _selectedMood,
          moodPattern: pattern,
        ),
      ),
    );
  }

  void _dismissChatPrompt() {
    setState(() {
      _showChatPrompt = false;
      _shouldShowChatPrompt = false;
    });
  }

  Widget _buildMoodOption(String emoji, String label) {
    return GestureDetector(
      onTap: () => _onMoodSelected(label),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.amber.shade100,
            child: Text(emoji, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.poppins(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildMoodHomeScreen() {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset('assets/images/neuroverse_icon.png', height: 28),
                const SizedBox(width: 8),
                Text('NeuroVerse', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
              ],
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
              child: const CircleAvatar(
                backgroundImage: AssetImage('assets/images/avatar.png'),
                radius: 18,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$_greeting,\n$_firstName!', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Text('How are you feeling today?', style: GoogleFonts.poppins(fontSize: 16)),
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildMoodOption('😊', 'Good'),
                    _buildMoodOption('☹️', 'Bad'),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Text('Thought of the day', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_quotes[_currentQuoteIndex]['text'] ?? '', style: GoogleFonts.poppins(fontSize: 14)),
                          const SizedBox(height: 6),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset('assets/images/brain.png', width: 80, height: 80),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Lottie.asset('assets/images/Animation - 1745924731296.json', repeat: true),
              ),
            ],
          ),
        ),
      ),
    );
  }

  

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildMoodHomeScreen(),
      const JournalScreen(),
      const DashboardScreen(),
      ChatBotScreen(selectedMood: '', moodPattern: const []),
    ];

    return Stack(
      children: [
        Scaffold(
          body: pages[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (int index) {
              setState(() {
                _selectedIndex = index;
                _showChatPrompt = false;
              });
            },
            selectedItemColor: Colors.teal,
            unselectedItemColor: Colors.grey.shade600,
            showUnselectedLabels: true,
            showSelectedLabels: true,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Journal'),
              BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Analytics'),
              BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: 'Chatbot'),
            ],
          ),
        ),
        if (_showChatPrompt)
          Positioned(
            bottom: 70,
            right: 26,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showChatPrompt = false;
                  _shouldShowChatPrompt = false;
                  _selectedIndex = 3;
                });
              },
              child: AnimatedOpacity(
                opacity: _showChatPrompt ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: _buildChatPromptCard(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildChatPromptCard() {
    return Stack(
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 240),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                blurRadius: 8,
                offset: const Offset(0, 3),
                color: Colors.black.withOpacity(0.1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Would you like to talk about your day?", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text("Tap here to start a conversation.", style: GoogleFonts.poppins(fontSize: 12)),
            ],
          ),
        ),
        Positioned(
          top: -8,
          right: -8,
          child: GestureDetector(
            onTap: _dismissChatPrompt,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              child: const Icon(Icons.close, size: 18),
            ),
          ),
        ),
        Positioned(
          bottom: -8,
          right: 18,
          child: Transform.rotate(
            angle: 3.14159 / 4,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
