import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mamaapp/features/journal/screens/journal_screen.dart';
import '../screens/reminders_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/health_tips_screen.dart';
import '../screens/symptoms_screen.dart';
import '../screens/ai_symptoms_screen.dart';
import 'package:http/http.dart' as http;

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String _username = '';
  String? _userId;
  String? _imageUrl;
  final String baseUrl = dotenv.env['APP_BASE_URL'] ?? '';

  @override
  void initState() {
    super.initState();
    print('AppDrawer initialized');
    print('Base URL: $baseUrl');
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    print('Loading user data...');
    final prefs = await SharedPreferences.getInstance();

    // Debug: Print all keys in SharedPreferences
    print('All SharedPreferences keys: ${prefs.getKeys()}');

    final userId = prefs.getString('user_id');
    final username = prefs.getString('username');

    print('User ID from SharedPreferences: $userId');
    print('Username from SharedPreferences: $username');

    // Try other possible keys if userId is null
    if (userId == null) {
      print('Trying alternative keys...');
      print('user_id: ${prefs.getString('user_id')}');
      print('id: ${prefs.getString('id')}');
      print('User ID: ${prefs.getString('User ID')}');
    }

    setState(() {
      _username = username ?? 'User';
      _userId = userId;
    });

    // Debug: Print final values
    print('Final _userId value: $_userId');
    print('Final _username value: $_username');

    if (_userId != null) {
      try {
        final apiUrl = '$baseUrl/api/users/$_userId/image';
        print('API URL being called: $apiUrl');

        final response = await http.get(
          Uri.parse(apiUrl),
        );

        print('API Response Status Code: ${response.statusCode}');
        print('API Response Body: ${response.body}');

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print('Decoded Response Data: $data');

          final imagePath = data['data']['image_path'];
          print('Image Path from Response: $imagePath');

          if (imagePath != null) {
            final fullImageUrl = '$baseUrl/$imagePath';
            print('Constructed Full Image URL: $fullImageUrl');

            setState(() {
              _imageUrl = fullImageUrl;
            });
          } else {
            print('Image path is null in response');
          }
        } else {
          print('API Error: Status ${response.statusCode}');
          print('Error Response: ${response.body}');
        }
      } catch (e) {
        print('Error fetching image path: $e');
        print('Stack trace: ${StackTrace.current}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFFFAE0E7),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  backgroundImage:
                      _imageUrl != null ? NetworkImage(_imageUrl!) : null,
                  onBackgroundImageError: _imageUrl != null
                      ? (exception, stackTrace) {
                          print('Error loading image: $exception');
                          print('Stack trace: $stackTrace');
                          setState(() {
                            _imageUrl = null;
                          });
                        }
                      : null,
                  child: _imageUrl == null
                      ? const Icon(Icons.person, size: 40, color: Colors.grey)
                      : null,
                ),
                const SizedBox(height: 10),
                Text(
                  _username,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Color(0xFFCB4172)),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.lightbulb_outline, color: Color(0xFFCB4172)),
            title: const Text('Health tips'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HealthTipsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined,
                color: Color(0xFFCB4172)),
            title: const Text('Reminders'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RemindersScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.book_outlined, color: Color(0xFFCB4172)),
            title: const Text('Personal Journal'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const JournalScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.add_circle_outline, color: Color(0xFFCB4172)),
            title: const Text('Add Symptoms'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AISymptomsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
