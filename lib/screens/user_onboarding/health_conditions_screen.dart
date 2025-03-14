import 'package:flutter/material.dart';
import 'package:mamaapp/models/user_model.dart';
import 'package:mamaapp/services/api_service.dart';
import 'package:mamaapp/screens/user_onboarding/symptoms_screen.dart';

class HealthConditionsScreen extends StatefulWidget {
  final UserPregnancyData pregnancyData;

  const HealthConditionsScreen({
    super.key,
    required this.pregnancyData,
  });

  @override
  State<HealthConditionsScreen> createState() => _HealthConditionsScreenState();
}

class _HealthConditionsScreenState extends State<HealthConditionsScreen> {
  final ApiService _apiService = ApiService();
  List<String> _healthConditions = [];
  List<String> _selectedConditions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHealthConditions();
  }

  Future<void> _loadHealthConditions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final conditions = await _apiService.getHealthConditions();
      setState(() {
        _healthConditions = conditions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading health conditions: $e')),
        );
      }
    }
  }

  void _toggleCondition(String condition) {
    setState(() {
      if (_selectedConditions.contains(condition)) {
        _selectedConditions.remove(condition);
      } else {
        // If "None of the above" is selected, clear other selections
        if (condition == 'None of the above') {
          _selectedConditions.clear();
        } else {
          // If another condition is selected, remove "None of the above"
          _selectedConditions.remove('None of the above');
        }
        _selectedConditions.add(condition);
      }
    });
  }

  void _continueToNextScreen() {
    final updatedPregnancyData = widget.pregnancyData.copyWith(
      healthConditions: _selectedConditions,
    );
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SymptomsScreen(pregnancyData: updatedPregnancyData),
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
        title: const Text(
          'Health Conditions',
          style: TextStyle(
            color: Color(0xFFCB4172),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFCB4172)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Do you have any health conditions?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Select all that apply to you',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Health Conditions List
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFCB4172),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _healthConditions.length,
                        itemBuilder: (context, index) {
                          final condition = _healthConditions[index];
                          final isSelected = _selectedConditions.contains(condition);
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: InkWell(
                              onTap: () => _toggleCondition(condition),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFFAE0E7)
                                      : const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFFCB4172)
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        condition,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      const Icon(
                                        Icons.check_circle,
                                        color: Color(0xFFCB4172),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              
              const SizedBox(height: 20),
              
              // Continue Button
              ElevatedButton(
                onPressed: _selectedConditions.isEmpty ? null : _continueToNextScreen,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCB4172),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey.shade300,
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
            ],
          ),
        ),
      ),
    );
  }
} 