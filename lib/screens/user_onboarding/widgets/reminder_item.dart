import 'package:flutter/material.dart';
import '../models/reminder_model.dart';
import 'package:intl/intl.dart';

class ReminderItem extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onDelete;
  final Function(bool) onStatusChanged;

  const ReminderItem({
    super.key,
    required this.reminder,
    required this.onDelete,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (reminder.type == "medicine") ...[
                  if (reminder.medicineDetails != null) ...[
                    // Show dose if available
                    if (reminder.medicineDetails!['dose'] != null &&
                        reminder.doseUnit != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${reminder.medicineDetails!['dose']} ${reminder.doseUnit}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    // Add other medicine details here if needed
                  ],
                ] else if (reminder.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    reminder.subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM dd, yyyy HH:mm')
                      .format(reminder.reminderTime),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: reminder.status,
            onChanged: onStatusChanged,
            activeColor: const Color(0xFFCB4172),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
