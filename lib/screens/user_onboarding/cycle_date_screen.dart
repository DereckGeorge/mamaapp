import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:mamaapp/models/user_model.dart';
import 'package:mamaapp/screens/user_onboarding/pregnancy_info_screen.dart';

class CycleDateScreen extends StatefulWidget {
  final UserPregnancyData pregnancyData;
  final bool isFirstChild;
  final String ageGroup;

  const CycleDateScreen({
    super.key,
    required this.pregnancyData,
    required this.isFirstChild,
    required this.ageGroup,
  });

  @override
  State<CycleDateScreen> createState() => _CycleDateScreenState();
}

class _CycleDateScreenState extends State<CycleDateScreen> {
  late DateTime _selectedDate;
  final List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  void _continueToNextScreen() {
    final updatedPregnancyData = widget.pregnancyData.copyWith(
      firstDayCircle: _selectedDate,
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
                      'First day of the cycle',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFCB4172),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Select the first day of your last menstrual period',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Date Picker
                    Expanded(
                      child: Row(
                        children: [
                          // Day Picker
                          Expanded(
                            child: CupertinoPicker(
                              itemExtent: 50,
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  _selectedDate = DateTime(
                                    _selectedDate.year,
                                    _selectedDate.month,
                                    index + 1,
                                  );
                                });
                              },
                              children: List<Widget>.generate(31, (index) {
                                return Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Color(0xFFCB4172),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                          // Month Picker
                          Expanded(
                            flex: 2,
                            child: CupertinoPicker(
                              itemExtent: 50,
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  _selectedDate = DateTime(
                                    _selectedDate.year,
                                    index + 1,
                                    _selectedDate.day,
                                  );
                                });
                              },
                              children: _months.map((month) {
                                return Center(
                                  child: Text(
                                    month,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Color(0xFFCB4172),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          // Year Picker
                          Expanded(
                            child: CupertinoPicker(
                              itemExtent: 50,
                              onSelectedItemChanged: (index) {
                                final year = DateTime.now().year - index;
                                setState(() {
                                  _selectedDate = DateTime(
                                    year,
                                    _selectedDate.month,
                                    _selectedDate.day,
                                  );
                                });
                              },
                              children: List<Widget>.generate(2, (index) {
                                return Center(
                                  child: Text(
                                    '${DateTime.now().year - index}',
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

                    const SizedBox(height: 20),

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
