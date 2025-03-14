import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarWidget extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final List<DateTime> datesWithEntries;

  const CalendarWidget({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.datesWithEntries,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMonthHeader(),
        const SizedBox(height: 20),
        _buildCalendarGrid(),
      ],
    );
  }

  Widget _buildMonthHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => onDateSelected(
            DateTime(selectedDate.year, selectedDate.month - 1),
          ),
        ),
        Text(
          DateFormat('MMMM yyyy').format(selectedDate),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () => onDateSelected(
            DateTime(selectedDate.year, selectedDate.month + 1),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    return Column(
      children: [
        _buildWeekdayHeader(),
        const SizedBox(height: 8),
        _buildDaysGrid(),
      ],
    );
  }

  Widget _buildWeekdayHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: const [
        Text('MON'),
        Text('TUE'),
        Text('WED'),
        Text('THU'),
        Text('FRI'),
        Text('SAT'),
        Text('SUN'),
      ],
    );
  }

  Widget _buildDaysGrid() {
    final daysInMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
    final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;
    
    final days = List.generate(42, (index) {
      final day = index - (firstWeekday - 1);
      if (day < 1 || day > daysInMonth) return null;
      return day;
    });

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 7,
      children: days.map((day) {
        if (day == null) return const SizedBox();
        
        final date = DateTime(selectedDate.year, selectedDate.month, day);
        final hasEntry = datesWithEntries.any((d) => 
          d.year == date.year && 
          d.month == date.month && 
          d.day == date.day
        );
        
        return InkWell(
          onTap: () => onDateSelected(date),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: _isSelectedDate(date) 
                  ? const Color(0xFFCB4172)
                  : hasEntry 
                      ? const Color(0xFFFAE0E7)
                      : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: TextStyle(
                  color: _isSelectedDate(date) ? Colors.white : Colors.black,
                  fontWeight: hasEntry ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  bool _isSelectedDate(DateTime date) {
    return date.year == selectedDate.year &&
           date.month == selectedDate.month &&
           date.day == selectedDate.day;
  }
} 