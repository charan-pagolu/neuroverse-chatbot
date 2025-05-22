import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class ChatBotScreen extends StatefulWidget {
  final String selectedMood;
  final List<String> moodPattern;
  const ChatBotScreen({
    super.key,
    required this.selectedMood,
    required this.moodPattern,
  });

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  String? _surveyQuestion;
  List<String> _surveyOptions = [];
  bool _isTyping = false;
  bool _showSurvey = false;
  bool _isDarkMode = false;
  bool _surveyCompleted = false;
  List<String> _songs = [];
  List<String> _titles = [];

  String getBaseUrl() {
    return kIsWeb ? 'http://localhost:5000' : 'http://10.0.2.2:5000';
  }

  bool isPositiveReason(String reason) {
    final positiveWords = [
      "good", "happy", "uplifting", "positive", "success",
      "achievement", "better", "good news", "great", "awesome"
    ];
    return positiveWords.any((word) => reason.toLowerCase().contains(word));
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _getInitialResponse();
  }

  Future<void> _getInitialResponse() async {
    setState(() => _isTyping = true);
    final url = Uri.parse('${getBaseUrl()}/chatbot-response');
    final payload = {
      "moods": widget.moodPattern,
      "name": "User",
      "time_of_day": "afternoon"
    };
    final res = await http.post(url, headers: {"Content-Type": "application/json"}, body: json.encode(payload));
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      setState(() {
        _messages.add({
          "bot": data['chatbot_response'],
          "timestamp": DateTime.now(),
        });
        _surveyQuestion = data['survey_question'];
        _surveyOptions = List<String>.from(data['survey_options'] ?? []);
        _songs = List<String>.from(data['song_links'] ?? []);
        _titles = List<String>.from(data['song_titles'] ?? []);
        _isTyping = false;
        _showSurvey = !_surveyCompleted && _surveyOptions.isNotEmpty;
      });
      _scrollToBottom();
    } else {
      _showErrorSnackBar('Failed to load initial response');
    }
  }

  Future<void> _handleSurvey(String reason) async {
    setState(() {
      _messages.add({"user": reason, "timestamp": DateTime.now()});
      _showSurvey = false;
      _surveyCompleted = true;
      _isTyping = true;
    });
    _scrollToBottom();

    if (isPositiveReason(reason)) {
      if (widget.moodPattern.isNotEmpty) {
        widget.moodPattern.removeLast();
      }
      widget.moodPattern.add("Good");
    }

    final url = Uri.parse('${getBaseUrl()}/chatbot-followup');
    final payload = {
      "message": reason,
      "mood_pattern": widget.moodPattern.join(),
      "survey_completed": true
    };
    final res = await http.post(url, headers: {"Content-Type": "application/json"}, body: json.encode(payload));
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      setState(() {
        _messages.add({
          "bot": data['chatbot_response'],
          "timestamp": DateTime.now(),
        });
        _songs = List<String>.from(data['song_links'] ?? []);
        _titles = List<String>.from(data['song_titles'] ?? []);
        if (_songs.isNotEmpty) {
          _messages.add({
            "bot": "Here are some songs that might help you 🎵",
            "timestamp": DateTime.now(),
          });
        }
        _isTyping = false;
      });
      _scrollToBottom();
    } else {
      _showErrorSnackBar('Failed to process survey response');
    }
  }

  Future<void> _sendMessage(String msg) async {
    if (msg.trim().isEmpty) return;

    if (_showSurvey) {
      setState(() {
        _showSurvey = false;
        _surveyCompleted = true;
      });
    }

    setState(() {
      _messages.add({"user": msg, "timestamp": DateTime.now()});
      _controller.clear();
      FocusScope.of(context).unfocus();
      _isTyping = true;
    });

    _scrollToBottom();

    final url = Uri.parse('${getBaseUrl()}/chatbot-followup');
    final payload = {
      "message": msg,
      "mood_pattern": widget.moodPattern.join(),
      "survey_completed": _surveyCompleted
    };

    final res = await http.post(url, headers: {"Content-Type": "application/json"}, body: json.encode(payload));
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      setState(() {
        _messages.add({
          "bot": data['chatbot_response'],
          "timestamp": DateTime.now(),
        });
        _songs = List<String>.from(data['song_links'] ?? []);
        _titles = List<String>.from(data['song_titles'] ?? []);
        if (_songs.isNotEmpty) {
          _messages.add({
            "bot": "Here are some songs that might help you 🎵",
            "timestamp": DateTime.now(),
          });
        }
        _isTyping = false;
      });
      _scrollToBottom();
    } else {
      _showErrorSnackBar('Failed to send message');
    }
  }

  void _showErrorSnackBar(String message) {
    final snackBar = SnackBar(
      content: AwesomeSnackbarContent(
        title: 'Error',
        message: message,
        contentType: ContentType.failure,
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget _buildSongRecommendations() {
    if (_songs.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recommended Songs',
            style: GoogleFonts.urbanist(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_songs.length, (index) {
              final link = _songs[index];
              final title = _titles.isNotEmpty && index < _titles.length ? _titles[index] : "Open Song";
              final videoId = Uri.tryParse(link)?.queryParameters['v'];
              return GestureDetector(
                onTap: () => launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _isDarkMode ? Colors.grey[800] : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (videoId != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            "https://img.youtube.com/vi/$videoId/0.jpg",
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          title,
                          style: GoogleFonts.urbanist(
                            fontSize: 14,
                            color: _isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isUser, DateTime timestamp) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            decoration: BoxDecoration(
              color: isUser
                  ? (_isDarkMode ? Colors.deepPurple[700] : Colors.deepPurple[400])
                  : (_isDarkMode ? Colors.grey[800] : Colors.grey[200]),
              borderRadius: BorderRadius.circular(20).copyWith(
                topLeft: isUser ? const Radius.circular(20) : const Radius.circular(4),
                topRight: isUser ? const Radius.circular(4) : const Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              text,
              style: GoogleFonts.urbanist(
                fontSize: 16,
                color: isUser
                    ? Colors.white
                    : (_isDarkMode ? Colors.white : Colors.black87),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              DateFormat('hh:mm a').format(timestamp),
              style: GoogleFonts.urbanist(
                fontSize: 12,
                color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurveyButtons() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_surveyQuestion != null)
            Text(
              _surveyQuestion!,
              style: GoogleFonts.urbanist(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _surveyOptions.map((option) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isDarkMode ? Colors.deepPurple[600] : Colors.deepPurple[100],
                  foregroundColor: _isDarkMode ? Colors.white : Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  elevation: 0,
                ),
                onPressed: () => _handleSurvey(option),
                child: Text(
                  option,
                  style: GoogleFonts.urbanist(fontSize: 14),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return _isTyping
        ? Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Lottie.asset(
                  'assets/images/Animation - 1745924731296.json',
                  width: 50,
                  height: 50,
                ),
                const SizedBox(width: 8),
                Text(
                  'Typing...',
                  style: GoogleFonts.urbanist(
                    fontSize: 14,
                    color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          )
        : const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final theme = _isDarkMode
        ? ThemeData.dark().copyWith(
            primaryColor: Colors.deepPurple,
            scaffoldBackgroundColor: Colors.grey[900],
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
          )
        : ThemeData.light().copyWith(
            primaryColor: Colors.deepPurple,
            scaffoldBackgroundColor: Colors.grey[50],
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
          );
    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Icon(Icons.smart_toy_rounded, size: 30),
              const SizedBox(width: 8),
              Text(
                'NeuroVerse Chatbot',
                style: GoogleFonts.urbanist(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
              tooltip: 'Toggle Theme',
            ),
          ],
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isDarkMode
                    ? [Colors.deepPurple.shade900, Colors.purple.shade800]
                    : [Colors.deepPurple.shade400, Colors.purple.shade300],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Scrollbar(
                    controller: _scrollController,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: _messages.length + (_showSurvey ? 1 : 0) + 1 + (_isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (_showSurvey && index == _messages.length) {
                          return _buildSurveyButtons();
                        }
                        if (index == _messages.length + (_showSurvey ? 1 : 0)) {
                          return _buildSongRecommendations();
                        }
                        if (_isTyping && index == _messages.length + (_showSurvey ? 1 : 0) + 1) {
                          return _buildTypingIndicator();
                        }
                        final msg = _messages[index];
                        final isUser = msg.containsKey("user");
                        final text = isUser ? msg['user'] ?? "" : msg['bot'] ?? "";
                        final timestamp = msg['timestamp'] as DateTime? ?? DateTime.now();
                        return _buildChatBubble(text, isUser, timestamp);
                      },
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _isDarkMode ? Colors.grey[850] : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          style: GoogleFonts.urbanist(fontSize: 16),
                          decoration: InputDecoration(
                            hintText: 'Type your message...',
                            hintStyle: GoogleFonts.urbanist(
                              color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: _isDarkMode ? Colors.grey[800] : Colors.grey[100],
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FloatingActionButton(
                        onPressed: () => _sendMessage(_controller.text),
                        backgroundColor: Colors.deepPurple,
                        mini: true,
                        child: const Icon(Icons.send, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}