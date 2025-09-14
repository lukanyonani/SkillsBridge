// 🎓 MIT OCW API Service - Your Gateway to World-Class Education!
// This service connects to the MIT OpenCourseWare scraping API and handles all the heavy lifting.
// Built with lively comments, detailed logging, and robust error handling. 🚀
// Supports searching with filters, featured courses, topics, and health checks.

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:skillsbridge/models/course_models.dart';

// 🚀 Main API Service Class
class CoursesApiService {
  // 🌍 API Configuration
  static const String _baseUrl = 'https://courses-api-1qr7.onrender.com';
  static const Duration _timeout = Duration(seconds: 60);

  // 🔧 Dio instance for making HTTP requests
  late final Dio _dio;

  // 🎯 Singleton pattern - only one instance of this service exists
  static final CoursesApiService _instance = CoursesApiService._internal();
  factory CoursesApiService() => _instance;

  // 🏗️ Private constructor for singleton
  CoursesApiService._internal() {
    debugPrint('🚀 Initializing Courses API Service with lively energy!');
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

    // 🔍 Add logging interceptor in debug mode for easier debugging
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
      debugPrint('🛡️ Debug mode active - Full logging enabled!');
    }
  }

  // 🎯 Search for courses with advanced filters
  // This is the main method you'll use to discover courses!
  Future<SearchResponse> searchCourses({
    String? query,
    String? department,
    String? topic,
    String? level,
    bool? hasVideoLectures,
    bool? hasLectureNotes,
    bool? hasAssignments,
    String? language,
    String? sort, // e.g., 'relevance', 'newest', 'title'
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // 🎨 Building query parameters dynamically - Let's filter smartly!
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      // 🔍 Add filters if provided - More options for precise searches!
      if (query != null && query.isNotEmpty) {
        queryParams['q'] = query;
        debugPrint('🔎 Adding search query: $query');
      }
      if (department != null && department.isNotEmpty) {
        queryParams['department'] = department;
        debugPrint('🏫 Filtering by department: $department');
      }
      if (topic != null && topic.isNotEmpty) {
        queryParams['topic'] = topic;
        debugPrint('📚 Filtering by topic: $topic');
      }
      if (level != null && level.isNotEmpty) {
        queryParams['level'] = level;
        debugPrint('🎓 Filtering by level: $level');
      }
      if (hasVideoLectures != null) {
        queryParams['hasVideoLectures'] = hasVideoLectures.toString();
        debugPrint('🎥 Filtering for video lectures: $hasVideoLectures');
      }
      if (hasLectureNotes != null) {
        queryParams['hasLectureNotes'] = hasLectureNotes.toString();
        debugPrint('📝 Filtering for lecture notes: $hasLectureNotes');
      }
      if (hasAssignments != null) {
        queryParams['hasAssignments'] = hasAssignments.toString();
        debugPrint('📚 Filtering for assignments: $hasAssignments');
      }
      if (language != null && language.isNotEmpty) {
        queryParams['language'] = language;
        debugPrint('🌐 Filtering by language: $language');
      }
      if (sort != null && sort.isNotEmpty) {
        queryParams['sort'] = sort;
        debugPrint('📊 Sorting by: $sort');
      }

      debugPrint('🔍 Fetching courses with params: $queryParams');

      // 🚀 Make the API call - Fingers crossed for great courses!
      final response = await _dio.get(
        '/courses/search',
        queryParameters: queryParams,
      );

      // ✅ Parse and return the response - Knowledge incoming!
      debugPrint(
        '✅ Successfully fetched ${response.data['courses'].length} courses!',
      );
      return SearchResponse.fromJson(response.data);
    } on DioException catch (e) {
      // 🚨 Handle Dio-specific errors gracefully
      throw _handleDioError(e);
    } catch (e) {
      // 🔥 Handle any other errors - Stay calm!
      debugPrint('❌ Unexpected error: $e');
      throw CoursesApiException(
        message: 'Unexpected error occurred: $e',
        statusCode: 500,
      );
    }
  }

  // 🌟 Get featured courses
  // Perfect for highlighting popular or recommended courses!
  Future<List<FeaturedCourse>> getFeaturedCourses() async {
    try {
      debugPrint('🌟 Fetching featured courses...');

      final response = await _dio.get('/courses/featured');

      // ✅ Parse the list of featured courses
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

  // 📚 Get all topics and departments
  // Great for building navigation or filters!
  Future<TopicsResponse> getTopics() async {
    try {
      debugPrint('📚 Fetching topics and departments...');

      final response = await _dio.get('/topics');

      // ✅ Parse and return
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

  // 🏥 Check API health status
  // Use this to verify the API is up and running!
  Future<HealthResponse> checkHealth() async {
    try {
      debugPrint('🏥 Checking API health...');

      final response = await _dio.get('/health');

      final health = HealthResponse.fromJson(response.data);

      // 🎉 Log the health status with enthusiasm!
      if (health.status == 'healthy') {
        debugPrint(
          '✅ API is healthy and ready to teach! Timestamp: ${health.timestamp}',
        );
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

  // 🔥 Private method to handle Dio errors gracefully - No panic!
  CoursesApiException _handleDioError(DioException error) {
    debugPrint('❌ Courses API Error: ${error.type} - ${error.message}');

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return CoursesApiException(
          message:
              '⏱️ Request timed out. Please check your internet connection.',
          statusCode: 408,
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 500;
        final message =
            error.response?.data?['detail'] ??
            error.response?.data?['message'] ??
            'Server error occurred';
        return CoursesApiException(
          message: '🚨 Server error ($statusCode): $message',
          statusCode: statusCode,
        );

      case DioExceptionType.cancel:
        return CoursesApiException(
          message: '🛑 Request was cancelled',
          statusCode: 499,
        );

      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return CoursesApiException(
            message: '📵 No internet connection. Please check your network.',
            statusCode: 503,
          );
        }
        return CoursesApiException(
          message: '❓ Unknown error occurred: ${error.message}',
          statusCode: 500,
        );

      default:
        return CoursesApiException(
          message: '⚠️ Unexpected error: ${error.message}',
          statusCode: 500,
        );
    }
  }

  // 🧹 Clean up resources (call this when disposing) - Keep it tidy!
  void dispose() {
    _dio.close();
    debugPrint('🧹 Courses API Service disposed - Goodbye for now!');
  }
}

// 🚨 Custom Exception class for API errors - Handle with care!
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

  // 🎯 Helper to check if this is a network error
  bool get isNetworkError => statusCode == 503 || statusCode == 408;

  // 🎯 Helper to check if this is a server error
  bool get isServerError => statusCode >= 500 && statusCode < 600;

  // 🎯 Helper to check if this is a client error
  bool get isClientError => statusCode >= 400 && statusCode < 500;
}
