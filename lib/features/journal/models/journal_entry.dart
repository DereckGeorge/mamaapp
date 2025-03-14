import 'package:intl/intl.dart';

class JournalEntry {
  final String id;
  final String content;
  final DateTime date;
  final String userId;

  JournalEntry({
    required this.id,
    required this.content,
    required this.date,
    required this.userId,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] as String,
      content: json['content'] as String,
      date: DateTime.parse(json['date'] as String),
      userId: json['userId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'date': date.toIso8601String(),
      'userId': userId,
    };
  }

  String get formattedDate => DateFormat('MMMM dd, yyyy').format(date);
} 