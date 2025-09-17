// lib/viewmodels/learning_screen_vm.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillsbridge/data/courses_api.dart';
import 'package:skillsbridge/models/course_models.dart';

// Provider for the API service
final coursesApiServiceProvider = Provider<CoursesApiService>((ref) {
  return CoursesApiService();
});

// Provider for mock mode state
final useMockModeProvider = StateProvider<bool>((ref) {
  return true; // Start with mock mode enabled for development
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
      return _courses.firstWhere(
        (course) => course.id == featured.id,
        orElse: () => Course(
          id: featured.id,
          title: featured.title,
          description: featured.description,
          instructor: featured.instructor,
          thumbnailUrl: featured.thumbnailUrl,
          level: featured.level,
          category: featured.category,
          rating: featured.rating,
          reviewCount: 0,
          pricing: CoursePricing(type: PricingType.free),
          totalDuration: Duration.zero,
          lessons: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          enrollmentCount: featured.enrollmentCount,
        ),
      );
    }
    return null;
  }

  List<Course> get popularCourses {
    return _courses.take(10).toList();
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

      final levelFilter = _activeFilters.firstWhere(
        (filter) => [
          'Beginner',
          'Intermediate',
          'Advanced',
          'Undergraduate',
          'Graduate',
        ].contains(filter),
        orElse: () => '',
      );

      final response = await _apiService.searchCourses(
        query: _searchQuery.isNotEmpty ? _searchQuery : null,
        topic: selectedCategory != null && selectedCategory != 'All'
            ? selectedCategory
            : null,
        level: levelFilter.isNotEmpty ? levelFilter : null,
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
        'Search completed: ${response.courses.length} courses loaded, page $_currentPage/${response.totalPages}',
      );
      _clearError();
    } catch (e) {
      _setError('Failed to search courses: $e');
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
    debugPrint('Disposing Learning Hub ViewModel');
    super.dispose();
  }
}

/// Usage Example in main.dart or app initialization:
/// 
/// void main() {
///   // Enable mock mode for development
///   CoursesApiService.setMockMode(true);
///   
///   runApp(
///     ProviderScope(
///       child: MyApp(),
///     ),
///   );
/// }
/// 
/// Usage in Widget:
/// 
/// class LearningScreen extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final viewModel = ref.watch(learningHubViewModelProvider);
///     
///     if (viewModel.isLoading) {
///       return CircularProgressIndicator();
///     }
///     
///     return Column(
///       children: [
///         // Search functionality
///         TextField(
///           onChanged: viewModel.updateSearchQuery,
///           decoration: InputDecoration(hintText: 'Search courses...'),
///         ),
///         
///         // Categories
///         ...viewModel.categories.asMap().entries.map((entry) {
///           final index = entry.key;
///           final category = entry.value;
///           return FilterChip(
///             label: Text(category),
///             selected: viewModel.selectedCategoryIndex == index,
///             onSelected: (_) => viewModel.selectCategory(index),
///           );
///         }),
///         
///         // Courses list
///         ...viewModel.courses.map((course) => 
///           ListTile(
///             title: Text(course.title),
///             subtitle: Text(course.instructor),
///             trailing: Text('⭐ ${course.rating}'),
///           ),
///         ),
///         
///         // Load more button
///         if (viewModel.hasMorePages)
///           ElevatedButton(
///             onPressed: viewModel.loadMoreCourses,
///             child: Text('Load More'),
///           ),
///       ],
///     );
///   }
/// }