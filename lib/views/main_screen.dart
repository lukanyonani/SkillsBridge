import 'package:flutter/material.dart';
import 'package:skillsbridge/constants/theme.dart';
import 'package:skillsbridge/views/bursary/btest.dart';
//import 'package:skillsbridge/views/bursary/bursary_screen.dart';
import 'package:skillsbridge/views/counsellor/counsellor_screen.dart';
import 'package:skillsbridge/views/home/home_screen.dart';
import 'package:skillsbridge/views/jobs/jobs_screen.dart';
import 'package:skillsbridge/views/learning/ltest.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  // Create instances of your screens
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(),
      LearningTesterHubScreen(), // Your existing learning screen
      AICouncelorScreen(), // Your existing AI counselor screen
      JobPortalScreen(),
      BursaryFinderTestScreen(), // Your existing bursary screen
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceWhite,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', 0),
              _buildNavItem(Icons.book, 'Learn', 1),
              _buildNavItem(Icons.smart_toy, 'AI Guide', 2),
              _buildNavItem(Icons.work, 'Jobs', 3),
              _buildNavItem(Icons.school, 'Bursaries', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24,
            color: isActive ? const Color(0xFF2563EB) : const Color(0xFF6B7280),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isActive
                  ? const Color(0xFF2563EB)
                  : const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}
