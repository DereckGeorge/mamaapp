import 'package:flutter/material.dart';
import '../models/reminder_model.dart';

class ReminderItem extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onDelete;

  const ReminderItem({
    super.key,
    required this.reminder,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                const SizedBox(height: 4),
                Text(
                  '${reminder.formattedDate},   ${reminder.formattedTime}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: reminder.isActive,
            onChanged: (value) {
              // In a real app, this would update the reminder's active state
            },
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFFCB4172),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey[300],
          ),
        ],
      ),
    );
  }
} 