import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_bottom_navigation.dart';
import '../models/reminder_model.dart';
import '../services/reminder_service.dart';
import '../widgets/reminder_item.dart';
import '../screens/doctor_appointment_screen.dart';
import '../screens/medicine_dosage_screen.dart';
import '../screens/medical_test_screen.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ReminderService _reminderService = ReminderService();
  List<Reminder> _doctorAppointments = [];
  List<Reminder> _medicines = [];
  List<Reminder> _medicalTests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    setState(() => _isLoading = true);
    try {
      final doctorAppointments = await _reminderService.getDoctorAppointments();
      final medicines = await _reminderService.getMedicines();
      final medicalTests = await _reminderService.getMedicalTests();
      
      setState(() {
        _doctorAppointments = doctorAppointments;
        _medicines = medicines;
        _medicalTests = medicalTests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading reminders: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text(
          'Reminders',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black),
            onPressed: () {
              // Handle settings
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFCB4172)))
          : RefreshIndicator(
              onRefresh: _loadReminders,
              color: const Color(0xFFCB4172),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  margin: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Doctor's Appointments Section
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: _buildSectionHeader(
                          'Doctor\'s appointment',
                          () => _navigateToAddScreen(const DoctorAppointmentScreen()),
                        ),
                      ),
                      _buildRemindersList(_doctorAppointments),
                      
                      const Divider(height: 1),
                      
                      // Medicines Section
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: _buildSectionHeader(
                          'Medicines',
                          () => _navigateToAddScreen(const MedicineDosageScreen()),
                        ),
                      ),
                      _buildRemindersList(_medicines),
                      
                      const Divider(height: 1),
                      
                      // Medical Tests Section
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: _buildSectionHeader(
                          'Medical tests',
                          () => _navigateToAddScreen(const MedicalTestScreen()),
                        ),
                      ),
                      _buildRemindersList(_medicalTests),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 0,
        onTap: (index) {
          // Handle navigation
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onAddPressed) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        TextButton.icon(
          onPressed: onAddPressed,
          icon: const Icon(Icons.add, color: Color(0xFFCB4172), size: 18),
          label: Text(
            'ADD ${title.toUpperCase()}',
            style: const TextStyle(
              color: Color(0xFFCB4172),
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }

  Widget _buildRemindersList(List<Reminder> reminders) {
    if (reminders.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Center(
          child: Text(
            'No reminders added yet',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: reminders.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              ReminderItem(
                reminder: reminders[index],
                onDelete: () async {
                  await _reminderService.deleteReminder(reminders[index].id);
                  _loadReminders();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _navigateToAddScreen(Widget screen) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
    
    if (result == true) {
      _loadReminders();
    }
  }
} 