import 'package:flutter/material.dart';
import 'package:mamaapp/models/user_model.dart';
import 'package:mamaapp/screens/user_onboarding/cycle_date_screen.dart';
import 'package:mamaapp/screens/user_onboarding/gestational_period_screen.dart';
import 'package:mamaapp/screens/user_onboarding/pregnancy_info_screen.dart';

class PregnancyKnowledgeScreen extends StatefulWidget {
  final UserPregnancyData pregnancyData;
  final bool isFirstChild;
  final String ageGroup;

  const PregnancyKnowledgeScreen({
    super.key,
    required this.pregnancyData,
    required this.isFirstChild,
    required this.ageGroup,
  });

  @override
  State<PregnancyKnowledgeScreen> createState() =>
      _PregnancyKnowledgeScreenState();
}

class _PregnancyKnowledgeScreenState extends State<PregnancyKnowledgeScreen> {
  String? _selectedOption;

  void _selectOption(String option) {
    setState(() {
      _selectedOption = option;
    });

    // Continue to next screen after selection
    _continueToNextScreen(option);
  }

  void _continueToNextScreen(String option) {
    final updatedPregnancyData = widget.pregnancyData.copyWith();

    Widget nextScreen;
    switch (option) {
      case 'First day of the cycle':
        nextScreen = CycleDateScreen(
          pregnancyData: updatedPregnancyData,
          isFirstChild: widget.isFirstChild,
          ageGroup: widget.ageGroup,
        );
        break;
      case 'Gestational period':
        nextScreen = GestationalPeriodScreen(
          pregnancyData: updatedPregnancyData,
          isFirstChild: widget.isFirstChild,
          ageGroup: widget.ageGroup,
        );
        break;
      default:
        return; // Don't navigate if no valid option is selected
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => nextScreen),
    );
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
                    'What you know',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFCB4172),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Option buttons
                  _buildOptionButton(
                    'First day of the cycle',
                    isSelected: _selectedOption == 'First day of the cycle',
                  ),
                  const SizedBox(height: 16),
                  _buildOptionButton(
                    'Gestational period',
                    isSelected: _selectedOption == 'Gestational period',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(
    String label, {
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
        onPressed: () => _selectOption(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: label,
              groupValue: _selectedOption,
              onChanged: (value) => _selectOption(value!),
              activeColor: Colors.white,
              fillColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.selected)) {
                    return Colors.white;
                  }
                  return const Color(0xFFCB4172);
                },
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
