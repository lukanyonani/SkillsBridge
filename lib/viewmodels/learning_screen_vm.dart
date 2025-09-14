// 🚀 Learning Hub ViewModel with Riverpod - The Brain of Our Learning Platform!
// This ViewModel manages all the state and business logic for the learning hub.
// Now powered by Riverpod for better state management and with API integration!
// Features automatic fallback to sample data when API is unavailable. 🎯

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillsbridge/data/courses_api.dart';
import 'package:skillsbridge/data/offline/courses_data.dart';
import 'package:skillsbridge/models/course_models.dart';

// 🌟 Provider for the API service - Singleton instance
final coursesApiServiceProvider = Provider<CoursesApiService>((ref) {
  debugPrint('🏗️ Creating Courses API Service Provider');
  return CoursesApiService();
});

// 🔧 Provider for mock mode state - Controls whether we use API or sample data
final useMockModeProvider = StateProvider<bool>((ref) {
  debugPrint('🎭 Mock mode initialized to false - Will try API first!');
  return true; // Start with API, fallback to mock if needed
});

// 📚 Main ViewModel Provider - The heart of our learning hub!
final learningHubViewModelProvider =
    ChangeNotifierProvider.autoDispose<LearningHubViewModel>((ref) {
      debugPrint('🎓 Creating Learning Hub ViewModel with Riverpod power!');
      final apiService = ref.watch(coursesApiServiceProvider);
      final useMock = ref.watch(useMockModeProvider);

      return LearningHubViewModel(
        apiService: apiService,
        useMock: useMock,
        ref: ref,
      );
    });

// 🎯 The Main ViewModel Class - Where the magic happens!
class LearningHubViewModel extends ChangeNotifier {
  // 🔧 Dependencies and References
  final CoursesApiService apiService;
  final bool useMock;
  final Ref ref;

  // 🎨 UI State Variables - Track everything the UI needs!
  int _currentNavIndex = 1; // Learn tab is active by default
  int _selectedCategoryIndex = 0;
  List<String> _activeFilters = ['All Levels'];
  String _searchQuery = '';
  bool _isEnrolled = false;
  List<bool> _expandedSections = [false, false, false, false];

  // 📊 Data State - Courses and related information
  List<Course> _courses = [];
  List<Course> _featuredCourses = [];
  List<String> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  // 🚀 Constructor - Initialize everything!
  LearningHubViewModel({
    required this.apiService,
    required this.useMock,
    required this.ref,
  }) {
    debugPrint('🎉 Learning Hub ViewModel initialized!');
    debugPrint('🎭 Mock mode: $useMock');
    _initializeData();
  }

  // 🔄 Initialize data - Load courses from API or sample data
  Future<void> _initializeData() async {
    debugPrint('🔄 Starting data initialization...');

    if (useMock) {
      debugPrint('🎭 Using mock data as requested!');
      _loadMockData();
    } else {
      debugPrint('🌐 Attempting to load from API...');
      await _loadFromApi();
    }
  }

  // 🌐 Load data from API with automatic fallback
  Future<void> _loadFromApi() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      debugPrint('🚀 Checking API health...');

      // First, check if API is healthy
      try {
        final health = await apiService.checkHealth();
        debugPrint('✅ API health check passed: ${health.status}');
      } catch (e) {
        debugPrint('⚠️ API health check failed, switching to mock mode!');
        _switchToMockMode();
        return;
      }

      // Load courses from API
      debugPrint('📚 Loading courses from API...');
      final searchResponse = await apiService.searchCourses(
        hasVideoLectures: true,
        limit: 30,
      );

      _courses = searchResponse.courses;
      debugPrint('✅ Loaded ${_courses.length} courses from API!');

      // Load featured courses
      debugPrint('🌟 Loading featured courses...');
      try {
        final featured = await apiService.getFeaturedCourses();
        //_featuredCourses = featured.map((f) => f.course).toList();
        debugPrint('✅ Loaded ${_featuredCourses.length} featured courses!');
      } catch (e) {
        debugPrint('⚠️ Featured courses failed, continuing without them');
      }

      // Load topics/categories
      debugPrint('📂 Loading categories...');
      try {
        final topicsResponse = await apiService.getTopics();
        //_categories = ['All', ...topicsResponse.topics];
        debugPrint('✅ Loaded ${_categories.length} categories!');
      } catch (e) {
        debugPrint('⚠️ Categories failed, using default list');
        _loadDefaultCategories();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ API loading failed: $e');
      debugPrint('🔄 Switching to mock mode as fallback...');
      _switchToMockMode();
    }
  }

  // 🎭 Switch to mock mode - Our safety net!
  void _switchToMockMode() {
    debugPrint('🎭 Activating mock mode - Sample data to the rescue!');
    ref.read(useMockModeProvider.notifier).state = true;
    _loadMockData();
  }

  // 📦 Load mock/sample data - The fallback hero!
  void _loadMockData() {
    debugPrint('📦 Loading sample course data...');

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Load sample courses from sample.dart
      _courses = sampleCourses;
      debugPrint('✅ Loaded ${_courses.length} sample courses!');

      // Featured courses are the first 5 with video lectures
      _featuredCourses = _courses
          .where((c) => c.hasVideoLectures)
          .take(5)
          .toList();
      debugPrint('🌟 Selected ${_featuredCourses.length} featured courses!');

      // Load default categories
      _loadDefaultCategories();

      _isLoading = false;
      notifyListeners();

      debugPrint('🎉 Mock data loaded successfully!');
    } catch (e) {
      debugPrint('❌ Failed to load mock data: $e');
      _errorMessage = 'Failed to load course data. Please try again.';
      _isLoading = false;
      notifyListeners();
    }
  }

  // 📂 Load default categories - Always have something to show!
  void _loadDefaultCategories() {
    debugPrint('📂 Loading default categories...');
    _categories = [
      'All',
      'Computer Science',
      'Mathematics',
      'Engineering',
      'Physics',
      'Biology',
      'Chemistry',
      'Business',
      'Psychology',
      'Economics',
      'Data Science',
      'Machine Learning',
      'Web Development',
      'Mobile Development',
      'Artificial Intelligence',
    ];
    debugPrint('✅ Loaded ${_categories.length} default categories!');
  }

  // 🔄 Refresh data - Try API again or reload mock
  Future<void> refreshData() async {
    debugPrint('🔄 Refreshing course data...');

    if (useMock) {
      debugPrint('🎭 Refreshing mock data...');
      _loadMockData();
    } else {
      debugPrint('🌐 Trying to refresh from API...');
      await _loadFromApi();
    }
  }

  // 🔄 Force API retry - Give the API another chance!
  Future<void> retryApiConnection() async {
    debugPrint('🔄 Forcing API retry...');
    ref.read(useMockModeProvider.notifier).state = false;
    await _loadFromApi();
  }

  // 🎯 Getters - Access to all our state!
  int get currentNavIndex => _currentNavIndex;
  int get selectedCategoryIndex => _selectedCategoryIndex;
  List<String> get activeFilters => _activeFilters;
  String get searchQuery => _searchQuery;
  bool get isEnrolled => _isEnrolled;
  List<bool> get expandedSections => _expandedSections;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isUsingMockData => ref.read(useMockModeProvider);

  List<Course> get courses => _courses;
  List<Course> get featuredCourses => _featuredCourses;
  List<String> get categories => _categories;

  // 🎨 Get featured course for display
  Course? get featuredCourse {
    if (_featuredCourses.isEmpty) return null;
    return _featuredCourses.first;
  }

  // 📚 Get popular courses - Top rated courses with videos!
  List<Course> get popularCourses {
    final popular = _courses.where((c) => c.hasVideoLectures).take(4).toList();
    debugPrint('📊 Returning ${popular.length} popular courses');
    return popular;
  }

  // 📖 Get all courses for list view
  List<Course> get allCourses => _courses;

  // 🔍 Filter courses based on search and filters
  List<Course> get filteredCourses {
    debugPrint('🔍 Filtering courses...');
    List<Course> filtered = _courses;

    // Apply category filter
    if (_selectedCategoryIndex > 0 &&
        _selectedCategoryIndex < _categories.length) {
      final selectedCategory = _categories[_selectedCategoryIndex];
      filtered = filtered.where((course) {
        return course.topics.any(
          (topic) =>
              topic.toLowerCase().contains(selectedCategory.toLowerCase()),
        );
      }).toList();
      debugPrint('📂 Applied category filter: $selectedCategory');
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((course) {
        return course.title.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            course.description!.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            course.topics.any(
              (t) => t.toLowerCase().contains(_searchQuery.toLowerCase()),
            );
      }).toList();
      debugPrint('🔎 Applied search filter: $_searchQuery');
    }

    // Apply level filters
    for (String filter in _activeFilters) {
      switch (filter) {
        case 'Undergraduate':
          filtered = filtered.where((c) => c.level == 'Undergraduate').toList();
          debugPrint('🎓 Applied Undergraduate filter');
          break;
        case 'Graduate':
          filtered = filtered.where((c) => c.level == 'Graduate').toList();
          debugPrint('🎓 Applied Graduate filter');
          break;
        // Add more filters as needed
      }
    }

    debugPrint(
      '✅ Filtering complete: ${filtered.length} courses match criteria',
    );
    return filtered;
  }

  // 🎯 Navigation Methods
  void updateNavIndex(int index) {
    debugPrint('🧭 Updating navigation index to: $index');
    _currentNavIndex = index;
    notifyListeners();
  }

  void selectCategory(int index) {
    debugPrint('📂 Selecting category at index: $index');
    _selectedCategoryIndex = index;
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    debugPrint('🔍 Updating search query: $query');
    _searchQuery = query;
    notifyListeners();
  }

  // 🏷️ Filter Management
  void toggleFilter(String filter) {
    debugPrint('🏷️ Toggling filter: $filter');
    if (_activeFilters.contains(filter)) {
      _activeFilters.remove(filter);
      debugPrint('❌ Removed filter: $filter');
    } else {
      _activeFilters.add(filter);
      debugPrint('✅ Added filter: $filter');
    }
    notifyListeners();
  }

  void clearFilters() {
    debugPrint('🧹 Clearing all filters');
    _activeFilters.clear();
    _activeFilters.add('All Levels');
    notifyListeners();
  }

  bool isFilterActive(String filter) => _activeFilters.contains(filter);

  // 📚 Course Enrollment
  void toggleEnrollment() {
    debugPrint('🎯 Toggling enrollment status');
    _isEnrolled = !_isEnrolled;
    debugPrint(
      _isEnrolled ? '✅ Enrolled in course!' : '❌ Unenrolled from course',
    );
    notifyListeners();
  }

  // 📋 Syllabus Management
  void toggleSyllabusSection(int index) {
    if (index < _expandedSections.length) {
      debugPrint('📋 Toggling syllabus section $index');
      _expandedSections[index] = !_expandedSections[index];
      notifyListeners();
    }
  }

  // 🔄 Reset everything - Fresh start!
  void reset() {
    debugPrint('🔄 Resetting all state to defaults');
    _currentNavIndex = 1;
    _selectedCategoryIndex = 0;
    _activeFilters = ['All Levels'];
    _searchQuery = '';
    _isEnrolled = false;
    _expandedSections = [false, false, false, false];
    notifyListeners();
    debugPrint('✅ Reset complete!');
  }

  @override
  void dispose() {
    debugPrint('🧹 Disposing Learning Hub ViewModel');
    super.dispose();
  }
}
