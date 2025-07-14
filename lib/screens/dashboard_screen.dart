import 'package:flutter/material.dart';
import 'package:monitoring_hafalan_app/screens/prediction_form_screen.dart'; // Import the new screen
import 'package:monitoring_hafalan_app/screens/profile_screen.dart'; // Import the new unified profile screen
// Import global navigatorKey

class DashboardScreen extends StatefulWidget {
  final String userType;
  final String credential;
  final String displayName;

  const DashboardScreen({super.key, required this.userType, required this.credential, required this.displayName});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _initializeWidgetOptions();
  }

  void _initializeWidgetOptions() {
    if (widget.userType == 'Guru') {
      _widgetOptions = <Widget>[
        _buildHomeScreen(), // Existing dashboard content
        const PredictionFormScreen(), // Form Prediksi for Guru
        ProfileScreen(userType: widget.userType, credential: widget.credential, displayName: widget.displayName), // Unified Profile Screen
      ];
    } else { // Santri and Orang Tua Santri
      _widgetOptions = <Widget>[
        _buildHomeScreen(), // Existing dashboard content
        const Text(
          'Kemajuan Hafalan Screen',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        ProfileScreen(userType: widget.userType, credential: widget.credential, displayName: widget.displayName), // Unified Profile Screen
      ];
    }
  }

  Widget _buildHomeScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // Add a helper method for the generic profile screen for other users (if needed)
  Widget _buildProfileScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Profil Screen',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/');
          },
          child: const Text('Logout'),
        ),
      ],
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildAnimatedIcon(IconData iconData, int itemIndex) {
    final bool isSelected = _selectedIndex == itemIndex;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      transform: Matrix4.translationValues(
        0, // X-axis translation
        isSelected ? -5.0 : 0.0, // Y-axis translation (moves up when selected)
        0, // Z-axis translation
      ),
      child: Icon(iconData),
    );
  }

  List<BottomNavigationBarItem> _getBottomNavBarItems() {
    if (widget.userType == 'Guru') {
      return <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: _buildAnimatedIcon(Icons.home, 0),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: _buildAnimatedIcon(Icons.analytics, 1),
          label: 'Form Prediksi',
        ),
        BottomNavigationBarItem(
          icon: _buildAnimatedIcon(Icons.person, 2),
          label: 'Profil',
        ),
      ];
    } else { // Santri and Orang Tua Santri
      return <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: _buildAnimatedIcon(Icons.home, 0),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: _buildAnimatedIcon(Icons.book, 1),
          label: 'Kemajuan Hafalan',
        ),
        BottomNavigationBarItem(
          icon: _buildAnimatedIcon(Icons.person, 2),
          label: 'Profil',
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Selamat datang, ${widget.displayName}!',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 26, 144, 11),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _getBottomNavBarItems(), // Use the dynamic list of items
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 26, 144, 11),
        selectedIconTheme: const IconThemeData(size: 30),
        onTap: _onItemTapped,
      ),
    );
  }
}