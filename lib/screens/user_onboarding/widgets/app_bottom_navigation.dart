import 'package:flutter/material.dart';
import 'package:mamaapp/screens/user_onboarding/summary_screen.dart';
import 'package:mamaapp/screens/user_onboarding/screens/health_tips_screen.dart';
import 'package:mamaapp/screens/user_onboarding/screens/symptoms_screen.dart';
import 'package:mamaapp/screens/user_onboarding/screens/profile_screen.dart';
import 'package:mamaapp/services/api_service.dart';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final ApiService _apiService = ApiService();

  AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFCB4172),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          onTap(index);
          _navigateToScreen(context, index);
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.7),
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline),
            label: 'Health tips',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services_outlined),
            label: 'Symptoms',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToScreen(BuildContext context, int index) async {
    if (index == currentIndex) return;
    
    Widget? screen;
    
    if (index == 0) {
      // For home button, always get the latest user data
      try {
        final user = await _apiService.getUserData();
        if (user != null && user.pregnancyData != null) {
          screen = SummaryScreen(pregnancyData: user.pregnancyData!);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unable to retrieve user data')),
          );
          return;
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        return;
      }
    } else {
      switch (index) {
        case 1:
          screen = const HealthTipsScreen();
          break;
        case 2:
          screen = const SymptomsScreen();
          break;
        case 3:
          screen = const ProfileScreen();
          break;
      }
    }

    if (screen != null && context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => screen!,
        ),
      );
    }
  }
} 