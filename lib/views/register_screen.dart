// lib/views/register_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'verify_email_screen.dart';
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onSwitchToLogin;
  const RegisterScreen({super.key, required this.onSwitchToLogin});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _name = '';
  bool _isLoading = false;

  void _register() async {
  if (!_formKey.currentState!.validate()) return;
  _formKey.currentState!.save();

  setState(() => _isLoading = true);

  try {
    final response = await AuthService.register(
      email: _email,
      password: _password,
      name: _name,
    );

    if (response.statusCode == 201) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyEmailScreen(email: _email),
        ),
      );
    } else {
      final error = jsonDecode(response.body);
      _showDialog('Registration Failed', error['message'] ?? 'Unknown error');
    }
  } catch (e) {
    _showDialog('Error', 'An unexpected error occurred.');
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}


  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white.withAlpha(230),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/login/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset('assets/login/logo.png', width: 150, height: 150),
                  const SizedBox(height: 100),
                  TextFormField(
                    decoration: _inputDecoration('Full Name'),
                    validator: (value) =>
                        value!.isEmpty ? 'Enter your name' : null,
                    onSaved: (value) => _name = value!,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: _inputDecoration('E-mail'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value!.isEmpty || !value.contains('@')
                        ? 'Enter a valid email'
                        : null,
                    onSaved: (value) => _email = value!,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: _inputDecoration('Password'),
                    obscureText: true,
                    validator: (value) => value!.length < 6
                        ? 'Password must be at least 6 characters'
                        : null,
                    onSaved: (value) => _password = value!,
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007BA7),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      minimumSize:
                          const Size(double.infinity, 50), // Full width
                    ),
                    onPressed: _isLoading ? null : _register,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Register',
                            style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: widget.onSwitchToLogin,
                    child: const Text('Already have an account? Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
