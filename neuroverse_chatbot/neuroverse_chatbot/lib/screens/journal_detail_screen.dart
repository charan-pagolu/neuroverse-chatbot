import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class JournalDetailScreen extends StatefulWidget {
  final DocumentSnapshot entry;
  final String entryId;
  final String content;
  final DateTime timestamp;
  final Function(String) onEdit;
  final Function onDelete;

  const JournalDetailScreen({
    super.key,
    required this.entry,
    required this.entryId,
    required this.content,
    required this.timestamp,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<JournalDetailScreen> createState() => _JournalDetailScreenState();
}

class _JournalDetailScreenState extends State<JournalDetailScreen> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.content);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveChanges() {
    widget.onEdit(_controller.text);
    setState(() {
      _isEditing = false;
    });
  }

  void _deleteEntry() {
    widget.onDelete();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat('MMMM d, y  |  h:mm a').format(widget.timestamp);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Journal Entry"),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveChanges,
            )
          else
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteEntry,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFF8E1), // Subtle parchment-like tone
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formattedDate,
                style: GoogleFonts.robotoSerif(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: TextField(
                  controller: _controller,
                  enabled: _isEditing,
                  maxLines: null,
                  style: GoogleFonts.robotoSerif(fontSize: 18),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Your journal entry...",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
