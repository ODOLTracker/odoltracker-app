import 'package:flutter/material.dart';
import 'views/login_screen.dart';
import 'views/home_screen.dart';
import 'views/profile_screen.dart'; 
import 'views/verify_image_screen.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
// import 'package:awesome_notifications/awesome_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // AwesomeNotifications().initialize(
  //   'resource://drawable/res_app_icon',
  //   [
  //     NotificationChannel(
  //       channelKey: 'basic_channel',
  //       channelName: 'Basic notifications',
  //       channelDescription: 'Notification channel for basic tests',
  //       defaultColor: const Color(0xFF9D50DD),
  //       ledColor: Colors.white,
  //     ),
  //   ],
  // );
  
  // Initialize notification service
  await NotificationService().init();
  
  await AuthService.initialize();

  // // Start notification polling if user is already logged in
  // if (AuthService.isAuthenticated()) {
  //   final userId = AuthService.getCurrentUserId();
  //   if (userId != null) {
  //     NotificationService().startNotificationPolling(userId);
  //   }
  // }
  
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
        '/verify': (context) => const VerifyImageScreen(),
      },
    );
  }
}
