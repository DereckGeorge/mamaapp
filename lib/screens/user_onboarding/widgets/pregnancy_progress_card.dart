import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamaapp/models/user_model.dart';
import 'package:mamaapp/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PregnancyProgressCard extends StatefulWidget {
  final UserPregnancyData pregnancyData;

  const PregnancyProgressCard({
    super.key,
    required this.pregnancyData,
  });

  @override
  State<PregnancyProgressCard> createState() => _PregnancyProgressCardState();
}

class _PregnancyProgressCardState extends State<PregnancyProgressCard> {
  DateTime? _dueDate;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMamaData();
  }

  Future<void> _loadMamaData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      if (userId == null) {
        setState(() {
          _error = 'User ID not found';
          _isLoading = false;
        });
        return;
      }

      final apiService = ApiService();
      final response = await apiService.getMamaData(int.parse(userId));

      if (response['status'] == 'success' && response['data'] != null) {
        final mamaData = response['data'];
        setState(() {
          _dueDate = DateTime.parse(mamaData['due_date']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response['message'] ?? 'Failed to load mama data';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading mama data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFCB4172), width: 1),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFCB4172)),
          ),
        ),
      );
    }

    if (_error != null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFCB4172), width: 1),
        ),
        child: Center(
          child: Text(
            _error!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_dueDate == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFCB4172), width: 1),
        ),
        child: const Center(
          child: Text(
            'No due date available',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    // Calculate pregnancy progress
    final progress = _calculatePregnancyProgress(_dueDate!);
    final currentWeek = _calculateCurrentWeek(_dueDate!).toInt();

    // Determine current trimester and fruit size
    String currentTrimester = '';
    String fruitName = '';
    String fruitImagePath = '';

    if (currentWeek <= 13) {
      currentTrimester = '1st Trimester';
      fruitName = 'jackfruit';
      fruitImagePath = 'assets/jackfruit.png';
    } else if (currentWeek <= 26) {
      currentTrimester = '2nd Trimester';
      fruitName = 'banana';
      fruitImagePath = 'assets/banana.png';
    } else {
      currentTrimester = '3rd Trimester';
      fruitName = 'watermelon';
      fruitImagePath = 'assets/watermelon.png';
    }

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
            DateFormat('dd MMMM, yyyy').format(_dueDate!).toLowerCase(),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'about the size of a $fruitName',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Image.asset(
                fruitImagePath,
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
              value: progress,
              backgroundColor: const Color(0xFFFAE0E7),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFFCB4172)),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          // Week indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Week $currentWeek - $currentTrimester',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFCB4172),
                ),
              ),
            ],
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

  /// Calculate pregnancy progress as a value between 0 and 1
  double _calculatePregnancyProgress(DateTime dueDate) {
    final today = DateTime.now();

    // A typical pregnancy lasts about 40 weeks (280 days) from the first day
    // of the last menstrual period to the due date
    final totalPregnancyDays = 280;

    // Calculate the estimated conception date (due date minus 40 weeks)
    final conceptionDate = dueDate.subtract(const Duration(days: 280));

    // Calculate days since conception
    final daysSinceConception = today.difference(conceptionDate).inDays;

    // Calculate progress as a value between 0 and 1
    double progress = daysSinceConception / totalPregnancyDays;

    // Clamp progress between 0 and 1
    return progress.clamp(0.0, 1.0);
  }

  /// Calculate current week of pregnancy
  double _calculateCurrentWeek(DateTime dueDate) {
    final today = DateTime.now();

    // Calculate the estimated conception date (due date minus 40 weeks)
    final conceptionDate = dueDate.subtract(const Duration(days: 280));

    // Calculate days since conception
    final daysSinceConception = today.difference(conceptionDate).inDays;

    // Calculate current week (divide by 7 and add 1)
    double currentWeek = (daysSinceConception / 7) + 1;

    // Clamp between 1 and 40 weeks
    return currentWeek.clamp(1.0, 40.0);
  }
}
