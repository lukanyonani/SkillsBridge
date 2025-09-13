import 'package:flutter/material.dart';

class HomeScreenViewModel extends ChangeNotifier {
  // User data
  String _userName = 'Lukanyo';
  String _greeting = 'Welcome back';

  // Stats data
  final Map<String, dynamic> _userStats = {
    'skillsAssessed': 12,
    'jobMatches': 8,
    'activeCourses': 3,
    'applications': 5,
  };

  // Current learning data
  final Map<String, dynamic> _currentCourse = {
    'title': 'Python for Data Science',
    'module': 'Module 3: Data Visualization',
    'timeLeft': '2 hours left',
    'progress': 0.65,
    'icon': '🐍',
  };

  // Recommended jobs data
  final List<Map<String, dynamic>> _recommendedJobs = [
    {
      'companyLogo': '🏢',
      'jobTitle': 'Junior Data Analyst',
      'companyName': 'TechCorp SA',
      'location': '📍 Cape Town',
      'salary': '💰 R15-20k',
      'workType': '🏠 Hybrid',
      'matchPercentage': '85%',
    },
    {
      'companyLogo': '🏦',
      'jobTitle': 'IT Support Intern',
      'companyName': 'First National Bank',
      'location': '📍 Johannesburg',
      'salary': '💰 R8-12k',
      'workType': '🏢 On-site',
      'matchPercentage': '78%',
    },
    {
      'companyLogo': '💻',
      'jobTitle': 'Web Developer',
      'companyName': 'Digital Dreams',
      'location': '📍 Remote',
      'salary': '💰 R18-25k',
      'workType': '🌍 Remote',
      'matchPercentage': '72%',
    },
  ];

  // Upcoming deadlines data
  final List<Map<String, dynamic>> _upcomingDeadlines = [
    {
      'title': 'NSFAS Application',
      'amount': 'Up to R90,000',
      'deadline': '⏰ Closes in 2 days',
      'isUrgent': true,
    },
    {
      'title': 'MTN Tech Scholarship',
      'amount': 'R50,000',
      'deadline': '⏰ Closes in 5 days',
      'isUrgent': false,
    },
    {
      'title': 'Google Career Certificates',
      'amount': 'Full Funding',
      'deadline': '⏰ Closes in 10 days',
      'isUrgent': false,
    },
  ];

  // Getters
  String get userName => _userName;
  String get greeting => _greeting;
  Map<String, dynamic> get userStats => _userStats;
  Map<String, dynamic> get currentCourse => _currentCourse;
  List<Map<String, dynamic>> get recommendedJobs => _recommendedJobs;
  List<Map<String, dynamic>> get upcomingDeadlines => _upcomingDeadlines;

  // Initialize the view model
  void initialize() {
    _updateGreeting();
    // You can add other initialization logic here
    // e.g., fetch user data from API, load preferences, etc.
  }

  // Update greeting based on time of day
  void _updateGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      _greeting = 'Good morning';
    } else if (hour < 17) {
      _greeting = 'Good afternoon';
    } else {
      _greeting = 'Good evening';
    }
    notifyListeners();
  }

  // Methods for user interactions
  void onStatCardTapped(String statType) {
    // Handle stat card tap - navigate to relevant screen
    debugPrint('Stat card tapped: $statType');
    // You can add navigation logic here
  }

  void onContinueCourseTapped() {
    // Handle continue course tap
    debugPrint('Continue course tapped: ${_currentCourse['title']}');
    // Navigate to course details or resume course
  }

  void onJobCardTapped(Map<String, dynamic> job) {
    // Handle job card tap
    debugPrint('Job tapped: ${job['jobTitle']} at ${job['companyName']}');
    // Navigate to job details
  }

  void onBursaryCardTapped(Map<String, dynamic> bursary) {
    // Handle bursary card tap
    debugPrint('Bursary tapped: ${bursary['title']}');
    // Navigate to bursary details or application
  }

  void onApplyNowTapped(String bursaryTitle) {
    // Handle apply now button tap
    debugPrint('Apply now tapped for: $bursaryTitle');
    // Navigate to application form or show success message
  }

  void onSeeAllTapped(String section) {
    // Handle see all button taps
    debugPrint('See all tapped for: $section');
    // Navigate to respective section's full view
  }

  // Data refresh methods (for future API integration)
  Future<void> refreshUserStats() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    // Update stats from API
    notifyListeners();
  }

  Future<void> refreshRecommendedJobs() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    // Update jobs from API
    notifyListeners();
  }

  Future<void> refreshUpcomingDeadlines() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    // Update deadlines from API
    notifyListeners();
  }

  // Update user progress
  void updateCourseProgress(double newProgress) {
    _currentCourse['progress'] = newProgress;
    notifyListeners();
  }

  // Add or update stats
  void updateStat(String statKey, int newValue) {
    if (_userStats.containsKey(statKey)) {
      _userStats[statKey] = newValue;
      notifyListeners();
    }
  }

  // Get user initials for avatar
  String getUserInitials() {
    final nameParts = _userName.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else if (nameParts.isNotEmpty) {
      return nameParts[0].substring(0, 2).toUpperCase();
    }
    return 'TM';
  }

  // Format progress percentage
  String getProgressPercentage() {
    return '${(_currentCourse['progress'] * 100).round()}%';
  }

  // Check if any deadlines are urgent
  bool hasUrgentDeadlines() {
    return _upcomingDeadlines.any((deadline) => deadline['isUrgent'] == true);
  }

  // Get urgent deadlines count
  int getUrgentDeadlinesCount() {
    return _upcomingDeadlines
        .where((deadline) => deadline['isUrgent'] == true)
        .length;
  }

  @override
  void dispose() {
    // Clean up any resources
    super.dispose();
  }
}
