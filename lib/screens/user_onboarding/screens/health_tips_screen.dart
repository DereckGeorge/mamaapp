import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_bottom_navigation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mamaapp/models/mama_tip_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'health_tip_detail_screen.dart';
import '../summary_screen.dart';
import 'package:mamaapp/services/api_service.dart';

class HealthTipsScreen extends StatefulWidget {
  const HealthTipsScreen({super.key});

  @override
  State<HealthTipsScreen> createState() => _HealthTipsScreenState();
}

class _HealthTipsScreenState extends State<HealthTipsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<MamaTip> _tips = [];
  String? _error;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadTips();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _apiService.getUserData();
      if (userData != null) {
        setState(() {
          _userName = userData.name;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _loadTips() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final baseUrl = dotenv.env['APP_BASE_URL'] ?? '';

      final response = await http.get(
        Uri.parse('$baseUrl/api/mama-tips'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _tips = (data['data'] as List)
              .map((tip) => MamaTip.fromJson(tip))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load tips';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToSummaryScreen() async {
    try {
      setState(() => _isLoading = true);
      final user = await _apiService.getUserData();
      setState(() => _isLoading = false);

      if (!mounted) return;

      if (user != null && user.pregnancyData != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SummaryScreen(
              pregnancyData: user.pregnancyData!,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to retrieve user data')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFCB4172),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _navigateToSummaryScreen,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Handle search
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFCB4172)))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pink container with welcome message
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFCB4172),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: Text(
                            'Welcome ${_userName.isNotEmpty ? _userName : "User"}!',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        _buildWelcomeCard(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Tips grid from API
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _error != null
                        ? Center(child: Text(_error!))
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: _tips.length,
                            itemBuilder: (context, index) {
                              final tip = _tips[index];
                              return _buildTipCard(tip);
                            },
                          ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 1,
        onTap: (index) {
          // Handle navigation
        },
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFD991A1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Guide to a Healthy Motherhood Journey!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Did you know? A balanced diet speeds up postpartum recovery!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HealthTipDetailScreen(tipId: 1),
                  ),
                );
              },
              icon: const Text(
                'Explore more',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              label: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 20,
              ),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFCB4172),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(MamaTip tip) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HealthTipDetailScreen(tipId: tip.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  image: tip.image != null
                      ? DecorationImage(
                          image: NetworkImage(
                              '${dotenv.env['APP_BASE_URL']}/${tip.image!}'),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: tip.image == null
                    ? const Center(
                        child: Icon(
                          Icons.health_and_safety,
                          size: 40,
                          color: Colors.grey,
                        ),
                      )
                    : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                tip.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
