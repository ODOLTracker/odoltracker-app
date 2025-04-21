import 'package:flutter/material.dart';
import 'views/login_screen.dart';
import 'views/home_screen.dart';
import 'views/profile_screen.dart'; 
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ODOLTracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: AuthService.isAuthenticated() ? HomeScreen() : LoginScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/profile': (context) => const ProfileScreen(), 
      },
    );
  }
}
