import 'dart:async';
import 'dart:convert';
import 'package:mamaapp/models/user_model.dart';
import 'package:mamaapp/services/shared_preferences_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mamaapp/models/query_log_model.dart';
import 'dart:math';
import 'package:mamaapp/models/health_model.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Get base URL from environment variables with better error handling
  String get baseUrl {
    final url = dotenv.env['APP_BASE_URL'];
    if (url == null) {
      throw Exception('APP_BASE_URL not found in environment variables');
    }
    return url;
  }

  // Get AI base URL from environment variables
  String get aiBaseUrl {
    final url = dotenv.env['AI_BASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('AI_BASE_URL is not configured in .env file');
    }
    return url;
  }

  User? _currentUser;

  User? get currentUser => _currentUser;

  Future<User> login(String login, String password) async {
    try {
      final url = Uri.parse('$baseUrl/api/auth/login');
      print('Attempting login to: $url'); // Debug print

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'login': login,
          'password': password,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Save all the necessary data to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', responseData['access_token']);
        await prefs.setBool('isLoggedIn', true);

        // Also set the login state in SharedPreferencesService for better persistence
        await SharedPreferencesService.setHasLoggedIn(true);

        // Store user data
        final userData = responseData['user'];
        await prefs.setString('user_id', userData['id'].toString());
        await prefs.setString('username', userData['username']);
        await prefs.setString('email', userData['email'] ?? '');
        await prefs.setString('phone_number', userData['phone_number'] ?? '');
        await prefs.setBool(
            'is_first_time_user',
            userData['is_first_time_user'] ??
                false); // Set to false to avoid onboarding

        // Print stored data
        print('\n--- Stored User Data ---');
        print('User ID: ${await prefs.getString('user_id')}');
        print('Username: ${await prefs.getString('username')}');
        print('Email: ${await prefs.getString('email')}');
        print('Phone: ${await prefs.getString('phone_number')}');
        print('Is First Time: ${await prefs.getBool('is_first_time_user')}');
        print('Token: ${await prefs.getString('token')}');
        print('Is Logged In: ${await prefs.getBool('isLoggedIn')}');
        print('----------------------\n');

        // Create user object from response
        _currentUser = User(
          id: userData['id'].toString(),
          name: userData['username'],
          email: userData['email'] ?? '',
          phone: userData['phone_number'],
          isFirstTimeUser: false, // Set to false to avoid onboarding
        );

        await _saveUserData();
        return _currentUser!;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Login failed');
      }
    } catch (e) {
      print('Login error: $e');
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<User> register(
      String name, String email, String phone, String password) async {
    try {
      // Input validation
      if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
        throw Exception('All fields are required');
      }

      if (!email.contains('@')) {
        throw Exception('Please enter a valid email address');
      }

      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters long');
      }

      final url = Uri.parse('$baseUrl/api/auth/register');
      print('Attempting registration to: $url');

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'username': name,
            'email': email,
            'phone_number': phone,
            'password': password,
            'password_confirmation': password,
          }),
        );

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        final responseData = json.decode(response.body);

        // Handle different response status codes
        switch (response.statusCode) {
          case 201:
            return await _handleSuccessfulRegistration(responseData);
          case 422:
            // Validation errors
            final errors = responseData['errors'];
            if (errors != null) {
              if (errors['email'] != null) {
                throw Exception(errors['email'][0]);
              }
              if (errors['phone_number'] != null) {
                throw Exception(errors['phone_number'][0]);
              }
              if (errors['username'] != null) {
                throw Exception(errors['username'][0]);
              }
            }
            throw Exception(responseData['message'] ?? 'Validation failed');
          case 400:
            throw Exception(responseData['message'] ?? 'Bad request');
          case 500:
            throw Exception('Server error. Please try again later');
          default:
            throw Exception(responseData['message'] ?? 'Registration failed');
        }
      } on http.ClientException catch (e) {
        throw Exception('Network error. Please check your connection');
      } on FormatException catch (e) {
        throw Exception('Invalid response format from server');
      }
    } catch (e) {
      print('Registration error: $e');
      rethrow; // Rethrow to preserve the original error message
    }
  }

  Future<User> _handleSuccessfulRegistration(
      Map<String, dynamic> responseData) async {
    try {
      final userData = responseData['user'];
      if (userData == null) {
        throw Exception('Invalid response: missing user data');
      }

      // Store user data in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await _storeUserData(prefs, userData);

      // Print stored data for debugging
      await _printStoredUserData(prefs);

      // Create and return user object
      _currentUser = _createUserFromData(userData);
      await _saveUserData();

      return _currentUser!;
    } catch (e) {
      print('Error handling registration response: $e');
      throw Exception('Error processing registration data');
    }
  }

  Future<void> _storeUserData(
      SharedPreferences prefs, Map<String, dynamic> userData) async {
    await prefs.setBool('isLoggedIn', false); // Set to false until they log in
    await prefs.setString('user_id', userData['id'].toString());
    await prefs.setString('username', userData['username']);
    await prefs.setString('email', userData['email'] ?? '');
    await prefs.setString('phone_number', userData['phone_number'] ?? '');
    await prefs.setBool(
        'is_first_time_user', true); // New user is always first time
  }

  Future<void> _printStoredUserData(SharedPreferences prefs) async {
    print('\n--- Stored User Data After Registration ---');
    print('User ID: ${await prefs.getString('user_id')}');
    print('Username: ${await prefs.getString('username')}');
    print('Email: ${await prefs.getString('email')}');
    print('Phone: ${await prefs.getString('phone_number')}');
    print('Is First Time: ${await prefs.getBool('is_first_time_user')}');
    print('Is Logged In: ${await prefs.getBool('isLoggedIn')}');
    print('----------------------\n');
  }

  User _createUserFromData(Map<String, dynamic> userData) {
    return User(
      id: userData['id'].toString(),
      name: userData['username'],
      email: userData['email'] ?? '',
      phone: userData['phone_number'],
      isFirstTimeUser: true, // New user is always first time
    );
  }

  Future<void> logout() async {
    try {
      final url = Uri.parse('$baseUrl/api/auth/logout');
      final token = await getToken();

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _currentUser = null;

        // Clear all stored data
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        await prefs.remove('user_id');
        await prefs.remove('username');
        await prefs.remove('email');
        await prefs.remove('phone_number');
        await prefs.remove('is_first_time_user');
        await prefs.setBool('isLoggedIn', false);
      } else {
        throw Exception('Logout failed');
      }
    } catch (e) {
      print('Logout error: $e');
      throw Exception('Logout failed: ${e.toString()}');
    }
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

  Future<User?> getUserProfile() async {
    try {
      final url = Uri.parse('$baseUrl/api/auth/user-profile');
      final token = await getToken();

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        _currentUser = User(
          id: userData['id'].toString(),
          name: userData['username'],
          email: userData['email'] ?? '',
          phone: userData['phone_number'],
          isFirstTimeUser: userData['is_first_time_user'] ?? true,
        );
        return _currentUser;
      } else {
        throw Exception('Failed to get user profile');
      }
    } catch (e) {
      print('Get user profile error: $e');
      return null;
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Add a method to retrieve stored user data
  Future<Map<String, dynamic>> getStoredUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'user_id': prefs.getString('user_id'),
      'username': prefs.getString('username'),
      'email': prefs.getString('email'),
      'phone_number': prefs.getString('phone_number'),
      'is_first_time_user': prefs.getBool('is_first_time_user'),
      'token': prefs.getString('token'),
      'isLoggedIn': prefs.getBool('isLoggedIn'),
    };
  }

  Future<void> storeMamaData({
    required bool isFirstChild,
    required String ageGroup,
    String? babyGender,
    DateTime? dueDate,
    DateTime? firstDayCircle,
    int? gestationalPeriod,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      if (userId == null) {
        throw Exception('User ID not found');
      }

      final url = Uri.parse('$baseUrl/api/mama-data');
      print('Storing mama data at: $url');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await getToken()}',
        },
        body: json.encode({
          'user_id': int.parse(userId),
          'first_child': isFirstChild,
          'age_group': ageGroup,
          'baby_gender': babyGender?.toLowerCase() ?? "i don't know yet",
          'due_date': dueDate?.toIso8601String(),
          'first_day_circle': firstDayCircle?.toIso8601String(),
          'gestational_period': gestationalPeriod,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 201) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to store mama data');
      }
    } catch (e) {
      print('Store mama data error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> queryAI(String message) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final phoneNumber = prefs.getString('phone_number');

      print('Debug API Request:');
      print('URL: $aiBaseUrl/api/query');
      print('Token: ${token?.substring(0, min(20, token?.length ?? 0))}...');
      print('Phone Number: $phoneNumber');
      print('Message: $message');

      final response = await http.post(
        Uri.parse('$aiBaseUrl/api/query'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'text': message,
          'phone_number': phoneNumber,
          'response_format': 'text',
          'voice': 'alloy',
        }),
      );

      print('Debug API Response:');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Parsed Response Data: $data');
        return {
          'text_response': data['text_response'] ?? 'No response available',
          'audio_url': data['audio_url'] ?? '',
        };
      } else {
        print('Error Response: ${response.body}');
        throw Exception('Failed to get AI response: ${response.statusCode}');
      }
    } catch (e) {
      print('API Error: $e');
      throw Exception('Error: $e');
    }
  }

  Future<List<QueryLog>> getConversationHistory(String phoneNumber,
      {int limit = 10, int skip = 0}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      print('Debug API Request - Conversation History:');
      print('URL: $aiBaseUrl/api/text/$phoneNumber');
      print('Token: ${token?.substring(0, min(20, token?.length ?? 0))}...');
      print('Phone Number: $phoneNumber');
      print('Limit: $limit, Skip: $skip');

      final response = await http.get(
        Uri.parse('$aiBaseUrl/api/text/$phoneNumber?limit=$limit&skip=$skip'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('Debug API Response - Conversation History:');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Parsed Response Data: $data');
        return data.map((json) => QueryLog.fromJson(json)).toList();
      } else {
        print('Error Response: ${response.body}');
        throw Exception(
            'Failed to load conversation history: ${response.statusCode}');
      }
    } catch (e) {
      print('API Error: $e');
      throw Exception('Error: $e');
    }
  }

  Future<HealthAnalysis> analyzeHealth(String phoneNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      print('\n=== Health Analysis API Call ===');
      print('Endpoint: $aiBaseUrl/api/health/health/$phoneNumber');
      print('Method: POST');
      print('Headers:');
      print('  - Authorization: Bearer [token]');
      print('  - Accept: application/json');

      final response = await http.post(
        Uri.parse('$aiBaseUrl/api/health/health/$phoneNumber'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return HealthAnalysis.fromJson(data);
      } else {
        throw Exception('Failed to analyze health: ${response.body}');
      }
    } catch (e) {
      print('Error analyzing health: $e');
      rethrow;
    }
  }

  Future<List<HealthAnalysisLog>> getHealthHistory(String phoneNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      print('\n=== Health History API Call ===');
      print('Endpoint: $aiBaseUrl/api/health/health/$phoneNumber');
      print('Method: GET');
      print('Headers:');
      print('  - Authorization: Bearer [token]');
      print('  - Accept: application/json');

      final response = await http.get(
        Uri.parse('$aiBaseUrl/api/health/health/$phoneNumber'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Check if data is empty
        if (data.isEmpty) {
          print('Warning: API returned empty array');
          return [];
        }

        // Sort the data by timestamp in descending order (newest first)
        data.sort((a, b) => DateTime.parse(b['timestamp'])
            .compareTo(DateTime.parse(a['timestamp'])));

        return data
            .map((log) {
              try {
                return HealthAnalysisLog.fromJson(log);
              } catch (e) {
                print('Error parsing health log: $e');
                print('Invalid log data: $log');
                return null;
              }
            })
            .whereType<HealthAnalysisLog>()
            .toList();
      } else {
        print('Error: API returned status code ${response.statusCode}');
        print('Response body: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error getting health history: $e');
      print('Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  Future<String> getHealthAudioSummary(String phoneNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('$aiBaseUrl/audio/$phoneNumber'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['audio_url'];
      } else {
        throw Exception('Failed to get audio summary: ${response.body}');
      }
    } catch (e) {
      print('Error getting audio summary: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getMamaData(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/mama-data/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await getToken()}',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        return {
          'status': 'error',
          'message': 'Mama data not found',
        };
      } else {
        return {
          'status': 'error',
          'message': 'Failed to load mama data',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error connecting to server: $e',
      };
    }
  }
}
