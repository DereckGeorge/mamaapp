import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../widgets/app_drawer.dart';
import '../widgets/app_bottom_navigation.dart';
import 'edit_profile_screen.dart';
import 'package:mamaapp/services/api_service.dart';
import 'package:mamaapp/screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _username = '';
  String _email = '';
  String? _userId;
  String? _imageUrl;
  final String baseUrl = dotenv.env['APP_BASE_URL'] ?? '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    print('Starting to load user data...'); // Debug init
    final prefs = await SharedPreferences.getInstance();

    // Debug: Print all available keys
    print('All SharedPreferences keys: ${prefs.getKeys()}');

    final userId = prefs.getString('user_id');
    final username = prefs.getString('username');
    final email = prefs.getString('email');

    // Debug: Print raw values
    print('Raw values from SharedPreferences:');
    print('userId: $userId');
    print('username: $username');
    print('email: $email');
    print('baseUrl: $baseUrl');

    setState(() {
      _username = username ?? 'User';
      _email = email ?? 'No email provided';
      _userId = userId;
    });

    // Debug: Print state values
    print('State values after update:');
    print('_username: $_username');
    print('_email: $_email');
    print('_userId: $_userId');

    if (_userId != null) {
      try {
        final apiUrl = '$baseUrl/api/users/$_userId/image';
        print('Attempting to fetch image from: $apiUrl'); // Debug API URL

        final response = await http.get(
          Uri.parse(apiUrl),
        );

        print(
            'API Response Status Code: ${response.statusCode}'); // Debug response
        print('API Response Body: ${response.body}');

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print('Decoded response data: $data'); // Debug decoded data

          final imagePath = data['data']['image_path'];
          print('Image path from response: $imagePath'); // Debug image path

          if (imagePath != null) {
            final fullImageUrl = '$baseUrl/$imagePath';
            print(
                'Constructed full image URL: $fullImageUrl'); // Debug full URL

            setState(() {
              _imageUrl = fullImageUrl;
            });
            print('_imageUrl set to: $_imageUrl'); // Debug final image URL
          } else {
            print('Image path is null in response data');
          }
        } else {
          print('API request failed with status: ${response.statusCode}');
          print('Error response: ${response.body}');
        }
      } catch (e) {
        print('Error fetching image: $e');
        print('Stack trace: ${StackTrace.current}'); // Debug stack trace
      }
    } else {
      print('User ID is null, skipping image fetch');
    }
  }

  Future<void> _handleLogout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userId = prefs.getString('user_id');
      final baseUrl = dotenv.env['APP_BASE_URL'] ?? '';

      if (token == null || userId == null) {
        // If no token or userId, just clear preferences and return to login
        await prefs.clear();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
        return;
      }

      // Call the logout API with user_id in the URL
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/logout/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      // Clear preferences regardless of response
      await prefs.clear();

      if (mounted) {
        if (response.statusCode == 200) {
          // Navigate to login screen and remove all previous routes
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        } else {
          // Show error but still navigate to login since we've cleared the token
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Logout error: ${jsonDecode(response.body)['message'] ?? 'Unknown error'}',
              ),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      // Handle any errors, clear preferences, and return to login
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during logout: $e'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

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
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Profile picture
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage:
                        _imageUrl != null ? NetworkImage(_imageUrl!) : null,
                    onBackgroundImageError: _imageUrl != null
                        ? (exception, stackTrace) {
                            print('Error loading image: $exception');
                            setState(() {
                              _imageUrl = null;
                            });
                          }
                        : null,
                    child: _imageUrl == null
                        ? const Icon(Icons.person, size: 50, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // User name
                  Text(
                    _username,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // User email
                  Text(
                    _email,
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
                      ).then(
                          (_) => _loadUserData()); // Reload data after editing
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
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Confirm Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        TextButton(
                          child: const Text('Logout'),
                          onPressed: () {
                            Navigator.of(context).pop();
                            _handleLogout();
                          },
                        ),
                      ],
                    );
                  },
                );
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
