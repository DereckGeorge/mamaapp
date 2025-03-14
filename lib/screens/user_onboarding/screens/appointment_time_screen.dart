import 'package:flutter/material.dart';

class AppointmentTimeScreen extends StatefulWidget {
  final TimeOfDay initialTime;

  const AppointmentTimeScreen({
    super.key,
    required this.initialTime,
  });

  @override
  State<AppointmentTimeScreen> createState() => _AppointmentTimeScreenState();
}

class _AppointmentTimeScreenState extends State<AppointmentTimeScreen> {
  late int _selectedHour;
  late int _selectedMinute;
  
  @override
  void initState() {
    super.initState();
    _selectedHour = widget.initialTime.hour;
    _selectedMinute = widget.initialTime.minute;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Appointment time',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hours column
                _buildTimeColumn(
                  10, 14, 
                  (index) => index.toString().padLeft(2, '0'),
                  _selectedHour,
                  (value) => setState(() => _selectedHour = value),
                ),
                
                // Separator
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    ':',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                // Minutes column
                _buildTimeColumn(
                  0, 59, 
                  (index) => index.toString().padLeft(2, '0'),
                  _selectedMinute,
                  (value) => setState(() => _selectedMinute = value),
                  step: 1,
                ),
              ],
            ),
          ),
          
          // Bottom buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'CANCEL',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(
                      context, 
                      TimeOfDay(hour: _selectedHour, minute: _selectedMinute),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCB4172),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        color: Colors.white,
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
    );
  }

  Widget _buildTimeColumn(
    int start,
    int end,
    String Function(int) formatter,
    int selectedValue,
    Function(int) onSelected, {
    int step = 1,
  }) {
    final items = <Widget>[];
    
    for (int i = start; i <= end; i += step) {
      final isSelected = i == selectedValue;
      items.add(
        GestureDetector(
          onTap: () => onSelected(i),
          child: Container(
            width: 60,
            height: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFCB4172) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Text(
              formatter(i),
              style: TextStyle(
                fontSize: 24,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      );
    }
    
    return SizedBox(
      width: 80,
      child: ListView(
        children: items,
      ),
    );
  }
} 