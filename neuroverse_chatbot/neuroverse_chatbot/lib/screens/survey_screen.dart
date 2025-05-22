// lib/screens/survey_screen.dart
import 'package:flutter/material.dart';

class SurveyScreen extends StatelessWidget {
  const SurveyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final questions = [
      "How do you feel today?",
      "Did you sleep well last night?",
      "How's your current stress level?",
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Survey'),
        backgroundColor: Colors.teal,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: questions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    questions[index],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(5, (rating) {
                      return Icon(Icons.circle,
                          size: 20,
                          color: rating <= 2 ? Colors.teal : Colors.grey[300]);
                    }),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
