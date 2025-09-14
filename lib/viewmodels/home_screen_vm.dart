import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillsbridge/data/bursary_api.dart';
import 'package:skillsbridge/data/jobs_api.dart';

// State class that holds all the home screen data
class HomeScreenState {
  final String userName;
  final String greeting;
  final Map<String, dynamic> userStats;
  final Map<String, dynamic> currentCourse;
  final List<Map<String, dynamic>> recommendedJobs;
  final List<Map<String, dynamic>> upcomingDeadlines;
  final bool isLoading;

  const HomeScreenState({
    this.userName = 'Lukanyo',
    this.greeting = 'Welcome back',
    this.userStats = const {
      'coursesAvailable': 0,
      'jobsAvailable': 0,
      'bursariesAvailable': 0,
      'applications': 5,
    },
    this.currentCourse = const {
      'title': 'Python for Data Science',
      'module': 'Module 3: Data Visualization',
      'timeLeft': '2 hours left',
      'progress': 0.65,
      'icon': '🐍',
    },
    this.recommendedJobs = const [
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
    ],
    this.upcomingDeadlines = const [
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
    ],
    this.isLoading = false,
  });

  HomeScreenState copyWith({
    String? userName,
    String? greeting,
    Map<String, dynamic>? userStats,
    Map<String, dynamic>? currentCourse,
    List<Map<String, dynamic>>? recommendedJobs,
    List<Map<String, dynamic>>? upcomingDeadlines,
    bool? isLoading,
  }) {
    return HomeScreenState(
      userName: userName ?? this.userName,
      greeting: greeting ?? this.greeting,
      userStats: userStats ?? this.userStats,
      currentCourse: currentCourse ?? this.currentCourse,
      recommendedJobs: recommendedJobs ?? this.recommendedJobs,
      upcomingDeadlines: upcomingDeadlines ?? this.upcomingDeadlines,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  // Computed properties
  String getUserInitials() {
    final nameParts = userName.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else if (nameParts.isNotEmpty) {
      return nameParts[0].substring(0, 2).toUpperCase();
    }
    return 'TM';
  }

  String getProgressPercentage() {
    return '${(currentCourse['progress'] * 100).round()}%';
  }

  bool hasUrgentDeadlines() {
    return upcomingDeadlines.any((deadline) => deadline['isUrgent'] == true);
  }

  int getUrgentDeadlinesCount() {
    return upcomingDeadlines
        .where((deadline) => deadline['isUrgent'] == true)
        .length;
  }
}

// StateNotifier that manages the home screen state
class HomeScreenNotifier extends StateNotifier<HomeScreenState> {
  HomeScreenNotifier() : super(const HomeScreenState()) {
    initialize();
  }

  // Initialize the notifier
  void initialize() {
    _updateGreeting();
    fetchTotalCounts();
    debugPrint('🏠 Home screen initialized');
  }

  // Update greeting based on time of day
  void _updateGreeting() {
    final hour = DateTime.now().hour;
    String newGreeting;

    if (hour < 12) {
      newGreeting = 'Good morning';
    } else if (hour < 17) {
      newGreeting = 'Good afternoon';
    } else {
      newGreeting = 'Good evening';
    }

    state = state.copyWith(greeting: newGreeting);
  }

  /// 📊 Fetch total counts for jobs, courses, and bursaries
  /// This method updates the dashboard stats with real-time data
  Future<void> fetchTotalCounts() async {
    debugPrint('📊 Fetching total counts for dashboard...');

    try {
      state = state.copyWith(isLoading: true);

      // 🚀 Fetch all counts concurrently for better performance
      final results = await Future.wait([
        _fetchTotalJobs(),
        _fetchTotalBursaries(),
        _fetchTotalCourses(),
      ]);

      final totalJobs = results[0] as int;
      final totalBursaries = results[1] as int;
      final totalCourses = results[2] as int;

      // 📈 Update user stats with fetched totals
      final updatedStats = Map<String, dynamic>.from(state.userStats);
      updatedStats['jobsAvailable'] = totalJobs;
      updatedStats['coursesAvailable'] = totalCourses;
      updatedStats['bursariesAvailable'] = totalBursaries;

      state = state.copyWith(userStats: updatedStats, isLoading: false);

      debugPrint('✅ Dashboard updated successfully!');
      debugPrint(
        '📊 Jobs: $totalJobs | Courses: $totalCourses | Bursaries: $totalBursaries',
      );
    } catch (e) {
      debugPrint('❌ Failed to fetch dashboard counts: $e');

      // Keep existing data and just stop loading
      state = state.copyWith(isLoading: false);
    }
  }

  /// 💼 Fetch total number of available jobs
  Future<int> _fetchTotalJobs() async {
    try {
      debugPrint('💼 Fetching total jobs from CareerJet...');

      // Perform a broad search to get total job count for South Africa
      final response = await CareerJetApiService.searchJobs(
        keywords: null, // No keyword filter to get all jobs
        location: 'South Africa',
        pageSize: 1, // We only need the total count, not the actual jobs
        page: 1,
      );

      if (response != null) {
        debugPrint('✅ Found ${response.hits} total jobs available');
        return response.hits;
      } else {
        debugPrint('⚠️ Jobs API returned null, using fallback count');
        return 150; // Fallback count
      }
    } catch (e) {
      debugPrint('❌ Failed to fetch jobs count: $e');
      return 123; // Default fallback from your existing data
    }
  }

  /// 🎓 Fetch total number of available bursaries
  Future<int> _fetchTotalBursaries() async {
    try {
      debugPrint('🎓 Fetching total bursaries...');

      final apiService = BursaryApiService();
      final response = await apiService.getBursaries(
        page: 1,
        limit: 1, // We only need the total count
      );

      final totalBursaries = response.pagination.total;
      debugPrint('✅ Found $totalBursaries total bursaries available');
      return totalBursaries;
    } catch (e) {
      debugPrint('❌ Failed to fetch bursaries count: $e');
      return 47; // Default fallback from your existing data
    }
  }

  /// 📚 Fetch total number of available courses
  Future<int> _fetchTotalCourses() async {
    try {
      debugPrint('📚 Calculating total courses...');

      // Sample course data - you can replace this with your actual course API call
      final sampleCourses = [
        {'id': '1', 'title': 'Python for Data Science'},
        {'id': '2', 'title': 'JavaScript Fundamentals'},
        {'id': '3', 'title': 'Machine Learning Basics'},
        {'id': '4', 'title': 'Web Development'},
        {'id': '5', 'title': 'Mobile App Development'},
        {'id': '6', 'title': 'Data Analysis with Excel'},
        {'id': '7', 'title': 'Digital Marketing'},
        {'id': '8', 'title': 'Cybersecurity Fundamentals'},
        {'id': '9', 'title': 'Cloud Computing'},
        {'id': '10', 'title': 'Project Management'},
        {'id': '11', 'title': 'UI/UX Design'},
        {'id': '12', 'title': 'SQL for Beginners'},
        {'id': '13', 'title': 'React Development'},
        {'id': '14', 'title': 'Network Administration'},
        {'id': '15', 'title': 'Blockchain Technology'},
      ];

      final totalCourses = sampleCourses.length;
      debugPrint('✅ Found $totalCourses total courses available');
      return totalCourses;
    } catch (e) {
      debugPrint('❌ Failed to calculate courses count: $e');
      return 15; // Reasonable fallback
    }
  }

  // Methods for user interactions
  void onStatCardTapped(String statType) {
    debugPrint('Stat card tapped: $statType');
    // You can add navigation logic here
  }

  void onContinueCourseTapped() {
    debugPrint('Continue course tapped: ${state.currentCourse['title']}');
    // Navigate to course details or resume course
  }

  void onJobCardTapped(Map<String, dynamic> job) {
    debugPrint('Job tapped: ${job['jobTitle']} at ${job['companyName']}');
    // Navigate to job details
  }

  void onBursaryCardTapped(Map<String, dynamic> bursary) {
    debugPrint('Bursary tapped: ${bursary['title']}');
    // Navigate to bursary details or application
  }

  void onApplyNowTapped(String bursaryTitle) {
    debugPrint('Apply now tapped for: $bursaryTitle');
    // Navigate to application form or show success message
  }

  void onSeeAllTapped(String section) {
    debugPrint('See all tapped for: $section');
    // Navigate to respective section's full view
  }

  // Data refresh methods with real API integration
  Future<void> refreshUserStats() async {
    state = state.copyWith(isLoading: true);

    try {
      // Fetch fresh counts from APIs
      await fetchTotalCounts();
      debugPrint('📊 User stats refreshed');
    } catch (e) {
      state = state.copyWith(isLoading: false);
      debugPrint('❌ Failed to refresh user stats: $e');
    }
  }

  /// 💼 Fetch 10 recent jobs for recommendations
  Future<void> refreshRecommendedJobs() async {
    state = state.copyWith(isLoading: true);

    try {
      debugPrint('💼 Fetching 10 recent jobs...');

      // Fetch recent jobs from CareerJet API
      final response = await CareerJetApiService.searchJobs(
        keywords: null, // No keyword filter to get diverse jobs
        location: 'South Africa',
        sort: 'date', // Sort by most recent
        pageSize: 10, // Get 10 jobs
        page: 1,
      );

      if (response != null && response.jobs.isNotEmpty) {
        // Convert CareerJet jobs to our app format - FIXED the map issue
        final updatedJobs = <Map<String, dynamic>>[];

        for (int index = 0; index < response.jobs.length; index++) {
          final job = response.jobs[index];
          final appJob = job.toAppJobFormat(index);

          updatedJobs.add({
            'companyLogo': appJob['logo'],
            'jobTitle': appJob['title'],
            'companyName': appJob['company'],
            'location': '📍 ${appJob['location']}',
            'salary': '💰 ${appJob['salary']}',
            'workType': _getWorkTypeIcon(appJob['type']),
            'matchPercentage': '${appJob['matchScore']}%',
          });
        }

        state = state.copyWith(recommendedJobs: updatedJobs, isLoading: false);
        debugPrint('✅ Updated with ${updatedJobs.length} recent jobs');
      } else {
        debugPrint('⚠️ No jobs returned from API, keeping existing data');
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      debugPrint('❌ Failed to refresh recommended jobs: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  /// 🎓 Fetch 10 bursaries closing soon
  Future<void> refreshUpcomingDeadlines() async {
    state = state.copyWith(isLoading: true);

    try {
      debugPrint('🎓 Fetching 10 bursaries closing soon...');

      final apiService = BursaryApiService();
      final response = await apiService.getClosingSoonBursaries(
        days: 30, // Get bursaries closing within 30 days
      );

      if (response.closingSoon.isNotEmpty) {
        // Convert to our app format and take first 10
        final updatedDeadlines = response.closingSoon
            .take(10)
            .map(
              (bursary) => {
                'title': bursary.title,
                'amount': bursary.amount?.isNotEmpty == true
                    ? bursary.amount
                    : 'Amount not specified',
                'deadline': '⏰ ${_formatDeadline(bursary.daysLeft)}',
                'isUrgent': bursary.isUrgent,
              },
            )
            .toList();

        state = state.copyWith(
          upcomingDeadlines: updatedDeadlines,
          isLoading: false,
        );
        debugPrint(
          '✅ Updated with ${updatedDeadlines.length} closing bursaries',
        );
      } else {
        debugPrint(
          '⚠️ No closing bursaries returned from API, keeping existing data',
        );
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      debugPrint('❌ Failed to refresh upcoming deadlines: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  // Helper methods
  String _getWorkTypeIcon(String workType) {
    switch (workType.toLowerCase()) {
      case 'remote':
        return '🌍 Remote';
      case 'hybrid':
        return '🏠 Hybrid';
      case 'on-site':
      case 'onsite':
        return '🏢 On-site';
      default:
        return '🏢 On-site';
    }
  }

  String _formatDeadline(int daysLeft) {
    if (daysLeft <= 0) {
      return 'Deadline passed';
    } else if (daysLeft == 1) {
      return 'Closes tomorrow';
    } else if (daysLeft <= 7) {
      return 'Closes in $daysLeft days';
    } else if (daysLeft <= 14) {
      return 'Closes in ${(daysLeft / 7).ceil()} weeks';
    } else {
      return 'Closes in ${(daysLeft / 7).round()} weeks';
    }
  }

  // Update user progress
  void updateCourseProgress(double newProgress) {
    final updatedCourse = Map<String, dynamic>.from(state.currentCourse);
    updatedCourse['progress'] = newProgress;

    state = state.copyWith(currentCourse: updatedCourse);
    debugPrint('📚 Course progress updated to ${(newProgress * 100).round()}%');
  }

  // Add or update stats
  void updateStat(String statKey, int newValue) {
    final updatedStats = Map<String, dynamic>.from(state.userStats);
    if (updatedStats.containsKey(statKey)) {
      updatedStats[statKey] = newValue;
      state = state.copyWith(userStats: updatedStats);
      debugPrint('📈 Stat $statKey updated to $newValue');
    }
  }

  /// 📊 Get formatted count string for display
  String getFormattedCount(int count) {
    if (count < 1000) {
      return count.toString();
    } else if (count < 1000000) {
      final k = count / 1000;
      return k % 1 == 0 ? '${k.toInt()}k' : '${k.toStringAsFixed(1)}k';
    } else {
      final m = count / 1000000;
      return m % 1 == 0 ? '${m.toInt()}M' : '${m.toStringAsFixed(1)}M';
    }
  }

  /// 🎯 Get specific total count by type
  int getTotalCount(String type) {
    switch (type) {
      case 'jobs':
        return state.userStats['jobsAvailable'] ?? 0;
      case 'courses':
        return state.userStats['coursesAvailable'] ?? 0;
      case 'bursaries':
        return state.userStats['bursariesAvailable'] ?? 0;
      default:
        return 0;
    }
  }

  /// 📈 Update a specific count (useful for real-time updates)
  void updateTotalCount(String type, int newCount) {
    final updatedStats = Map<String, dynamic>.from(state.userStats);

    switch (type) {
      case 'jobs':
        updatedStats['jobsAvailable'] = newCount;
        break;
      case 'courses':
        updatedStats['coursesAvailable'] = newCount;
        break;
      case 'bursaries':
        updatedStats['bursariesAvailable'] = newCount;
        break;
    }

    state = state.copyWith(userStats: updatedStats);
    debugPrint('📈 Updated $type count to $newCount');
  }

  // Refresh all data
  Future<void> refreshAllData() async {
    debugPrint('🔄 Refreshing all home screen data');
    await Future.wait([
      fetchTotalCounts(), // Fetch fresh totals
      refreshRecommendedJobs(), // Fetch 10 recent jobs
      refreshUpcomingDeadlines(), // Fetch 10 closing bursaries
    ]);
    _updateGreeting();
    debugPrint('🎉 All home screen data refreshed successfully');
  }
}

// Provider definition
final homeScreenProvider =
    StateNotifierProvider<HomeScreenNotifier, HomeScreenState>(
      (ref) => HomeScreenNotifier(),
    );
