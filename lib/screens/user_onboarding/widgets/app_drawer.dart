import 'package:flutter/material.dart';
import 'package:mamaapp/features/journal/screens/journal_screen.dart';
import '../screens/reminders_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/health_tips_screen.dart';
import '../screens/symptoms_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFFFAE0E7),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 10),
                Text(
                  'Maryline Swai',
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Color(0xFFCB4172)),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.lightbulb_outline, color: Color(0xFFCB4172)),
            title: const Text('Health tips'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HealthTipsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined, color: Color(0xFFCB4172)),
            title: const Text('Reminders'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RemindersScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.book_outlined, color: Color(0xFFCB4172)),
            title: const Text('Personal Journal'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const JournalScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline, color: Color(0xFFCB4172)),
            title: const Text('Add Symptoms'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SymptomsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined, color: Color(0xFFCB4172)),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to settings screen
            },
          ),
        ],
      ),
    );
  }
} 