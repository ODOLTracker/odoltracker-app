import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;
  const VerifyEmailScreen({super.key, required this.email});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isSending = false;
  String? _statusMessage;

  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isSending = true;
      _statusMessage = null;
    });

    try {
      final response = await AuthService.resendVerificationEmail(widget.email);
      if (response.statusCode == 200) {
        setState(
            () => _statusMessage = 'Verification email sent successfully!');
      } else {
        setState(() => _statusMessage = 'Failed to resend verification email.');
      }
    } catch (e) {
      setState(() => _statusMessage = 'An error occurred. Please try again.');
    } finally {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF95A3C),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/login/logo.png', width: 150, height: 150),
              const SizedBox(height: 30),
              const Text(
                'Please verify your email',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                'We have sent a verification link to:',
                style: TextStyle(color: Colors.white.withOpacity(0.9)),
              ),
              Text(
                widget.email,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isSending ? null : _resendVerificationEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007BA7),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: _isSending
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Resend Verification Email'),
              ),
              const SizedBox(height: 16),
              if (_statusMessage != null)
                Text(
                  _statusMessage!,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                  );
                },
                child: const Text(
                  'Back to Login',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
