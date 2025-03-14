import 'package:flutter/material.dart';
import 'package:mamaapp/models/user_model.dart';
import 'package:mamaapp/services/api_service.dart';
import 'package:mamaapp/screens/user_onboarding/summary_screen.dart';

class GenderSelectionScreen extends StatefulWidget {
  final UserPregnancyData pregnancyData;

  const GenderSelectionScreen({
    super.key,
    required this.pregnancyData,
  });

  @override
  State<GenderSelectionScreen> createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  String? _selectedGender;

  void _selectGender(String gender) {
    setState(() {
      _selectedGender = gender;
    });
    
    // Continue to next screen after selection
    _continueToNextScreen();
  }

  void _continueToNextScreen() {
    final updatedPregnancyData = widget.pregnancyData.copyWith(
      // Add gender to pregnancy data if needed
    );
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SummaryScreen(pregnancyData: updatedPregnancyData),
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
        onPressed: () => _selectGender(label == 'I do not know yet' ? 'Unknown' : label),
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