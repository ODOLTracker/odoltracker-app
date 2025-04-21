import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import flutter_svg untuk gambar SVG
import '../services/user_service.dart'; // Import UserService untuk API
import 'edit_profile_screen.dart'; // Untuk navigasi ke halaman EditProfile
import 'dart:convert'; // Untuk decode JSON

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = "Loading..."; // Default username
  String userEmail = "Loading..."; // Default email
  String profilePic = "assets/profile.png"; // Default profile picture (PNG)
  bool _isLoading = true; // To handle loading state

  @override
  void initState() {
    super.initState();
    _loadUserProfile(); // Load user profile when the screen is initialized
  }

  // Load user profile from API
  _loadUserProfile() async {
    final response = await UserService.getProfile();
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        userName = data['user']['name'];
        userEmail = data['user']['email'];
        profilePic = data['user']['profilePicture'];
        _isLoading = false; // Update loading state
      });
    } else {
      setState(() {
        _isLoading = false; // Stop loading
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load profile')));
    }
  }

  // Check if the image URL is an SVG
  bool _isSvgImage(String imageUrl) {
    return imageUrl.endsWith('.svg');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: // ...existing code...
              Column(
            mainAxisSize: MainAxisSize.min, // Center vertically
            children: <Widget>[
              // Profile Picture
              _isLoading
                  ? const CircularProgressIndicator()
                  : CircleAvatar(
                      radius: 60,
                      backgroundImage: _isSvgImage(profilePic)
                          ? null // CircleAvatar does not support SVG directly
                          : NetworkImage(profilePic) as ImageProvider,
                      child: _isSvgImage(profilePic)
                          ? SvgPicture.network(
                              profilePic,
                              width: 120,
                              height: 120,
                            ) // Use SvgPicture for SVG
                          : null,
                    ),
              const SizedBox(height: 20),

              // Name field (display only)
              _isLoading
                  ? const SizedBox()
                  : Text(
                      userName,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
              const SizedBox(height: 20),

              // Email field (display only)
              _isLoading
                  ? const SizedBox()
                  : Text(
                      userEmail,
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
              const SizedBox(height: 40),

              // Change Profile Button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const EditProfileScreen()), // Navigate to EditProfileScreen
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Change Profile'),
              ),
              const SizedBox(height: 20),

              // Logout Button
              ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
// ...existing code...
        ),
      ),
    );
  }

  void _logout() {
    // Implement logout functionality
    // For example, clear authentication data
    Navigator.pushReplacementNamed(
        context, '/login'); // Navigate back to login screen
  }
}
