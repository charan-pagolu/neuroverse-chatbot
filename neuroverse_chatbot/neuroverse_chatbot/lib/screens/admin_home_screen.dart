import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  List<dynamic> _usersList = [];

  Future<void> _printUsers(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final usersString = prefs.getString('users');

    if (usersString != null) {
      final users = jsonDecode(usersString);
      setState(() {
        _usersList = users;
      });

      _showSnackBar(context, 'Success', 'User data loaded successfully!', ContentType.success);
    } else {
      _showSnackBar(context, 'Warning', 'No users found.', ContentType.warning);
      setState(() {
        _usersList = [];
      });
    }
  }

  Future<void> _resetUsers(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final loggedInEmail = prefs.getString('loggedInEmail') ?? '';

    bool confirmReset = await _showConfirmationDialog(context);
    if (!confirmReset) return;

    await prefs.clear();

    await prefs.setString('loggedInEmail', loggedInEmail);
    await prefs.setBool('isLoggedIn', true);

    setState(() {
      _usersList = [];
    });

    _showSnackBar(context, 'Reset Complete', 'User data reset. Admin still logged in.', ContentType.success);
  }

  Future<bool> _showConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Reset'),
        content: const Text('Are you sure you want to reset all user data? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Confirm'),
          ),
        ],
      ),
    ) ??
        false;
  }

  void _logoutAdmin(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _showSnackBar(BuildContext context, String title, String message, ContentType type) {
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: type,
        color: const Color(0xFF317773),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF317773);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: primaryTeal,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Admin Actions',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryTeal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _printUsers(context),
              icon: const Icon(Icons.list, color: Colors.white),
              label: const Text('Load User Data', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryTeal,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _resetUsers(context),
              icon: const Icon(Icons.restore, color: Colors.white),
              label: const Text('Reset Users (Keep Admin)', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _logoutAdmin(context),
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text('Logout Admin', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 24),

            // Display loaded user data
            Expanded(
              child: _usersList.isEmpty
                  ? const Center(child: Text('No users loaded yet.', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                itemCount: _usersList.length,
                itemBuilder: (context, index) {
                  final user = _usersList[index];
                  final userJson = const JsonEncoder.withIndent('  ').convert(user);
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      userJson,
                      style: const TextStyle(fontFamily: 'Urbanist', fontSize: 14),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
