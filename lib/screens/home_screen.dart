import 'package:flutter/material.dart';
import 'package:mamaapp/models/user_model.dart';
import 'package:mamaapp/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:mamaapp/screens/user_onboarding/screens/reminders_screen.dart';
import 'package:mamaapp/screens/user_onboarding/widgets/app_bottom_navigation.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mamaapp/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _apiService.getUserData();
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading user data: $e')),
        );
      }
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/pinklogo.png',
              height: 30,
              width: 30,
            ),
            const SizedBox(width: 8),
            const Text(
              'MAMA APP',
              style: TextStyle(
                color: Color(0xFFCB4172),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFCB4172)),
            onPressed: () {
              // Show confirmation dialog before logout
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
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFCB4172),
              ),
            )
          : _user == null
              ? const Center(
                  child: Text('No user data found'),
                )
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Welcome, ${_user!.name}!',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (_user!.pregnancyData != null) ...[
                          _buildPregnancyCard(_user!.pregnancyData!),
                          const SizedBox(height: 24),
                        ],
                        const Text(
                          'Features',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          children: [
                            _buildFeatureCard(
                              'Health Tracker',
                              Icons.favorite,
                              'Track your health metrics',
                            ),
                            _buildFeatureCard(
                              'Appointments',
                              Icons.calendar_today,
                              'Manage doctor visits',
                            ),
                            _buildFeatureCard(
                              'Tips & Advice',
                              Icons.lightbulb,
                              'Pregnancy tips and advice',
                            ),
                            _buildFeatureCard(
                              'Nearby Hospitals',
                              Icons.local_hospital,
                              'Find healthcare services',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 0,
        onTap: (index) {
          // Handle navigation
        },
      ),
    );
  }

  Widget _buildPregnancyCard(UserPregnancyData pregnancyData) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFAE0E7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your Pregnancy',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFCB4172),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFCB4172),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${pregnancyData.weeksPregnant} weeks',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Due Date',
              DateFormat('MMM dd, yyyy').format(pregnancyData.dueDate)),
          _buildInfoRow('Stage', pregnancyData.pregnancyStage),
          if (pregnancyData.symptoms.isNotEmpty &&
              pregnancyData.symptoms.first != 'None of the above') ...[
            const SizedBox(height: 8),
            const Text(
              'Current Symptoms:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: pregnancyData.symptoms.map((symptom) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    symptom,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFCB4172),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String title, IconData icon, String description) {
    return InkWell(
      onTap: () {
        if (title == 'Appointments') {
          // Check if it's the appointments card
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RemindersScreen()),
          );
        } else {
          // Keep the existing fallback for other features
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title feature coming soon!')),
          );
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: const Color(0xFFCB4172),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
