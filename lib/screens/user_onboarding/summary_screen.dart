import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamaapp/models/user_model.dart';
import 'package:mamaapp/screens/user_onboarding/screens/health_tips_screen.dart';
import 'package:mamaapp/services/api_service.dart';
import 'package:mamaapp/screens/home_screen.dart';
import 'widgets/app_drawer.dart';
import 'widgets/app_bottom_navigation.dart';
import 'widgets/pregnancy_progress_card.dart';
import 'widgets/feature_card.dart';
import 'screens/reminders_screen.dart';

class SummaryScreen extends StatefulWidget {
  final UserPregnancyData pregnancyData;

  const SummaryScreen({
    super.key,
    required this.pregnancyData,
  });

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _saveAndContinue() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _apiService.updatePregnancyData(widget.pregnancyData);

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving data: $e')),
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
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {
              // Handle notifications
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Welcome,',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'Marilyne Swai',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Pregnancy Progress Card
              PregnancyProgressCard(pregnancyData: widget.pregnancyData),
              const SizedBox(height: 24),

              // Feature Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  FeatureCard(
                    title: 'Add Symptoms',
                    iconPath: 'assets/symptoms_icon.png',
                    color: const Color(0xFFFFE6E6),
                    onTap: () {
                      // Navigate to symptoms screen
                    },
                  ),
                  FeatureCard(
                    title: 'Daily health articles',
                    iconPath: 'assets/articles_icon.png',
                    color: const Color(0xFFFFE6E6),
                    onTap: () {
                      Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HealthTipsScreen(),
                ),
              );
                    },
                  ),
                  FeatureCard(
                    title: 'Health Progress',
                    iconPath: 'assets/progress_icon.png',
                    color: const Color(0xFFFFE6E6),
                    onTap: () {
                      // Navigate to progress screen
                    },
                  ),
                  FeatureCard(
                    title: 'Reminders',
                    iconPath: 'assets/reminders_icon.png',
                    color: const Color(0xFFFFE6E6),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RemindersScreen(),
                        ),
                      );
                    },
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
}
