import 'package:flutter/material.dart';
import 'dart:convert'; // For decoding JSON
import '../services/user_service.dart'; // Import UserService for API
import '../services/tollgate_service.dart'; // Import TollgateService for API
import '../services/vehicledetection_service.dart'; // Import VehicleDetectionService for API
import '../services/notification_service.dart'; // Import NotificationService for API
import '../widgets/summary_tile.dart'; // Use summary_tile.dart for reusable tile
import '../widgets/image_section.dart'; // For images section reusable
import '../widgets/sensor_log.dart'; // For the logs
import 'profile_screen.dart'; // Import ProfileScreen
import 'notification_screen.dart'; // Import NotificationScreen for notifications
import 'package:badges/badges.dart' as badges; // Import badges package
import 'verify_image_screen.dart'; // Import VerifyImageScreen for verify images

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _userName = "Loading..."; // Default name
  bool _isLoading = true; // To handle loading state
  String _operatorId = ''; // To hold operator ID
  int _userID = 1; // To hold user ID
  List<Map<String, dynamic>> _tollgates =
      []; // List to hold tollgate names and IDs
  String? _selectedTollgate; // To hold selected tollgate name
  bool _isTollgatesLoading = true; // Loading state for tollgates
  bool _isCountLoading = false; // Loading state for vehicle counts
  int _overdimensionCount = 0; // Count for overdimension vehicles
  int _normalCount = 0; // Count for normal vehicles
  int _unreadCount = 0; // Unread notifications count

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
        _operatorId =
            data['user']['id'].toString(); // Get operator ID from user profile
        _userID = data['user']['id']; // Get user ID for notification count
        _isLoading = false; // Update loading state
      });
      _loadTollgates(); // Now load tollgates after user profile is fetched
      _fetchUnreadNotificationsCount(); // Fetch unread notifications count
    } else {
      setState(() {
        _isLoading = false; // Stop loading
      });
      // Handle failure, show error message
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load profile')));
    }
  }

  // Load tollgates based on the operatorId
  _loadTollgates() async {
    if (_operatorId.isNotEmpty) {
      final response =
          await TollgateService.getManagedTollgates(int.parse(_operatorId));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _tollgates = List<Map<String, dynamic>>.from(data['tollgates'].map(
              (tollgate) => {'name': tollgate['name'], 'id': tollgate['id']}));
          _isTollgatesLoading = false; // Stop loading
        });
      } else {
        setState(() {
          _isTollgatesLoading = false; // Stop loading
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to load tollgates')));
      }
    }
  }

  // Fetch overdimension and normal vehicle counts based on selected tollgate
  _fetchVehicleCounts() async {
    if (_selectedTollgate != null) {
      setState(() {
        _isCountLoading = true;
      });

      final tollgateId = _tollgates.firstWhere(
          (tollgate) => tollgate['name'] == _selectedTollgate)['id'];

      try {
        // Fetch overdimension count from all pages
        int overdimensionTotal = 0;
        int currentPage = 1;
        bool hasMore = true;

        while (hasMore) {
          final response = await VehicleDetectionService.getOverdimensionVehicleDetections(
            tollgateId,
            page: currentPage,
            limit: 10
          );

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            overdimensionTotal += (data['vehicledetections'] as List).length;
            
            // Check if there are more pages
            final totalPages = data['totalPages'] as int;
            hasMore = currentPage < totalPages;
            currentPage++;
          } else {
            throw Exception('Failed to fetch overdimension count');
          }
        }

        // Fetch normal count from all pages
        int normalTotal = 0;
        currentPage = 1;
        hasMore = true;

        while (hasMore) {
          final response = await VehicleDetectionService.getNormalVehicleDetections(
            tollgateId,
            page: currentPage,
            limit: 10
          );

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            normalTotal += (data['vehicledetections'] as List).length;
            
            // Check if there are more pages
            final totalPages = data['totalPages'] as int;
            hasMore = currentPage < totalPages;
            currentPage++;
          } else {
            throw Exception('Failed to fetch normal count');
          }
        }

        // Update state with total counts
        setState(() {
          _overdimensionCount = overdimensionTotal;
          _normalCount = normalTotal;
          _isCountLoading = false;
        });

      } catch (e) {
        print('Error fetching vehicle counts: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch vehicle counts: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
        setState(() {
          _isCountLoading = false;
        });
      }
    }
  }

  // Fetch unread notifications count
  _fetchUnreadNotificationsCount() async {
    final response =
        await NotificationService.getUnreadUserNotificationsCount(_userID); // Pass current userID
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _unreadCount = data['count']; // Set unread count
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch unread notifications')));
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
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
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
        const Text('Analytics Page',
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
        VerifyImageScreen(),
        NotificationScreen(), // Display NotificationScreen
        const ProfileScreen(),
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
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.verified),
            label: 'Verify Images',
          ),
          BottomNavigationBarItem(
            icon: badges.Badge(
              badgeContent: Text(
                _unreadCount.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              child: const Icon(Icons.notifications),
            ),
            label: 'Notifications',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
        unselectedItemColor: Colors.grey,
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
        child: _isTollgatesLoading
            ? const CircularProgressIndicator()
            : DropdownButton<String>(
                value: _selectedTollgate, // Set the selected value
                items: _tollgates.map((Map<String, dynamic> tollgate) {
                  return DropdownMenuItem<String>(
                    value: tollgate['name'],
                    child: Text(tollgate['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTollgate = value; // Update selected tollgate
                  });
                  _fetchVehicleCounts(); // Fetch vehicle counts when a tollgate is selected
                },
                hint: const Text('Select Location'),
                isExpanded: true,
              ),
      ),
    );
  }

  Widget _buildSummaryTiles() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: SummaryTile(
              title: 'Overdimension',
              count: _isCountLoading ? '...' : _overdimensionCount.toString(),
              color: Colors.red,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: SummaryTile(
              title: 'Normal',
              count: _isCountLoading ? '...' : _normalCount.toString(),
              color: Colors.green,
            ),
          ),
        ),
      ],
    );
  }
}
