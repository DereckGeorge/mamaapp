import 'package:flutter/material.dart';
import 'package:mamaapp/models/user_model.dart';
import 'package:mamaapp/screens/user_onboarding/age_selection_screen.dart';

class FirstChildScreen extends StatefulWidget {
  const FirstChildScreen({super.key});

  @override
  State<FirstChildScreen> createState() => _FirstChildScreenState();
}

class _FirstChildScreenState extends State<FirstChildScreen> {
  String? _selectedOption;

  void _selectOption(String option) {
    setState(() {
      _selectedOption = option;
    });

    // Continue to next screen after selection
    _continueToNextScreen();
  }

  void _continueToNextScreen() {
    // Create initial pregnancy data
    final pregnancyData = UserPregnancyData(
      dueDate: DateTime.now().add(const Duration(days: 280)),
      weeksPregnant: 0,
      pregnancyStage: 'First trimester',
      isFirstChild: _selectedOption == 'Yes',
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AgeSelectionScreen(
          pregnancyData: pregnancyData,
          isFirstChild: _selectedOption == 'Yes',
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
                    'Is this your first Child?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFCB4172),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Yes button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _selectOption('Yes'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedOption == 'Yes'
                            ? const Color(0xFFCB4172)
                            : const Color(0xFFFAE0E7),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Yes',
                        style: TextStyle(
                          color: _selectedOption == 'Yes'
                              ? Colors.white
                              : const Color(0xFFCB4172),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // No button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _selectOption('No'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedOption == 'No'
                            ? const Color(0xFFCB4172)
                            : const Color(0xFFFAE0E7),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'No',
                        style: TextStyle(
                          color: _selectedOption == 'No'
                              ? Colors.white
                              : const Color(0xFFCB4172),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
