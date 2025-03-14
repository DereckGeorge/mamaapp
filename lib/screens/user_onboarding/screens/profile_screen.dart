import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_bottom_navigation.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              // Handle settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Profile picture
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/profile_picture.jpg'),
                    backgroundColor: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  
                  // User name
                  const Text(
                    'Marilyne Swai',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // User email
                  Text(
                    'marilyneswai@gmail.com',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Edit profile button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCB4172),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      minimumSize: const Size(150, 36),
                    ),
                    child: const Text('Edit Profile'),
                  ),
                ],
              ),
            ),
            
            // Menu options
            _buildMenuOption(
              icon: Icons.favorite_border,
              title: 'Health Progress',
              onTap: () {
                // Navigate to health progress screen
              },
            ),
            
            _buildMenuOption(
              icon: Icons.download_outlined,
              title: 'Downloads',
              onTap: () {
                // Navigate to downloads screen
              },
            ),
            
            _buildMenuOption(
              icon: Icons.language,
              title: 'Language',
              onTap: () {
                // Navigate to language settings
              },
            ),
            
            const Divider(),
            
            _buildMenuOption(
              icon: Icons.history,
              title: 'Clear History',
              onTap: () {
                // Show clear history dialog
              },
            ),
            
            const SizedBox(height: 20),
            
            _buildMenuOption(
              icon: Icons.logout,
              title: 'Log out',
              onTap: () {
                // Show logout confirmation dialog
              },
              showArrow: false,
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 3,
        onTap: (index) {
          // Handle navigation
        },
      ),
    );
  }
  
  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool showArrow = true,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFCB4172)),
      title: Text(title),
      trailing: showArrow ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }
} 