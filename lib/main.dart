import 'package:flutter/material.dart';
import 'package:mamaapp/screens/splash_screen.dart';
import 'package:mamaapp/screens/login_screen.dart';
import 'package:mamaapp/screens/register_screen.dart';
import 'package:mamaapp/screens/home_screen.dart';
import 'package:mamaapp/screens/user_onboarding/pregnancy_info_screen.dart';
import 'package:mamaapp/screens/user_onboarding/summary_screen.dart';
import 'package:mamaapp/services/shared_preferences_service.dart';
import 'package:mamaapp/services/api_service.dart';
import 'package:mamaapp/models/user_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load();
    print("Environment variables loaded successfully.");
  } catch (e) {
    print("Error loading .env file: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MamaApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFCB4172)),
        useMaterial3: true,
      ),
      home: const AppInitializer(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/pregnancy_info': (context) => PregnancyInfoScreen(
              pregnancyData: UserPregnancyData(
                dueDate: DateTime.now().add(const Duration(days: 280)),
                weeksPregnant: 0,
                pregnancyStage: 'First trimester',
              ),
              isFirstChild: true,
              ageGroup: '25-34 years old',
            ),
      },
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  Widget? _nextScreen;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      // Check if user has seen onboarding
      final hasSeenOnboarding = await SharedPreferencesService.getHasSeenOnboarding();
      if (!hasSeenOnboarding) {
        _nextScreen = const SplashScreen();
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Check if user is logged in
      final isLoggedIn = await SharedPreferencesService.getHasLoggedIn();
      if (!isLoggedIn) {
        _nextScreen = const LoginScreen();
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Get user data
      final user = await _apiService.getUserData();
      if (user == null) {
        _nextScreen = const LoginScreen();
      } else {
        // User is logged in and has data, go directly to SummaryScreen
        // Create default pregnancy data if none exists
        final pregnancyData = user.pregnancyData ?? UserPregnancyData(
          dueDate: DateTime.now().add(const Duration(days: 280)),
          weeksPregnant: 0,
          pregnancyStage: 'First trimester',
          isFirstChild: true,
        );
        
        _nextScreen = SummaryScreen(
          pregnancyData: pregnancyData,
        );
      }
    } catch (e) {
      print('Error during app initialization: $e');
      _nextScreen = const LoginScreen();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFCB4172),
          ),
        ),
      );
    }

    return _nextScreen!;
  }
}
