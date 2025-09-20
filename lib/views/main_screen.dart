import 'package:flutter/material.dart';
import 'package:skillsbridge/constants/theme.dart';
import 'package:skillsbridge/views/bursary/bursary_screen.dart';
import 'package:skillsbridge/views/counsellor/councillor_screen.dart';
import 'package:skillsbridge/views/home/home_screen.dart';
import 'package:skillsbridge/views/jobs/jobs_screen.dart';
import 'package:skillsbridge/views/learning/learning_screen.dart';
import 'package:skillsbridge/utils/navigation_service.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with TabSwitcher {
  int _currentIndex = 0;

  // Create instances of your screens
  late final List<Widget> _screens;
  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(),
      LearningHubScreen(), // Your existing learning screen
      AICouncillorScreen(), // Your existing AI counselor screen
      JobPortalScreen(),
      BursaryFinderScreen(), // Your existing bursary screen
    ];

    // Register this state with the navigation service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NavigationService.registerMainNavigation(this);
    });
  }

  @override
  void dispose() {
    NavigationService.unregisterMainNavigation();
    super.dispose();
  }

  @override
  void switchToTab(int tabIndex) {
    debugPrint(
      '🔄 MainNavigationScreen: switchToTab called with index $tabIndex',
    );
    if (tabIndex >= 0 && tabIndex < _screens.length) {
      setState(() {
        _currentIndex = tabIndex;
      });
      debugPrint(
        '✅ MainNavigationScreen: Successfully switched to tab $tabIndex',
      );
    } else {
      debugPrint(
        '❌ MainNavigationScreen: Invalid tab index $tabIndex (valid range: 0-${_screens.length - 1})',
      );
    }
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
              _buildNavItem(Icons.smart_toy, 'AI Counsellor', 2),
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
