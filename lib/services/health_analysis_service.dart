import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mamaapp/services/api_service.dart';
import 'package:mamaapp/models/health_model.dart';

class HealthAnalysisService {
  static final HealthAnalysisService _instance =
      HealthAnalysisService._internal();
  factory HealthAnalysisService() => _instance;
  HealthAnalysisService._internal();

  final ApiService _apiService = ApiService();
  Timer? _analysisTimer;
  bool _isRunning = false;

  Future<void> startPeriodicAnalysis() async {
    if (_isRunning) {
      print('\n=== Health Analysis Service ===');
      print('Service is already running');
      print('==========================\n');
      return;
    }

    print('\n=== Starting Health Analysis Service ===');
    print('Initializing periodic health analysis...');

    try {
      final prefs = await SharedPreferences.getInstance();
      final phoneNumber = prefs.getString('phone_number');

      if (phoneNumber == null) {
        print('Error: Phone number not found in SharedPreferences');
        return;
      }

      // Perform initial analysis
      await _performAnalysis(phoneNumber);

      // Set up periodic analysis (every hour)
      _analysisTimer = Timer.periodic(const Duration(hours: 1), (timer) async {
        await _performAnalysis(phoneNumber);
      });

      _isRunning = true;
      print('Periodic health analysis started successfully');
      print('Next analysis in: 1 hour');
    } catch (e) {
      print('Error starting health analysis service: $e');
      _isRunning = false;
    }
    print('==========================\n');
  }

  Future<void> _performAnalysis(String phoneNumber) async {
    print('\n=== Performing Health Analysis ===');
    print('Phone Number: $phoneNumber');
    print('Timestamp: ${DateTime.now()}');

    try {
      await _apiService.analyzeHealth(phoneNumber);
      await _updateLastAnalysisTime();
      print('Health analysis completed successfully');
    } catch (e) {
      print('Error performing health analysis: $e');
    }
    print('==========================\n');
  }

  Future<void> stopPeriodicAnalysis() async {
    print('\n=== Stopping Health Analysis Service ===');
    _analysisTimer?.cancel();
    _isRunning = false;
    print('Service stopped successfully');
    print('==========================\n');
  }

  Future<DateTime?> getLastAnalysisTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt('last_health_analysis');
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  Future<void> _updateLastAnalysisTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        'last_health_analysis', DateTime.now().millisecondsSinceEpoch);
  }
}
