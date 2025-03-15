import 'package:flutter/material.dart';
import 'package:mamaapp/models/user_model.dart';
import 'package:mamaapp/screens/user_onboarding/pregnancy_knowledge_screen.dart';

class AgeSelectionScreen extends StatefulWidget {
  final UserPregnancyData pregnancyData;
  final bool isFirstChild;

  const AgeSelectionScreen({
    super.key,
    required this.pregnancyData,
    required this.isFirstChild,
  });

  @override
  State<AgeSelectionScreen> createState() => _AgeSelectionScreenState();
}

class _AgeSelectionScreenState extends State<AgeSelectionScreen> {
  String? _selectedAgeRange;

  void _selectAgeRange(String ageRange) {
    setState(() {
      _selectedAgeRange = ageRange;
    });

    _continueToNextScreen();
  }

  void _continueToNextScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PregnancyKnowledgeScreen(
          pregnancyData: widget.pregnancyData,
          isFirstChild: widget.isFirstChild,
          ageGroup: _selectedAgeRange!,
        ),
      ),
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
                    'Enter your age',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFCB4172),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Age range buttons
                  _buildAgeRangeButton('18-24 years old'),
                  const SizedBox(height: 16),
                  _buildAgeRangeButton('25-34 years old'),
                  const SizedBox(height: 16),
                  _buildAgeRangeButton('35-44 years old'),
                  const SizedBox(height: 16),
                  _buildAgeRangeButton('44 years old or above'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgeRangeButton(String ageRange) {
    final isSelected = _selectedAgeRange == ageRange;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _selectAgeRange(ageRange),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isSelected ? const Color(0xFFCB4172) : const Color(0xFFFAE0E7),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          ageRange,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFFCB4172),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
