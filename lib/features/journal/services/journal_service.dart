import 'dart:async';
import '../models/journal_entry.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class JournalService {
  final String baseUrl = dotenv.env['APP_BASE_URL'] ?? '';

  Future<List<JournalEntry>> getJournals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userId = prefs.getString('user_id');

      if (token == null || userId == null) {
        throw Exception('Authentication required');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/journals/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['data'] as List)
            .map((entry) => JournalEntry.fromJson(entry))
            .toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Failed to load journals');
      }
    } catch (e) {
      throw Exception('Error fetching journals: $e');
    }
  }

  Future<void> addJournal(String content) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userId = prefs.getString('user_id');

      if (token == null || userId == null) {
        throw Exception('Authentication required');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/journals'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user_id': userId,
          'content': content,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to create journal entry');
      }
    } catch (e) {
      throw Exception('Error creating journal: $e');
    }
  }

  Future<void> deleteJournal(String journalId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Authentication required');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/api/journals/$journalId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete journal entry');
      }
    } catch (e) {
      throw Exception('Error deleting journal: $e');
    }
  }

  Future<List<JournalEntry>> getEntriesForMonth(
      String userId, DateTime month) async {
    try {
      final entries = await getJournals();
      return entries
          .where((entry) =>
              entry.createdAt.year == month.year &&
              entry.createdAt.month == month.month)
          .toList();
    } catch (e) {
      throw Exception('Error fetching journals for month: $e');
    }
  }

  Future<List<JournalEntry>> getEntriesForDate(DateTime date) async {
    try {
      final entries = await getJournals();
      return entries
          .where((entry) =>
              entry.createdAt.year == date.year &&
              entry.createdAt.month == date.month &&
              entry.createdAt.day == date.day)
          .toList();
    } catch (e) {
      throw Exception('Error fetching journals for date: $e');
    }
  }

  Future<JournalEntry> addEntry(
      String userId, String content, DateTime date) async {
    try {
      await addJournal(content);
      final entries = await getJournals();
      return entries.first; // Return the most recently created entry
    } catch (e) {
      throw Exception('Error adding journal entry: $e');
    }
  }
}
