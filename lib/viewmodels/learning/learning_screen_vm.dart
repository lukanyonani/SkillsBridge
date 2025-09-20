// lib/viewmodels/learning_screen_vm.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillsbridge/data/course.dart';

// Provider for the API service
final coursesApiServiceProvider = Provider<CoursesApiService>((ref) {
  return CoursesApiService();
});

// Provider for mock mode state
final useMockModeProvider = StateProvider<bool>((ref) {
  return false; // Start with real API mode
});

// Main ViewModel Provider
final learningHubViewModelProvider =
    ChangeNotifierProvider.autoDispose<LearningHubViewModel>((ref) {
      final apiService = ref.watch(coursesApiServiceProvider);
      final useMock = ref.watch(useMockModeProvider);

      // Set mock mode on API service
      CoursesApiService.setMockMode(useMock);

      return LearningHubViewModel(apiService: apiService, ref: ref);
    });

/// Learning Hub ViewModel with complete API integration
class LearningHubViewModel extends ChangeNotifier {
  final CoursesApiService _apiService;
  final Ref _ref;

  // UI State
  int _currentNavIndex = 1;
  int _selectedCategoryIndex = 0;
  List<String> _activeFilters = ['All Levels'];
  String _searchQuery = '';
  bool _isEnrolled = false;
  List<bool> _expandedSections = [false, false, false, false];

  // Data State
  List<Course> _courses = [];
  List<FeaturedCourse> _featuredCourses = [];
  TopicsResponse? _topicsResponse;
  bool _isLoading = false;
  String? _errorMessage;

  // Search/Filter State
  SearchResponse? _lastSearchResponse;
  int _currentPage = 1;
  bool _hasMorePages = false;

  LearningHubViewModel({
    required CoursesApiService apiService,
    required Ref ref,
  }) : _apiService = apiService,
       _ref = ref {
    debugPrint('Initializing Learning Hub ViewModel');
    _initializeData();
  }

  // Getters
  int get currentNavIndex => _currentNavIndex;
  int get selectedCategoryIndex => _selectedCategoryIndex;
  List<String> get activeFilters => _activeFilters;
  String get searchQuery => _searchQuery;
  bool get isEnrolled => _isEnrolled;
  List<bool> get expandedSections => _expandedSections;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isUsingMockData => CoursesApiService.isMockMode;
  bool get hasMorePages => _hasMorePages;
  int get currentPage => _currentPage;

  List<Course> get courses => _courses;
  List<FeaturedCourse> get featuredCourses => _featuredCourses;

  List<String> get categories {
    if (_topicsResponse?.topics != null) {
      return ['All', ..._topicsResponse!.topics];
    }
    return ['All'];
  }

  List<String> get departments {
    return _topicsResponse?.departments ?? [];
  }

  Map<String, String> get departmentNames {
    return _topicsResponse?.departmentNames ?? {};
  }

  Course? get featuredCourse {
    if (_featuredCourses.isNotEmpty) {
      // Convert FeaturedCourse to Course for UI compatibility
      final featured = _featuredCourses.first;
      // Try to find the full course in our courses list
      final fullCourse = _courses.cast<Course?>().firstWhere(
        (course) => course?.id == featured.id,
        orElse: () => null,
      );

      if (fullCourse != null) {
        return fullCourse;
      }

      // Create a minimal Course object from FeaturedCourse data
      return Course(
        id: featured.id,
        courseNumber: '',
        title: featured.title,
        department: '',
        url: '',
        videoGalleryUrl: '',
        description: featured.description,
        instructors: [
          Instructor(name: featured.instructor, title: 'Instructor'),
        ],
        semester: '',
        hasVideoLectures: true,
        hasLectureNotes: false,
        hasAssignments: false,
        level: featured.level == 'graduate'
            ? CourseLevel.graduate
            : CourseLevel.undergraduate,
        topics: [featured.category],
        languages: ['English'],
        license: '',
        units: 0,
        estimatedHours: 0,
        thumbnailImage: featured.thumbnailUrl,
        videoPlaylistId: '',
        sampleVideos: [],
        rating: featured.rating,
        enrollmentCount: featured.enrollmentCount,
      );
    }
    return null;
  }

  List<Course> get popularCourses {
    // Sort by enrollment count or rating
    final sorted = List<Course>.from(_courses);
    sorted.sort((a, b) {
      final aScore = (a.enrollmentCount ?? 0) + ((a.rating ?? 0) * 100).toInt();
      final bScore = (b.enrollmentCount ?? 0) + ((b.rating ?? 0) * 100).toInt();
      return bScore.compareTo(aScore);
    });
    return sorted.take(10).toList();
  }

  List<Course> get allCourses => _courses;

  List<Course> get filteredCourses {
    // Since filtering is handled by the API, return all courses
    // The API already applied the filters based on our search parameters
    return _courses;
  }

  /// Initialize data from API
  Future<void> _initializeData() async {
    _setLoading(true);

    try {
      // Load topics/categories first
      await _loadTopics();

      // Load featured courses
      await _loadFeaturedCourses();

      // Load initial courses
      await _searchCourses();
    } catch (e) {
      _setError('Failed to initialize data: $e');
      // If API fails, try with mock mode
      if (!CoursesApiService.isMockMode) {
        debugPrint('API failed, switching to mock mode');
        _ref.read(useMockModeProvider.notifier).state = true;
        CoursesApiService.setMockMode(true);
        await _initializeData(); // Retry with mock data
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Load topics and departments from API
  Future<void> _loadTopics() async {
    try {
      debugPrint('Loading topics from API...');
      _topicsResponse = await _apiService.getTopics();
      debugPrint('Topics loaded: ${_topicsResponse?.topics.length ?? 0}');
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load topics: $e');
      // Continue without topics
    }
  }

  /// Load featured courses from API
  Future<void> _loadFeaturedCourses() async {
    try {
      debugPrint('Loading featured courses from API...');
      _featuredCourses = await _apiService.getFeaturedCourses();
      debugPrint('Featured courses loaded: ${_featuredCourses.length}');
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load featured courses: $e');
      // Continue without featured courses
    }
  }

  /// Search courses with current filters
  Future<void> _searchCourses({
    bool loadMore = false,
    bool resetResults = true,
  }) async {
    try {
      final searchPage = loadMore ? _currentPage + 1 : 1;

      if (!loadMore) {
        _setLoading(true);
      }

      debugPrint('Searching courses: query="$_searchQuery", page=$searchPage');

      // Build search parameters
      final selectedCategory =
          _selectedCategoryIndex > 0 &&
              _selectedCategoryIndex < categories.length
          ? categories[_selectedCategoryIndex]
          : null;

      // Map filter strings to API level format
      String? levelFilter;
      for (final filter in _activeFilters) {
        if (filter == 'Beginner' ||
            filter == 'Intermediate' ||
            filter == 'Advanced') {
          levelFilter = 'undergraduate'; // Map to undergraduate
          break;
        } else if (filter == 'Undergraduate') {
          levelFilter = 'undergraduate';
          break;
        } else if (filter == 'Graduate') {
          levelFilter = 'graduate';
          break;
        }
      }

      final response = await _apiService.searchCourses(
        query: _searchQuery.isNotEmpty ? _searchQuery : null,
        topic: selectedCategory != null && selectedCategory != 'All'
            ? selectedCategory
            : null,
        level: levelFilter,
        hasVideoLectures: true, // Always prefer courses with videos
        sort: 'relevance',
        page: searchPage,
        limit: 20,
      );

      _lastSearchResponse = response;
      _currentPage = searchPage;
      _hasMorePages = searchPage < response.totalPages;

      if (resetResults || !loadMore) {
        _courses = response.courses;
      } else {
        // Append results for pagination
        _courses.addAll(response.courses);
      }

      debugPrint(
        'Search completed: ${response.courses.length} courses loaded, '
        'page $_currentPage/${response.totalPages}',
      );
      _clearError();
    } catch (e) {
      _setError('Failed to search courses: $e');

      // If search fails and we're not in mock mode, switch to mock
      if (!CoursesApiService.isMockMode) {
        debugPrint('Search failed, switching to mock mode');
        _ref.read(useMockModeProvider.notifier).state = true;
        CoursesApiService.setMockMode(true);
        await _searchCourses(loadMore: loadMore, resetResults: resetResults);
      }
    } finally {
      if (!loadMore) {
        _setLoading(false);
      }
    }
  }

  /// Load more courses (pagination)
  Future<void> loadMoreCourses() async {
    if (!_hasMorePages || _isLoading) return;

    debugPrint('Loading more courses...');
    await _searchCourses(loadMore: true, resetResults: false);
  }

  /// Refresh all data
  Future<void> refreshData() async {
    debugPrint('Refreshing all data...');
    _currentPage = 1;
    await _initializeData();
  }

  /// Force API retry
  Future<void> retryApiConnection() async {
    debugPrint('Retrying API connection...');
    _ref.read(useMockModeProvider.notifier).state = false;
    CoursesApiService.setMockMode(false);
    await refreshData();
  }

  /// Toggle mock mode
  void toggleMockMode() {
    final newMode = !CoursesApiService.isMockMode;
    debugPrint('Toggling mock mode to: $newMode');
    _ref.read(useMockModeProvider.notifier).state = newMode;
    CoursesApiService.setMockMode(newMode);
    refreshData();
  }

  /// Update search query and trigger search
  void updateSearchQuery(String query) {
    if (_searchQuery != query) {
      debugPrint('Updating search query: "$query"');
      _searchQuery = query;
      _currentPage = 1;
      notifyListeners();

      // Debounce search to avoid too many API calls
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        _searchCourses();
      });
    }
  }

  Timer? _debounceTimer;

  /// Select category and trigger search
  void selectCategory(int index) {
    if (_selectedCategoryIndex != index) {
      debugPrint('Selecting category at index: $index');
      _selectedCategoryIndex = index;
      _currentPage = 1;
      notifyListeners();
      _searchCourses();
    }
  }

  /// Toggle filter and trigger search
  void toggleFilter(String filter) {
    debugPrint('Toggling filter: $filter');

    if (_activeFilters.contains(filter)) {
      _activeFilters.remove(filter);
    } else {
      // Remove conflicting filters
      if (['Beginner', 'Intermediate', 'Advanced'].contains(filter)) {
        _activeFilters.removeWhere(
          (f) => ['Beginner', 'Intermediate', 'Advanced'].contains(f),
        );
      } else if (['Undergraduate', 'Graduate'].contains(filter)) {
        _activeFilters.removeWhere(
          (f) => ['Undergraduate', 'Graduate'].contains(f),
        );
      }
      _activeFilters.add(filter);
    }

    // Ensure "All Levels" is present if no level filters are active
    final hasLevelFilter = _activeFilters.any(
      (f) => [
        'Beginner',
        'Intermediate',
        'Advanced',
        'Undergraduate',
        'Graduate',
      ].contains(f),
    );

    if (!hasLevelFilter && !_activeFilters.contains('All Levels')) {
      _activeFilters.add('All Levels');
    } else if (hasLevelFilter) {
      _activeFilters.remove('All Levels');
    }

    _currentPage = 1;
    notifyListeners();
    _searchCourses();
  }

  /// Clear all filters
  void clearFilters() {
    debugPrint('Clearing all filters');
    _activeFilters = ['All Levels'];
    _selectedCategoryIndex = 0;
    _searchQuery = '';
    _currentPage = 1;
    notifyListeners();
    _searchCourses();
  }

  /// Check if filter is active
  bool isFilterActive(String filter) => _activeFilters.contains(filter);

  /// Search by department
  Future<void> searchByDepartment(String department) async {
    debugPrint('Searching by department: $department');
    try {
      _setLoading(true);

      final response = await _apiService.searchCourses(
        department: department,
        hasVideoLectures: true,
        sort: 'enrollment',
        page: 1,
        limit: 20,
      );

      _courses = response.courses;
      _lastSearchResponse = response;
      _currentPage = 1;
      _hasMorePages = response.totalPages > 1;

      debugPrint(
        'Department search completed: ${response.courses.length} courses',
      );
      _clearError();
    } catch (e) {
      _setError('Failed to search by department: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Navigation methods
  void updateNavIndex(int index) {
    _currentNavIndex = index;
    notifyListeners();
  }

  /// Course enrollment
  void toggleEnrollment() {
    _isEnrolled = !_isEnrolled;
    debugPrint(_isEnrolled ? 'Enrolled in course' : 'Unenrolled from course');
    notifyListeners();
  }

  /// Syllabus management
  void toggleSyllabusSection(int index) {
    if (index < _expandedSections.length) {
      _expandedSections[index] = !_expandedSections[index];
      notifyListeners();
    }
  }

  /// Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    debugPrint('Error: $error');
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset to default state
  void reset() {
    debugPrint('Resetting ViewModel state');
    _currentNavIndex = 1;
    _selectedCategoryIndex = 0;
    _activeFilters = ['All Levels'];
    _searchQuery = '';
    _isEnrolled = false;
    _expandedSections = [false, false, false, false];
    _currentPage = 1;
    notifyListeners();
    _searchCourses();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _apiService.dispose();
    debugPrint('Disposing Learning Hub ViewModel');
    super.dispose();
  }
}
