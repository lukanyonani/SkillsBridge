import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillsbridge/data/bursary_api.dart';
import 'package:skillsbridge/data/jobs_api.dart';
import 'package:skillsbridge/views/jobs/jobs_detail_screen.dart';
import 'package:skillsbridge/views/bursary/bursary_detail_screen.dart';
import 'package:skillsbridge/views/learning/course_detail_screen.dart';
import 'package:skillsbridge/models/bursary_models.dart' as bursary_models;
import 'package:skillsbridge/models/course_models.dart';

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
      'applications': 25,
    },
    this.currentCourse = const {
      'title': 'Python for Data Science',
      'module': 'Module 3: Data Visualization',
      'timeLeft': '2 hours left',
      'progress': 0.65,
      'icon': '🐍',
    },
    this.recommendedJobs = const [],
    this.upcomingDeadlines = const [],
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
    refreshRecommendedJobs();
    refreshUpcomingDeadlines();
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

      final totalJobs = results[0];
      final totalBursaries = results[1];
      final totalCourses = results[2];

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

  void onContinueCourseTapped(BuildContext context) {
    debugPrint('Continue course tapped: ${state.currentCourse['title']}');
    // Create a sample course for navigation
    final sampleCourse = Course(
      id: '1',
      title: state.currentCourse['title'],
      description:
          'Continue your learning journey with this comprehensive course.',
      instructor: 'SkillsBridge Team',
      thumbnailUrl: 'https://example.com/thumbnail.jpg',
      rating: 4.5,
      enrollmentCount: 1250,
      level: CourseLevel.beginner,
      category: CourseCategory.programming,
      pricing: CoursePricing(type: PricingType.free, amount: 0),
      totalDuration: const Duration(hours: 30),
      lessons: const [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      reviewCount: 150,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailScreen(course: sampleCourse),
      ),
    );
  }

  void onJobCardTapped(BuildContext context, Map<String, dynamic> job) {
    debugPrint('Job tapped: ${job['jobTitle']} at ${job['companyName']}');

    // Convert home screen job format to jobs detail screen format
    final jobDetail = {
      'id': (job['jobTitle'] ?? 'Unknown').hashCode.toString(),
      'title': job['jobTitle'] ?? 'Unknown Position',
      'company': job['companyName'] ?? 'Unknown Company',
      'location': (job['location'] ?? 'Unknown').toString().replaceAll(
        '📍 ',
        '',
      ),
      'salary': (job['salary'] ?? 'Negotiable').toString().replaceAll(
        '💰 ',
        '',
      ),
      'type': (job['workType'] ?? 'On-site')
          .toString()
          .replaceAll('🌍 ', '')
          .replaceAll('🏠 ', '')
          .replaceAll('🏢 ', ''),
      'logo': job['companyLogo'] ?? '🏢',
      'url': 'https://example.com/apply',
      'description':
          'This is a great opportunity to work with a leading company in the industry. You will be responsible for various tasks and will have the chance to grow your career.',
      'matchScore':
          int.tryParse(
            (job['matchPercentage'] ?? '75%').toString().replaceAll('%', ''),
          ) ??
          75,
    };

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => JobDetailPage(job: jobDetail)),
    );
  }

  void onBursaryCardTapped(BuildContext context, Map<String, dynamic> bursary) {
    debugPrint('Bursary tapped: ${bursary['title']}');

    // Create a sample bursary for navigation
    final sampleBursary = bursary_models.Bursary(
      id: (bursary['title'] ?? 'Unknown').hashCode.toString(),
      title: bursary['title'] ?? 'Unknown Bursary',
      provider: bursary_models.Provider(
        name: 'Sample Provider',
        website: 'https://example.com',
      ),
      coverage: bursary_models.Coverage(
        type: 'Full',
        amount: _parseAmount(bursary['amount']),
        covers: ['Tuition fees', 'Accommodation', 'Books and materials'],
      ),
      deadline: bursary_models.Deadline(
        displayText: (bursary['deadline'] ?? 'Unknown deadline')
            .toString()
            .replaceAll('⏰ ', ''),
        isUrgent: bursary['isUrgent'] ?? false,
        closingDate: DateTime.now()
            .add(const Duration(days: 30))
            .toIso8601String(),
      ),
      studyLevel: 'Undergraduate',
      academicYear: '2024',
      fields: ['Technology', 'Engineering', 'Business'],
      numberOfBursaries: 10,
      eligibility: bursary_models.Eligibility(
        citizenship: 'South African',
        maxAge: 25,
        qualifications: ['Matric', 'University entrance'],
      ),
      applicationProcess: bursary_models.ApplicationProcess(
        method: 'Online Application',
        steps: ['Complete application form', 'Submit documents', 'Interview'],
        applicationUrl: 'https://example.com/apply',
      ),
      requiredDocuments: ['ID Copy', 'Matric Certificate', 'Proof of Income'],
      selectionProcess: bursary_models.SelectionProcess(
        timeframe: '2-4 weeks',
        priorityPolicy: 'Merit-based',
        noResponseMeansRejection: true,
      ),
      workBackObligation: bursary_models.WorkBackObligation(
        required: false,
        duration: null,
        department: null,
        additionalBenefits: [],
      ),
      tags: ['New', 'Popular'],
      scraped: bursary_models.ScrapedInfo(
        lastUpdated: DateTime.now().toIso8601String(),
        sourceUrl: 'https://example.com/source',
        scrapedAt: DateTime.now().toIso8601String(),
      ),
      isSaved: false,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BursaryDetailPage(bursary: sampleBursary),
      ),
    );
  }

  void onApplyNowTapped(BuildContext context, String bursaryTitle) {
    debugPrint('Apply now tapped for: $bursaryTitle');
    // Find the bursary and navigate to detail screen
    final bursary = state.upcomingDeadlines.firstWhere(
      (b) => b['title'] == bursaryTitle,
      orElse: () => state.upcomingDeadlines.isNotEmpty
          ? state.upcomingDeadlines.first
          : <String, dynamic>{},
    );
    onBursaryCardTapped(context, bursary);
  }

  void onSeeAllTapped(String section) {
    debugPrint('See all tapped for: $section');
    // Navigate to respective section's full view
  }

  // Helper method to parse amount from various formats
  int? _parseAmount(dynamic amount) {
    if (amount == null) return null;

    String amountStr = amount.toString();
    if (amountStr.toLowerCase().contains('full funding')) {
      return 100000;
    }

    // Remove common prefixes and suffixes
    amountStr = amountStr
        .replaceAll('R', '')
        .replaceAll(',', '')
        .replaceAll('Up to ', '')
        .replaceAll(' ', '');

    return int.tryParse(amountStr);
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
                'amount': bursary.amount,
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
