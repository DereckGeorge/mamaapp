import 'package:flutter/material.dart';
import 'package:mamaapp/screens/home_screen.dart';
import 'package:mamaapp/screens/user_onboarding/screens/health_tips_screen.dart';
import 'package:mamaapp/screens/user_onboarding/screens/symptoms_screen.dart';
import 'package:mamaapp/screens/user_onboarding/screens/profile_screen.dart';
import 'package:mamaapp/services/api_service.dart';
import 'package:mamaapp/models/user_model.dart';
import 'package:mamaapp/screens/user_onboarding/summary_screen.dart';
import 'package:mamaapp/screens/user_onboarding/screens/ai_symptoms_screen.dart';

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

    switch (index) {
      case 0:
        // For home tab, get user data and navigate to SummaryScreen
        try {
          final userData = await _apiService.getUserData();
          if (userData != null && userData.pregnancyData != null) {
            screen = SummaryScreen(
              pregnancyData: userData.pregnancyData!,
            );
          } else {
            // Create default pregnancy data if none exists
            final defaultPregnancyData = UserPregnancyData(
              dueDate: DateTime.now().add(const Duration(days: 280)),
              weeksPregnant: 0,
              pregnancyStage: 'First trimester',
              isFirstChild: true,
            );

            screen = SummaryScreen(
              pregnancyData: defaultPregnancyData,
            );
          }
        } catch (e) {
          // Create default pregnancy data on error
          final defaultPregnancyData = UserPregnancyData(
            dueDate: DateTime.now().add(const Duration(days: 280)),
            weeksPregnant: 0,
            pregnancyStage: 'First trimester',
            isFirstChild: true,
          );

          screen = SummaryScreen(
            pregnancyData: defaultPregnancyData,
          );
        }
        break;
      case 1:
        screen = const HealthTipsScreen();
        break;
      case 2:
        screen = const AISymptomsScreen();
        break;
      case 3:
        screen = const ProfileScreen();
        break;
      default:
        return;
    }

    if (screen != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => screen!,
        ),
      );
    }
  }
}
