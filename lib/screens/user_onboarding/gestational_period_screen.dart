import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mamaapp/models/user_model.dart';
import 'package:mamaapp/screens/user_onboarding/pregnancy_info_screen.dart';

class GestationalPeriodScreen extends StatefulWidget {
  final UserPregnancyData pregnancyData;
  final bool isFirstChild;
  final String ageGroup;

  const GestationalPeriodScreen({
    super.key,
    required this.pregnancyData,
    required this.isFirstChild,
    required this.ageGroup,
  });

  @override
  State<GestationalPeriodScreen> createState() =>
      _GestationalPeriodScreenState();
}

class _GestationalPeriodScreenState extends State<GestationalPeriodScreen> {
  int _selectedWeeks = 0;
  int _selectedDays = 0;

  void _continueToNextScreen() {
    // Calculate total days pregnant
    final totalDays = (_selectedWeeks * 7) + _selectedDays;

    // Calculate due date based on gestational age
    final dueDate = DateTime.now().add(Duration(days: 280 - totalDays));

    // Calculate weeks pregnant
    final weeksPregnant = _selectedWeeks;

    // Determine pregnancy stage
    String pregnancyStage = 'First trimester';
    if (weeksPregnant >= 13 && weeksPregnant < 27) {
      pregnancyStage = 'Second trimester';
    } else if (weeksPregnant >= 27) {
      pregnancyStage = 'Third trimester';
    }

    final updatedPregnancyData = widget.pregnancyData.copyWith(
      dueDate: dueDate,
      weeksPregnant: weeksPregnant,
      pregnancyStage: pregnancyStage,
      gestationalPeriod: _selectedWeeks,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PregnancyInfoScreen(
          pregnancyData: updatedPregnancyData,
          isFirstChild: widget.isFirstChild,
          ageGroup: widget.ageGroup,
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

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gestational period',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFCB4172),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Select your current gestational age',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Gestational Period Picker
                    Expanded(
                      child: Row(
                        children: [
                          // Weeks Picker
                          Expanded(
                            child: Column(
                              children: [
                                const Text(
                                  'Weeks',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFFCB4172),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: CupertinoPicker(
                                    itemExtent: 50,
                                    onSelectedItemChanged: (index) {
                                      setState(() {
                                        _selectedWeeks = index;
                                      });
                                    },
                                    children:
                                        List<Widget>.generate(42, (index) {
                                      return Center(
                                        child: Text(
                                          '$index',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            color: Color(0xFFCB4172),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Days Picker
                          Expanded(
                            child: Column(
                              children: [
                                const Text(
                                  'Days',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFFCB4172),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: CupertinoPicker(
                                    itemExtent: 50,
                                    onSelectedItemChanged: (index) {
                                      setState(() {
                                        _selectedDays = index;
                                      });
                                    },
                                    children: List<Widget>.generate(7, (index) {
                                      return Center(
                                        child: Text(
                                          '$index',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            color: Color(0xFFCB4172),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _continueToNextScreen,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFCB4172),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
