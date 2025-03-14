import 'dart:async';
import 'dart:convert';
import 'package:mamaapp/models/user_model.dart';
import 'package:mamaapp/services/shared_preferences_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  User? _currentUser;

  User? get currentUser => _currentUser;

  Future<User> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    if (email.isNotEmpty && password.isNotEmpty) {
      _currentUser = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Test User',
        email: email,
        isFirstTimeUser: true,
      );

      await SharedPreferencesService.setHasLoggedIn(true);
      
      await _saveUserData();

      return _currentUser!;
    } else {
      throw Exception('Invalid email or password');
    }
  }

  Future<User> register(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      _currentUser = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        isFirstTimeUser: true,
      );

      await SharedPreferencesService.setHasLoggedIn(true);
      
      await _saveUserData();

      return _currentUser!;
    } else {
      throw Exception('Invalid registration data');
    }
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
    await SharedPreferencesService.setHasLoggedIn(false);
  }

  Future<User> updatePregnancyData(UserPregnancyData pregnancyData) async {
    await Future.delayed(const Duration(seconds: 1));

    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        pregnancyData: pregnancyData,
        isFirstTimeUser: false,
      );
      
      await _saveUserData();
      
      return _currentUser!;
    } else {
      throw Exception('User not logged in');
    }
  }

  Future<User?> getUserData() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final userData = await SharedPreferencesService.getUserData();
    if (userData != null) {
      _currentUser = User.fromJson(jsonDecode(userData));
      return _currentUser;
    }
    
    return null;
  }

  Future<void> _saveUserData() async {
    if (_currentUser != null) {
      await SharedPreferencesService.setUserData(
        jsonEncode(_currentUser!.toJson()),
      );
    }
  }

  Future<List<String>> getHealthConditions() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      'Diabetes',
      'Hypertension',
      'Anemia',
      'Thyroid disorder',
      'Asthma',
      'Heart disease',
      'Kidney disease',
      'Depression/Anxiety',
      'None of the above',
    ];
  }

  Future<List<String>> getCommonSymptoms() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      'Morning sickness',
      'Fatigue',
      'Headaches',
      'Back pain',
      'Swelling',
      'Heartburn',
      'Constipation',
      'Insomnia',
      'Mood swings',
      'None of the above',
    ];
  }
} 