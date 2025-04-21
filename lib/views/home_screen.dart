import 'package:flutter/material.dart';
import 'dart:convert'; // Untuk decode JSON
import '../services/user_service.dart'; // Import UserService untuk API
import '../widgets/summary_tile.dart'; // Use summary_tile.dart for reusable tile
import '../widgets/image_section.dart'; // For images section reusable
import '../widgets/sensor_log.dart'; // For the logs
import 'profile_screen.dart'; // Import ProfileScreen

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _userName = "Loading..."; // Default name
  bool _isLoading = true; // To handle loading state

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // Load user profile from API
  _loadUserProfile() async {
    final response = await UserService.getProfile();
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _userName = data['user']['name'];
        _isLoading = false; // Update loading state
      });
    } else {
      setState(() {
        _isLoading = false; // Stop loading
      });
      // Handle failure, show error message
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to load profile')));
    }
  }

  List<Widget> _widgetOptions() => [
        SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              // Display "Hello, <name>" with dynamic data
              _isLoading
                  ? const CircularProgressIndicator()
                  : Text(
                      'Hello, $_userName!',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
              const SizedBox(height: 20),
              _buildDropdown(),
              _buildSummaryTiles(),
              ImageSection(
                title: 'Images to verify',
                child: Container(
                  height: 100,
                  color: Colors.grey[300], // Placeholder
                ),
              ),
              const SensorLog(log: 'Sensor Log will be displayed here...'),
            ],
          ),
        ),
        const Text('Settings Page',
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
        const ProfileScreen(), // Profile page integrated
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Jika tab "Home" dipilih, fetch ulang profil
    if (index == 0) {
      _loadUserProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Image(
            image: AssetImage('assets/logo_panjang.png'),
            width: 200,
            height: 200,
          ),
        ),
        backgroundColor: const Color(0xFF007BA7),
      ),
      body: Center(
        child: _widgetOptions().elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      margin: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(color: Colors.grey),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          items: <String>['Pintu Tol Tandes', 'Other Locations']
              .map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (_) {},
          hint: const Text('Select Location'),
          isExpanded: true,
        ),
      ),
    );
  }

  Widget _buildSummaryTiles() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: SummaryTile(
              title: 'Overdimension',
              count: '23',
              color: Colors.red,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: SummaryTile(
              title: 'Normal',
              count: '134',
              color: Colors.green,
            ),
          ),
        ),
      ],
    );
  }
}