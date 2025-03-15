import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reminder_model.dart';

class ReminderService {
  final String baseUrl = dotenv.env['APP_BASE_URL'] ?? '';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  // Get all reminders for the user
  Future<List<Reminder>> getReminders() async {
    try {
      final userId = await _getUserId();
      if (userId == null) throw Exception('User ID not found');

      final response = await http.get(
        Uri.parse('$baseUrl/api/reminders/$userId'),
        headers: {
          'Authorization': 'Bearer ${await _getToken()}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final reminders = (data['data'] as List)
            .map((item) => Reminder.fromJson(item))
            .toList();
        return reminders;
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Failed to load reminders');
      }
    } catch (e) {
      print('Error getting reminders: $e');
      rethrow;
    }
  }

  // Create a new reminder
  Future<void> createReminder({
    required String type,
    String? appointment,
    required DateTime reminderTime,
    String? doseUnit,
    Map<String, dynamic>? medicineDetails,
    String? question,
  }) async {
    try {
      final userId = await _getUserId();
      if (userId == null) throw Exception('User ID not found');

      final response = await http.post(
        Uri.parse('$baseUrl/api/reminders'),
        headers: {
          'Authorization': 'Bearer ${await _getToken()}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user_id': int.parse(userId),
          'type': type,
          'appointment': appointment,
          'reminder_time': reminderTime.toIso8601String(),
          'dose_unit': doseUnit,
          'medicine_details': medicineDetails,
          'question': question,
        }),
      );

      if (response.statusCode != 201) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to create reminder');
      }
    } catch (e) {
      print('Error creating reminder: $e');
      rethrow;
    }
  }

  // Update reminder status
  Future<void> updateReminderStatus(String id, bool status) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/api/reminders/$id/status'),
        headers: {
          'Authorization': 'Bearer ${await _getToken()}',
          'Content-Type': 'application/json',
        },
        body: json.encode({'status': status}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update reminder status');
      }
    } catch (e) {
      print('Error updating reminder status: $e');
      rethrow;
    }
  }

  // Get reminders by type
  Future<List<Reminder>> getDoctorAppointments() async {
    final reminders = await getReminders();
    return reminders.where((r) => r.type == "doctor's appointment").toList();
  }

  Future<List<Reminder>> getMedicines() async {
    final reminders = await getReminders();
    return reminders.where((r) => r.type == "medicine").toList();
  }

  Future<List<Reminder>> getMedicalTests() async {
    final reminders = await getReminders();
    return reminders.where((r) => r.type == "medical tests").toList();
  }

  // Add a new reminder
  Future<Reminder> addReminder(Reminder reminder) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // Implementation needed
    throw UnimplementedError();
  }

  // Update an existing reminder
  Future<Reminder> updateReminder(Reminder reminder) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // Implementation needed
    throw UnimplementedError();
  }

  // Delete a reminder
  Future<void> deleteReminder(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/reminders/$id'),
        headers: {
          'Authorization': 'Bearer ${await _getToken()}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete reminder');
      }
    } catch (e) {
      print('Error deleting reminder: $e');
      rethrow;
    }
  }

  // Generate a random ID
  String generateId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return List.generate(10, (index) => chars[random.nextInt(chars.length)])
        .join();
  }
}
