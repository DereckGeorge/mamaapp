import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/reminder_model.dart';

class ReminderService {
  // Mock data storage
  final List<Reminder> _reminders = [
    Reminder(
      id: '1',
      title: 'Visit to a therapist',
      date: DateTime(2025, 2, 15),
      time: const TimeOfDay(hour: 14, minute: 30),
      type: ReminderType.doctorAppointment,
    ),
    Reminder(
      id: '2',
      title: 'Visit to a gynecologist',
      date: DateTime(2025, 3, 21),
      time: const TimeOfDay(hour: 15, minute: 30),
      type: ReminderType.doctorAppointment,
    ),
    Reminder(
      id: '3',
      title: 'Vitamin E',
      date: DateTime(2025, 2, 14),
      time: const TimeOfDay(hour: 12, minute: 0),
      type: ReminderType.medicine,
      additionalData: {
        'dosage': 'Twice a day',
      },
    ),
    Reminder(
      id: '4',
      title: 'Folic Acid',
      date: DateTime(2025, 2, 22),
      time: const TimeOfDay(hour: 8, minute: 0),
      type: ReminderType.medicine,
      additionalData: {
        'dosage': 'Once a day',
      },
    ),
    Reminder(
      id: '5',
      title: 'Test appointment',
      date: DateTime(2025, 3, 20),
      time: const TimeOfDay(hour: 17, minute: 0),
      type: ReminderType.medicalTest,
    ),
    Reminder(
      id: '6',
      title: 'Pregnancy appointment',
      date: DateTime(2025, 3, 27),
      time: const TimeOfDay(hour: 13, minute: 0),
      type: ReminderType.medicalTest,
    ),
  ];

  // Get all reminders
  Future<List<Reminder>> getReminders() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));
    return _reminders;
  }

  // Get doctor appointments
  Future<List<Reminder>> getDoctorAppointments() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _reminders.where((r) => r.type == ReminderType.doctorAppointment).toList();
  }

  // Get medicines
  Future<List<Reminder>> getMedicines() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _reminders.where((r) => r.type == ReminderType.medicine).toList();
  }

  // Get medical tests
  Future<List<Reminder>> getMedicalTests() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _reminders.where((r) => r.type == ReminderType.medicalTest).toList();
  }

  // Add a new reminder
  Future<Reminder> addReminder(Reminder reminder) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _reminders.add(reminder);
    return reminder;
  }

  // Update an existing reminder
  Future<Reminder> updateReminder(Reminder reminder) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final index = _reminders.indexWhere((r) => r.id == reminder.id);
    if (index != -1) {
      _reminders[index] = reminder;
      return reminder;
    }
    throw Exception('Reminder not found');
  }

  // Delete a reminder
  Future<void> deleteReminder(String id) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _reminders.removeWhere((r) => r.id == id);
  }

  // Generate a random ID
  String generateId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return List.generate(10, (index) => chars[random.nextInt(chars.length)]).join();
  }
} 