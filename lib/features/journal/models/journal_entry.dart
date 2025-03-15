import 'package:intl/intl.dart';

class JournalEntry {
  final int id;
  final String content;
  final int userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  JournalEntry({
    required this.id,
    required this.content,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'],
      content: json['content'],
      userId: json['user_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  String get formattedDate => DateFormat('MMMM dd, yyyy').format(createdAt);
}
