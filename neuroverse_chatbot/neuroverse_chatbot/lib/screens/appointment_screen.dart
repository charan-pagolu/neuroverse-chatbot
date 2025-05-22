import 'package:flutter/material.dart';

class AppointmentScreen extends StatelessWidget {
  const AppointmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Appointments'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: const [
            _AppointmentCard(
              doctor: 'Dr. Lisa Ray',
              specialty: 'Therapist',
              time: '10:30 AM - 11:00 AM',
            ),
            _AppointmentCard(
              doctor: 'Dr. Kevin Smith',
              specialty: 'Psychologist',
              time: '02:00 PM - 02:30 PM',
            ),
            _AppointmentCard(
              doctor: 'Dr. Ana Patel',
              specialty: 'Wellness Coach',
              time: '04:00 PM - 04:30 PM',
            ),
          ],
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final String doctor;
  final String specialty;
  final String time;

  const _AppointmentCard({
    required this.doctor,
    required this.specialty,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 24,
              backgroundColor: Colors.teal,
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(doctor, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(specialty),
                  const SizedBox(height: 6),
                  Text(time, style: const TextStyle(color: Colors.teal)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
