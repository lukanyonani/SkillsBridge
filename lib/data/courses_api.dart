// lib/services/courses_api_service.dart

import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:skillsbridge/data/offline/courses_data.dart';
import 'package:skillsbridge/models/course_models.dart';

/// Enhanced Courses API Service with Mock Mode Support
/// This service can switch between real API calls and local MIT course data
class CoursesApiService {
  // API Configuration
  static const String _baseUrl = 'https://courses-api-1qr7.onrender.com';
  static const Duration _timeout = Duration(seconds: 60);

  // Mock Mode Configuration
  static bool _mockMode = true;
  static bool get isMockMode => _mockMode;

  // Dio instance for making HTTP requests
  late final Dio _dio;

  // Singleton pattern
  static final CoursesApiService _instance = CoursesApiService._internal();
  factory CoursesApiService() => _instance;

  CoursesApiService._internal() {
    debugPrint('🚀 Initializing Courses API Service...');
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: _timeout,
        receiveTimeout: _timeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
          error: true,
          logPrint: (log) => debugPrint('🌐 Courses API: $log'),
        ),
      );
    }
  }

  /// Enable or disable mock mode
  /// When enabled, uses local MIT course data instead of API calls
  static void setMockMode(bool enabled) {
    _mockMode = enabled;
    debugPrint(
      _mockMode
          ? '🎭 Mock mode ENABLED - Using local MIT course data'
          : '🌐 Mock mode DISABLED - Using live API',
    );
  }

  /// Search for courses with advanced filters
  Future<SearchResponse> searchCourses({
    String? query,
    String? department,
    String? topic,
    String? level,
    bool? hasVideoLectures,
    bool? hasLectureNotes,
    bool? hasAssignments,
    String? language,
    String? sort,
    int page = 1,
    int limit = 20,
  }) async {
    if (_mockMode) {
      return _mockSearchCourses(
        query: query,
        department: department,
        topic: topic,
        level: level,
        hasVideoLectures: hasVideoLectures,
        hasLectureNotes: hasLectureNotes,
        hasAssignments: hasAssignments,
        language: language,
        sort: sort,
        page: page,
        limit: limit,
      );
    }

    // Real API implementation
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      if (query != null && query.isNotEmpty) {
        queryParams['q'] = query;
      }
      if (department != null && department.isNotEmpty) {
        queryParams['department'] = department;
      }
      if (topic != null && topic.isNotEmpty) {
        queryParams['topic'] = topic;
      }
      if (level != null && level.isNotEmpty) {
        queryParams['level'] = level;
      }
      if (hasVideoLectures != null) {
        queryParams['hasVideoLectures'] = hasVideoLectures.toString();
      }
      if (hasLectureNotes != null) {
        queryParams['hasLectureNotes'] = hasLectureNotes.toString();
      }
      if (hasAssignments != null) {
        queryParams['hasAssignments'] = hasAssignments.toString();
      }
      if (language != null && language.isNotEmpty) {
        queryParams['language'] = language;
      }
      if (sort != null && sort.isNotEmpty) {
        queryParams['sort'] = sort;
      }

      debugPrint('🔍 Fetching courses with params: $queryParams');

      final response = await _dio.get(
        '/courses/search',
        queryParameters: queryParams,
      );

      debugPrint('✅ Successfully fetched courses from API!');
      return SearchResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      throw CoursesApiException(
        message: 'Unexpected error occurred: $e',
        statusCode: 500,
      );
    }
  }

  /// Get featured courses
  Future<List<FeaturedCourse>> getFeaturedCourses() async {
    if (_mockMode) {
      return _mockGetFeaturedCourses();
    }

    try {
      debugPrint('🌟 Fetching featured courses from API...');
      final response = await _dio.get('/courses/featured');
      final List<dynamic> data = response.data as List<dynamic>;
      final featured = data
          .map((json) => FeaturedCourse.fromJson(json as Map<String, dynamic>))
          .toList();
      debugPrint('✅ Loaded ${featured.length} featured courses!');
      return featured;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      debugPrint('❌ Failed to fetch featured courses: $e');
      throw CoursesApiException(
        message: 'Failed to fetch featured courses: $e',
        statusCode: 500,
      );
    }
  }

  /// Get all topics and departments
  Future<TopicsResponse> getTopics() async {
    if (_mockMode) {
      return _mockGetTopics();
    }

    try {
      debugPrint('📚 Fetching topics from API...');
      final response = await _dio.get('/topics');
      debugPrint('✅ Loaded topics response!');
      return TopicsResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      debugPrint('❌ Failed to fetch topics: $e');
      throw CoursesApiException(
        message: 'Failed to fetch topics: $e',
        statusCode: 500,
      );
    }
  }

  /// Check API health status
  Future<HealthResponse> checkHealth() async {
    if (_mockMode) {
      return _mockCheckHealth();
    }

    try {
      debugPrint('🏥 Checking API health...');
      final response = await _dio.get('/health');
      final health = HealthResponse.fromJson(response.data);

      if (health.status == 'healthy') {
        debugPrint('✅ API is healthy! Timestamp: ${health.timestamp}');
      } else {
        debugPrint('⚠️ API health check returned: ${health.status}');
      }

      return health;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      debugPrint('❌ Health check failed: $e');
      throw CoursesApiException(
        message: 'Health check failed: $e',
        statusCode: 500,
      );
    }
  }

  // MOCK IMPLEMENTATIONS

  /// Mock search implementation using local MIT data
  Future<SearchResponse> _mockSearchCourses({
    String? query,
    String? department,
    String? topic,
    String? level,
    bool? hasVideoLectures,
    bool? hasLectureNotes,
    bool? hasAssignments,
    String? language,
    String? sort,
    int page = 1,
    int limit = 20,
  }) async {
    debugPrint(
      '🎭 Mock search with query: $query, dept: $department, level: $level',
    );

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));

    var courses = MITCourseData.getSampleCourses();

    // Apply filters
    if (query != null && query.isNotEmpty) {
      final searchQuery = query.toLowerCase();
      courses = courses
          .where(
            (course) =>
                course.title.toLowerCase().contains(searchQuery) ||
                course.description.toLowerCase().contains(searchQuery) ||
                course.instructor.toLowerCase().contains(searchQuery) ||
                course.tags.any(
                  (tag) => tag.toLowerCase().contains(searchQuery),
                ) ||
                course.id.toLowerCase().contains(searchQuery),
          )
          .toList();
    }

    if (department != null && department.isNotEmpty) {
      // Handle MIT department filtering (e.g., "6" for EECS, "18" for Math)
      courses = courses
          .where(
            (course) =>
                course.id.startsWith('$department.') ||
                course.id.startsWith(department),
          )
          .toList();
    }

    if (level != null && level.isNotEmpty) {
      final courseLevel = CourseLevel.fromString(level);
      courses = courses.where((course) => course.level == courseLevel).toList();
    }

    if (topic != null && topic.isNotEmpty) {
      courses = courses
          .where(
            (course) =>
                course.category.value.toLowerCase() == topic.toLowerCase() ||
                course.tags.any(
                  (tag) => tag.toLowerCase().contains(topic.toLowerCase()),
                ),
          )
          .toList();
    }

    if (hasVideoLectures == true) {
      courses = courses
          .where(
            (course) =>
                course.lessons.any((lesson) => lesson.type == LessonType.video),
          )
          .toList();
    }

    if (hasLectureNotes == true) {
      // For mock, assume all courses have lecture notes
      // In real implementation, you'd filter based on actual notes availability
    }

    if (hasAssignments == true) {
      // For mock, assume courses have assignments if they have non-video lessons
      courses = courses
          .where(
            (course) =>
                course.lessons.any((lesson) => lesson.type != LessonType.video),
          )
          .toList();
    }

    if (language != null &&
        language.isNotEmpty &&
        language.toLowerCase() != 'english') {
      // For mock, all courses are in English, so filter out if other language requested
      courses = [];
    }

    // Apply sorting
    if (sort != null) {
      switch (sort.toLowerCase()) {
        case 'newest':
          courses.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          break;
        case 'oldest':
          courses.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
          break;
        case 'rating':
          courses.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case 'enrollment':
          courses.sort(
            (a, b) => b.enrollmentCount.compareTo(a.enrollmentCount),
          );
          break;
        case 'title':
          courses.sort((a, b) => a.title.compareTo(b.title));
          break;
        case 'relevance':
        default:
          // Keep original order for relevance
          break;
      }
    }

    // Pagination
    final totalCount = courses.length;
    final totalPages = (totalCount / limit).ceil();
    final startIndex = (page - 1) * limit;
    final endIndex = min(startIndex + limit, totalCount);

    if (startIndex >= totalCount) {
      courses = [];
    } else {
      courses = courses.sublist(startIndex, endIndex);
    }

    debugPrint(
      '🎭 Mock search result: ${courses.length} courses (page $page/$totalPages)',
    );

    return SearchResponse(
      courses: courses,
      totalCount: totalCount,
      page: page,
      limit: limit,
      totalPages: totalPages,
      filters: {
        'query': query,
        'department': department,
        'topic': topic,
        'level': level,
        'hasVideoLectures': hasVideoLectures,
        'hasLectureNotes': hasLectureNotes,
        'hasAssignments': hasAssignments,
        'language': language,
        'sort': sort,
      },
    );
  }

  /// Mock featured courses implementation
  Future<List<FeaturedCourse>> _mockGetFeaturedCourses() async {
    debugPrint('🎭 Mock: Getting featured courses...');
    await Future.delayed(const Duration(milliseconds: 200));

    final allCourses = MITCourseData.getSampleCourses();
    final featuredCourses = allCourses
        .where((course) => course.isFeatured)
        .toList();

    final featured = featuredCourses.asMap().entries.map((entry) {
      final index = entry.key;
      final course = entry.value;
      return FeaturedCourse.fromCourse(
        course,
        reason: _getFeaturedReason(course),
        rank: index + 1,
      );
    }).toList();

    debugPrint('🎭 Mock: Returning ${featured.length} featured courses');
    return featured;
  }

  String _getFeaturedReason(Course course) {
    if (course.id == '18.06') {
      return 'Legendary mathematics course by Prof. Gilbert Strang';
    }
    if (course.id == '6.0001') {
      return 'Perfect introduction to programming and computer science';
    }
    if (course.id == '15.S12') {
      return 'Cutting-edge course on blockchain technology';
    }
    if (course.id == '18.065') {
      return 'Advanced linear algebra for modern applications';
    }
    return 'Highly rated course with excellent content';
  }

  /// Mock topics implementation
  Future<TopicsResponse> _mockGetTopics() async {
    debugPrint('🎭 Mock: Getting topics and departments...');
    await Future.delayed(const Duration(milliseconds: 150));

    return TopicsResponse(
      departments: [
        '6',
        '18',
        '8',
        '7',
        '2',
        '3',
        '5',
        '14',
        '15',
        '1',
        '4',
        '9',
        '11',
        '21L',
      ],
      topics: [
        'Programming',
        'Mathematics',
        'Physics',
        'Engineering',
        'Biology',
        'Chemistry',
        'Economics',
        'Business',
        'Data Science',
        'Artificial Intelligence',
        'Design',
        'Arts',
      ],
      levels: [
        'All Levels',
        'Beginner',
        'Intermediate',
        'Advanced',
        'Undergraduate',
        'Graduate',
      ],
      languages: ['English'],
      departmentNames: {
        '1': 'Civil & Environmental Engineering',
        '2': 'Mechanical Engineering',
        '3': 'Materials Science & Engineering',
        '4': 'Architecture',
        '5': 'Chemistry',
        '6': 'Electrical Engineering & Computer Science',
        '7': 'Biology',
        '8': 'Physics',
        '9': 'Brain & Cognitive Sciences',
        '11': 'Urban Studies & Planning',
        '14': 'Economics',
        '15': 'Management',
        '18': 'Mathematics',
        '21L': 'Literature',
      },
    );
  }

  /// Mock health check implementation
  Future<HealthResponse> _mockCheckHealth() async {
    debugPrint('🎭 Mock: Checking health...');
    await Future.delayed(const Duration(milliseconds: 100));

    return HealthResponse(
      status: 'healthy',
      timestamp: DateTime.now().toIso8601String(),
      info: {
        'mode': 'mock',
        'courses_available': MITCourseData.getSampleCourses().length,
        'departments': 14,
        'featured_courses': MITCourseData.getSampleCourses()
            .where((c) => c.isFeatured)
            .length,
      },
    );
  }

  /// Handle Dio errors gracefully
  CoursesApiException _handleDioError(DioException error) {
    debugPrint('❌ Courses API Error: ${error.type} - ${error.message}');

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return CoursesApiException(
          message: 'Request timed out. Please check your internet connection.',
          statusCode: 408,
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 500;
        final message =
            error.response?.data?['detail'] ??
            error.response?.data?['message'] ??
            'Server error occurred';
        return CoursesApiException(
          message: 'Server error ($statusCode): $message',
          statusCode: statusCode,
        );

      case DioExceptionType.cancel:
        return CoursesApiException(
          message: 'Request was cancelled',
          statusCode: 499,
        );

      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return CoursesApiException(
            message: 'No internet connection. Please check your network.',
            statusCode: 503,
          );
        }
        return CoursesApiException(
          message: 'Unknown error occurred: ${error.message}',
          statusCode: 500,
        );

      default:
        return CoursesApiException(
          message: 'Unexpected error: ${error.message}',
          statusCode: 500,
        );
    }
  }

  /// Clean up resources
  void dispose() {
    _dio.close();
    debugPrint('🧹 Courses API Service disposed');
  }
}

/// Custom Exception class for API errors
class CoursesApiException implements Exception {
  final String message;
  final int statusCode;
  final dynamic data;

  CoursesApiException({
    required this.message,
    required this.statusCode,
    this.data,
  });

  @override
  String toString() => 'CoursesApiException: [$statusCode] $message';

  bool get isNetworkError => statusCode == 503 || statusCode == 408;
  bool get isServerError => statusCode >= 500 && statusCode < 600;
  bool get isClientError => statusCode >= 400 && statusCode < 500;
}
