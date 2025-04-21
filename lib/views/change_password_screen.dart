import 'package:flutter/material.dart';
import '../services/user_service.dart'; // Import UserService untuk API

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Change Password',
          style: TextStyle(
            color: Colors.white,
            ),
          ),
        backgroundColor: const Color(0xFF007BA7),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to EditProfileScreen
          },
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            // Old Password input
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Old Password',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // New Password input
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Save Password button
            ElevatedButton(
              onPressed: _savePassword,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Save Password'),
            ),
          ],
        ),
      ),
    );
  }

  // Function to save password changes
  void _savePassword() async {
    final oldPassword = oldPasswordController.text;
    final newPassword = newPasswordController.text;

    if (oldPassword.isNotEmpty && newPassword.isNotEmpty) {
      final response = await UserService.changePassword(
        oldPassword,
        newPassword,
      );

      if (response.statusCode == 200) {
        // If password is updated successfully
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password updated successfully')));

        // Go back to EditProfileScreen
        Navigator.pop(context);
      } else {
        // If API call fails
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update password')));
      }
    } else {
      // Validation for empty fields
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill both fields')));
    }
  }
}
