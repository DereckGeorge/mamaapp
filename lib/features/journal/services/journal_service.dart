import 'dart:async';
import 'dart:math';
import '../models/journal_entry.dart';

class JournalService {
  final Map<String, List<JournalEntry>> _journalEntries = {};
  Future<List<JournalEntry>> getEntriesForMonth(String userId, DateTime month) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final entries = _journalEntries[userId] ?? [];
    return entries.where((entry) => 
      entry.date.year == month.year && 
      entry.date.month == month.month
    ).toList();
  }

  Future<JournalEntry> addEntry(String userId, String content, DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final entry = JournalEntry(
      id: _generateId(),
      content: content,
      date: date,
      userId: userId,
    );

    if (!_journalEntries.containsKey(userId)) {
      _journalEntries[userId] = [];
    }
    
    _journalEntries[userId]!.add(entry);
    return entry;
  }

  Future<void> deleteEntry(String userId, String entryId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (_journalEntries.containsKey(userId)) {
      _journalEntries[userId]!.removeWhere((entry) => entry.id == entryId);
    }
  }

  Future<JournalEntry> updateEntry(String userId, String entryId, String content) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (_journalEntries.containsKey(userId)) {
      final index = _journalEntries[userId]!.indexWhere((entry) => entry.id == entryId);
      if (index != -1) {
        final oldEntry = _journalEntries[userId]![index];
        final updatedEntry = JournalEntry(
          id: entryId,
          content: content,
          date: oldEntry.date,
          userId: userId,
        );
        _journalEntries[userId]![index] = updatedEntry;
        return updatedEntry;
      }
    }
    throw Exception('Entry not found');
  }

  // Generate a random ID
  String _generateId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return List.generate(10, (index) => chars[random.nextInt(chars.length)]).join();
  }
} 