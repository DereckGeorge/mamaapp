import 'package:flutter/material.dart';

enum ReminderType {
  doctorAppointment,
  medicine,
  medicalTest,
}

class Reminder {
  final String id;
  final String title;
  final DateTime date;
  final TimeOfDay time;
  final ReminderType type;
  final bool isActive;
  final Map<String, dynamic>? additionalData;

  Reminder({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.type,
    this.isActive = true,
    this.additionalData,
  });

  String get formattedDate {
    final day = date.day;
    final month = _getMonthName(date.month);
    final year = date.year;
    return '$day $month $year';
  }

  String get formattedTime {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'],
      title: json['title'],
      date: DateTime.parse(json['date']),
      time: TimeOfDay(
        hour: int.parse(json['time'].split(':')[0]),
        minute: int.parse(json['time'].split(':')[1]),
      ),
      type: ReminderType.values.firstWhere(
        (e) => e.toString() == 'ReminderType.${json['type']}',
      ),
      isActive: json['isActive'] ?? true,
      additionalData: json['additionalData'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'time': '${time.hour}:${time.minute}',
      'type': type.toString().split('.').last,
      'isActive': isActive,
      'additionalData': additionalData,
    };
  }
} 