import 'package:flutter/material.dart';
import 'change_password_screen.dart'; // Import ChangePasswordScreen
import 'dart:io'; // Import dart:io for File class
import '../services/user_service.dart'; // Import UserService for API
import 'dart:convert'; // For decoding JSON

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  String profilePic = "assets/profile.png"; // Default profile picture
  File? _profilePicFile; // To hold the selected profile picture file
  String initialName = ''; // To hold the initial name
  String initialEmail = ''; // To hold the initial email

  @override
  void initState() {
    super.initState();
    _loadUserProfile(); // Fetch user profile data from API
  }

  Future<void> _loadUserProfile() async {
    try {
      final response =
          await UserService.getProfile(); // Fetch user profile from API
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          initialName = data['user']['name'] ?? ''; // Simpan nilai awal nama
          initialEmail = data['user']['email'] ?? ''; // Simpan nilai awal email
          nameController.text = initialName; // Set nilai ke controller
          emailController.text = initialEmail; // Set nilai ke controller
          profilePic = data['user']['profilePicture'] ??
              "assets/profile.png"; // Set profile picture
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load profile')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('An error occurred while loading profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF007BA7),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              GestureDetector(
                onTap: _changeProfilePicture,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _profilePicFile != null
                      ? FileImage(_profilePicFile!) as ImageProvider
                      : (profilePic.startsWith(
                              'http') // Check if profilePic is a URL
                          ? NetworkImage(profilePic)
                          : AssetImage(profilePic)) as ImageProvider,
                ),
              ),
              const SizedBox(height: 20),
              const Text("Tap to change profile picture",
                  style: TextStyle(fontSize: 12, color: Colors.blue)),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Save Changes'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ChangePasswordScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Change Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _changeProfilePicture() async {
    // Implement image picker logic here
  }

  void _saveChanges() async {
    String name = nameController.text.trim();
    String email = emailController.text.trim();

    bool isNameChanged = name != initialName;
    bool isEmailChanged = email != initialEmail;

    if (name.isEmpty || email.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all fields')),
        );
      }
      return;
    }

    try {
      // Jika hanya nama yang berubah
      if (isNameChanged && !isEmailChanged) {
        final response = await UserService.updateProfile(name: name);
        if (response.statusCode == 200) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Name updated successfully!')),
            );
          }
        } else {
          throw Exception('Failed to update name');
        }
      }

      // Jika hanya email yang berubah
      if (!isNameChanged && isEmailChanged) {
        final response = await UserService.changeEmail(email);
        if (response.statusCode == 200) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Email updated successfully!')),
            );
          }
        } else {
          throw Exception('Failed to update email');
        }
      }

      // Jika keduanya berubah
      if (isNameChanged && isEmailChanged) {
        final nameResponse = await UserService.updateProfile(name: name);
        final emailResponse = await UserService.changeEmail(email);

        if (nameResponse.statusCode == 200 && emailResponse.statusCode == 200) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully!')),
            );
          }
        } else {
          throw Exception('Failed to update profile');
        }
      }

      if (mounted) {
        Navigator.pop(context); // Kembali ke layar sebelumnya setelah berhasil
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: ${e.toString()}')),
        );
      }
    }
  }
}
