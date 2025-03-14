import 'package:flutter/material.dart';
import 'package:mamaapp/services/shared_preferences_service.dart';
import 'package:mamaapp/screens/onboarding_screen.dart';
import 'package:mamaapp/screens/login_screen.dart';
import 'package:mamaapp/screens/register_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    await SharedPreferencesService.resetPreferences();
    
    await Future.delayed(const Duration(seconds: 5));
    if (!mounted) return;
    final hasSeenOnboarding = await SharedPreferencesService.getHasSeenOnboarding();
    final hasLoggedIn = await SharedPreferencesService.getHasLoggedIn();

    if (!hasSeenOnboarding) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    } else if (!hasLoggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCB4172),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/whitelogo.png',
              width: 80,
              height: 80,
            ),
            const SizedBox(width: 16),
            const Text(
              'MAMA APP',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 