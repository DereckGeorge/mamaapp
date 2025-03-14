import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamaapp/models/user_model.dart';

class PregnancyProgressCard extends StatelessWidget {
  final UserPregnancyData pregnancyData;

  const PregnancyProgressCard({
    super.key,
    required this.pregnancyData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCB4172), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Expected date',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFCB4172),
                ),
              ),
              const Spacer(),
              CircleAvatar(
                backgroundColor: const Color(0xFFFAE0E7),
                radius: 20,
                child: Image.asset(
                  'assets/baby_icon.png',
                  width: 100,
                  height: 100,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('dd MMMM, yyyy').format(pregnancyData.dueDate).toLowerCase(),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                'about the size of a jackfruit',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 12),
              Image.asset(
                'assets/jackfruit.png',
                height: 80,
                fit: BoxFit.contain,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: pregnancyData.weeksPregnant / 40,
              backgroundColor: const Color(0xFFFAE0E7),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFCB4172)),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          // Trimester Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                '1st Trimester',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                '2nd Trimester',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                '3rd Trimester',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 