import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color primaryTeal = Color(0xFF317773);

  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _phone = '';
  String _avatarUrl = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data() ?? {};
      final fullName = data['fullName'] ?? '';
      final parts = fullName.split(' ');

      setState(() {
        _firstName = parts.isNotEmpty ? parts[0] : '';
        _lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
        _email = user.email ?? '';
        _phone = data['phone'] ?? '';
        _avatarUrl = data['avatarUrl'] ?? '';
      });
    }
  }

  Widget _buildProfileField(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(icon, color: primaryTeal),
          title: Text(
            label,
            style: GoogleFonts.urbanist(fontSize: 13, color: Colors.grey),
          ),
          subtitle: Text(
            value.isNotEmpty ? value : 'Not provided',
            style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  @override
  @override
Widget build(BuildContext context) {
  final initials = '${_firstName.isNotEmpty ? _firstName[0] : ''}${_lastName.isNotEmpty ? _lastName[0] : ''}';

  return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text('Profile', style: GoogleFonts.urbanist(color: Colors.black)),
      iconTheme: const IconThemeData(color: Colors.black),
    ),
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 42,
              backgroundColor: primaryTeal,
              backgroundImage: _avatarUrl.isNotEmpty
                  ? NetworkImage(_avatarUrl)
                  : const AssetImage('assets/images/avatar.png') as ImageProvider,
              child: _avatarUrl.isEmpty
                  ? Text(
                      initials,
                      style: GoogleFonts.urbanist(
                          fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    )
                  : null,
            ),
            const SizedBox(height: 12),
            Text(
              '$_firstName $_lastName',
              style: GoogleFonts.urbanist(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            _buildProfileField('Email', _email, Icons.email_outlined),
            _buildProfileField('Phone', _phone, Icons.phone_outlined),
            _buildProfileField('Password', '********', Icons.lock_outline),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.logout),
              label: Text(
                'LOG OUT',
                style: GoogleFonts.urbanist(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
