import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chatbot_screen.dart';

class ChatBotLoaderScreen extends StatefulWidget {
  final String userId;

  const ChatBotLoaderScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<ChatBotLoaderScreen> createState() => _ChatBotLoaderScreenState();
}

class _ChatBotLoaderScreenState extends State<ChatBotLoaderScreen> {
  @override
  void initState() {
    super.initState();
    _loadMoodPattern();
  }

  Future<void> _loadMoodPattern() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('moods')
          .where('userId', isEqualTo: widget.userId)
          .orderBy('timestamp', descending: true)
          .limit(3)
          .get();

      final moods = snapshot.docs
          .map((doc) => doc['mood'] as String)
          .toList()
          .reversed
          .toList(); // Keep original order: oldest → newest

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ChatBotScreen(
              selectedMood: moods.isNotEmpty ? moods.last : 'Good',
              moodPattern: moods.isNotEmpty ? moods : ['Good', 'Good', 'Good'],
            ),
          ),
        );
      }
    } catch (e) {
      print('❌ Error loading mood pattern: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load mood pattern')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
