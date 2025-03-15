import 'package:flutter/material.dart';
import 'dart:convert';

enum ReminderType {
  doctorAppointment,
  medicine,
  medicalTest,
}

class Reminder {
  final String id;
  final String type;
  final String? appointment;
  final DateTime reminderTime;
  final String? doseUnit;
  final Map<String, dynamic>? medicineDetails;
  final bool status;

  Reminder({
    required this.id,
    required this.type,
    this.appointment,
    required this.reminderTime,
    this.doseUnit,
    this.medicineDetails,
    required this.status,
  });

  String get title {
    switch (type) {
      case "doctor's appointment":
        return appointment ?? 'Doctor Appointment';
      case "medicine":
        if (medicineDetails != null && medicineDetails!['name'] != null) {
          return medicineDetails!['name'];
        }
        return 'Medicine';
      case "medical tests":
        return appointment ?? 'Medical Test';
      default:
        return 'Reminder';
    }
  }

  String get subtitle {
    switch (type) {
      case "medicine":
        if (medicineDetails != null) {
          List<String> details = [];
          if (medicineDetails!['dose'] != null) {
            details.add('${medicineDetails!['dose']} $doseUnit');
          }
          // Add any other medicine details you want to display
          return details.join(' • ');
        }
        return '';
      default:
        return '';
    }
  }

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'].toString(),
      type: json['type'],
      appointment: json['appointment'],
      reminderTime: DateTime.parse(json['reminder_time']),
      doseUnit: json['dose_unit'],
      medicineDetails: json['medicine_details'] != null
          ? jsonDecode(json['medicine_details'])
          : null,
      status: json['status'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'appointment': appointment,
      'reminder_time': reminderTime.toIso8601String(),
      'dose_unit': doseUnit,
      'medicine_details':
          medicineDetails != null ? jsonEncode(medicineDetails) : null,
      'status': status,
    };
  }
}
