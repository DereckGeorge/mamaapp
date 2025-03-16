import 'package:flutter/material.dart';
import 'package:mamaapp/models/user_model.dart';
import 'package:mamaapp/services/api_service.dart';
import 'package:mamaapp/screens/home_screen.dart';
import 'package:mamaapp/screens/user_onboarding/summary_screen.dart';

class GenderSelectionScreen extends StatefulWidget {
  final UserPregnancyData pregnancyData;
  final bool isFirstChild;
  final String ageGroup;
  final DateTime? dueDate;
  final DateTime? firstDayCircle;
  final int? gestationalPeriod;

  const GenderSelectionScreen({
    super.key,
    required this.pregnancyData,
    required this.isFirstChild,
    required this.ageGroup,
    this.dueDate,
    this.firstDayCircle,
    this.gestationalPeriod,
  });

  @override
  State<GenderSelectionScreen> createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  final ApiService _apiService = ApiService();
  bool _isSubmitting = false;
  String? _selectedGender;

  void _selectGender(String gender) {
    setState(() {
      _selectedGender = gender;
    });

    // Continue to next screen after selection
    _continueToNextScreen();
  }

  Future<void> _continueToNextScreen() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      await _apiService.storeMamaData(
        isFirstChild: widget.isFirstChild,
        ageGroup: widget.ageGroup,
        babyGender: _selectedGender,
        dueDate: widget.dueDate,
        firstDayCircle: widget.firstDayCircle,
        gestationalPeriod: widget.gestationalPeriod,
      );

      // Update pregnancy data with selected gender
      final updatedPregnancyData = widget.pregnancyData.copyWith(
        babyGender: _selectedGender,
      );

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your pregnancy information has been saved!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to SummaryScreen instead of HomeScreen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => SummaryScreen(
            pregnancyData: updatedPregnancyData,
          ),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pink wave decoration
            Container(
              height: 40,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/pink_wave.png'),
                  fit: BoxFit.fill,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Choose baby\'s gender',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFCB4172),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Gender selection buttons
                  _buildGenderButton(
                    label: 'Girl',
                    isSelected: _selectedGender == 'Girl',
                  ),
                  const SizedBox(height: 16),
                  _buildGenderButton(
                    label: 'Boy',
                    isSelected: _selectedGender == 'Boy',
                  ),
                  const SizedBox(height: 16),
                  _buildGenderButton(
                    label: 'I do not know yet',
                    isSelected: _selectedGender == 'Unknown',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderButton({
    required String label,
    bool isSelected = false,
    bool isPrimary = false,
  }) {
    final backgroundColor = isPrimary
        ? const Color(0xFFCB4172)
        : isSelected
            ? const Color(0xFFCB4172)
            : const Color(0xFFFAE0E7);

    final textColor = isPrimary
        ? Colors.white
        : isSelected
            ? Colors.white
            : const Color(0xFFCB4172);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () =>
            _selectGender(label == 'I do not know yet' ? 'Unknown' : label),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
