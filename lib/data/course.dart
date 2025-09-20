// data/mit_ocw_api.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

// ============================================================================
// MODELS
// ============================================================================

class Instructor {
  final String name;
  final String title;

  Instructor({required this.name, required this.title});

  factory Instructor.fromJson(Map<String, dynamic> json) {
    return Instructor(name: json['name'] ?? '', title: json['title'] ?? '');
  }

  Map<String, dynamic> toJson() => {'name': name, 'title': title};

  @override
  String toString() => '$title $name';
}

class Video {
  final String title;
  final String url;

  Video({required this.title, required this.url});

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(title: json['title'] ?? '', url: json['url'] ?? '');
  }

  Map<String, dynamic> toJson() => {'title': title, 'url': url};

  @override
  String toString() => 'Video: $title';
}

enum CourseLevel { undergraduate, graduate, all }

class Course {
  final String id;
  final String courseNumber;
  final String title;
  final String department;
  final String url;
  final String videoGalleryUrl;
  final String description;
  final List<Instructor> instructors;
  final String semester;
  final bool hasVideoLectures;
  final bool hasLectureNotes;
  final bool hasAssignments;
  final CourseLevel level;
  final List<String> topics;
  final List<String> languages;
  final String license;
  final int units;
  final int estimatedHours;
  final String thumbnailImage;
  final String videoPlaylistId;
  final List<Video> sampleVideos;
  final String? heroImage;
  final double? rating;
  final int? enrollmentCount;
  final DateTime? lastUpdated;
  final bool? featured;

  Course({
    required this.id,
    required this.courseNumber,
    required this.title,
    required this.department,
    required this.url,
    required this.videoGalleryUrl,
    required this.description,
    required this.instructors,
    required this.semester,
    required this.hasVideoLectures,
    required this.hasLectureNotes,
    required this.hasAssignments,
    required this.level,
    required this.topics,
    required this.languages,
    required this.license,
    required this.units,
    required this.estimatedHours,
    required this.thumbnailImage,
    required this.videoPlaylistId,
    required this.sampleVideos,
    this.heroImage,
    this.rating,
    this.enrollmentCount,
    this.lastUpdated,
    this.featured,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    final courseTitle = json['title'] ?? 'Unknown Course';
    debugPrint('Parsing course: $courseTitle');

    try {
      final instructors =
          (json['instructors'] as List<dynamic>?)
              ?.map((e) => Instructor.fromJson(e))
              .toList() ??
          [];

      final sampleVideos =
          (json['sampleVideos'] as List<dynamic>?)
              ?.map((e) => Video.fromJson(e))
              .toList() ??
          [];

      return Course(
        id: json['id'] ?? '',
        courseNumber: json['courseNumber'] ?? '',
        title: courseTitle,
        department: json['department'] ?? '',
        url: json['url'] ?? '',
        videoGalleryUrl: json['videoGalleryUrl'] ?? '',
        description: json['description'] ?? '',
        instructors: instructors,
        semester: json['semester'] ?? '',
        hasVideoLectures: json['hasVideoLectures'] ?? false,
        hasLectureNotes: json['hasLectureNotes'] ?? false,
        hasAssignments: json['hasAssignments'] ?? false,
        level: _parseCourseLevel(json['level']),
        topics:
            (json['topics'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        languages:
            (json['languages'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        license: json['license'] ?? '',
        units: json['units'] ?? 0,
        estimatedHours: json['estimatedHours'] ?? 0,
        thumbnailImage: json['thumbnailImage'] ?? '',
        videoPlaylistId: json['videoPlaylistId'] ?? '',
        sampleVideos: sampleVideos,
        heroImage: json['heroImage'],
        rating: json['rating']?.toDouble(),
        enrollmentCount: json['enrollmentCount'],
        lastUpdated: json['lastUpdated'] != null
            ? DateTime.parse(json['lastUpdated'])
            : null,
        featured: json['featured'],
      );
    } catch (e) {
      debugPrint('Failed to parse course: $courseTitle - $e');
      rethrow;
    }
  }

  static CourseLevel _parseCourseLevel(String? level) {
    switch (level?.toLowerCase()) {
      case 'undergraduate':
        return CourseLevel.undergraduate;
      case 'graduate':
        return CourseLevel.graduate;
      default:
        return CourseLevel.undergraduate;
    }
  }

  // Helper getters for compatibility with existing ViewModel
  String get instructor =>
      instructors.isNotEmpty ? instructors.first.name : 'Unknown Instructor';

  String get category => topics.isNotEmpty ? topics.first : 'General';

  String get thumbnailUrl => thumbnailImage;

  int get reviewCount => 0; // Not available in API

  Duration get totalDuration => Duration(hours: estimatedHours);

  List<dynamic> get lessons => sampleVideos; // Map videos to lessons

  @override
  String toString() => '$courseNumber: $title';
}

class FeaturedCourse {
  final String id;
  final String title;
  final String description;
  final String instructor;
  final String thumbnailUrl;
  final String level;
  final String category;
  final double? rating;
  final int enrollmentCount;

  FeaturedCourse({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    required this.thumbnailUrl,
    required this.level,
    required this.category,
    this.rating,
    required this.enrollmentCount,
  });

  factory FeaturedCourse.fromCourse(Course course) {
    return FeaturedCourse(
      id: course.id,
      title: course.title,
      description: course.description,
      instructor: course.instructor,
      thumbnailUrl: course.thumbnailUrl,
      level: course.level.name,
      category: course.category,
      rating: course.rating,
      enrollmentCount: course.enrollmentCount ?? 0,
    );
  }
}

class Topic {
  final String id;
  final String name;
  final String description;
  final int courseCount;

  Topic({
    required this.id,
    required this.name,
    required this.description,
    required this.courseCount,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      courseCount: json['courseCount'] ?? 0,
    );
  }

  @override
  String toString() => '$name ($courseCount courses)';
}

class Pagination {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  Pagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      totalPages: json['totalPages'] ?? 1,
    );
  }
}

class AppliedFilters {
  final String? query;
  final String? department;
  final String? topic;
  final bool? lectureVideos;

  AppliedFilters({this.query, this.department, this.topic, this.lectureVideos});

  factory AppliedFilters.fromJson(Map<String, dynamic> json) {
    return AppliedFilters(
      query: json['query'],
      department: json['department'],
      topic: json['topic'],
      lectureVideos: json['lectureVideos'],
    );
  }

  @override
  String toString() {
    final parts = <String>[];
    if (query != null) parts.add('query="$query"');
    if (department != null) parts.add('department="$department"');
    if (topic != null) parts.add('topic="$topic"');
    if (lectureVideos != null) parts.add('lectureVideos=$lectureVideos');
    return parts.isEmpty ? 'No filters' : parts.join(', ');
  }
}

class FilterInfo {
  final AppliedFilters appliedFilters;

  FilterInfo({required this.appliedFilters});

  factory FilterInfo.fromJson(Map<String, dynamic> json) {
    return FilterInfo(
      appliedFilters: AppliedFilters.fromJson(json['appliedFilters'] ?? {}),
    );
  }
}

class SearchResponse {
  final List<Course> courses;
  final Pagination pagination;
  final FilterInfo filters;
  final String source;

  // Helper getters for compatibility
  int get totalPages => pagination.totalPages;

  SearchResponse({
    required this.courses,
    required this.pagination,
    required this.filters,
    required this.source,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    debugPrint('Parsing search response...');
    final courses = (json['courses'] as List<dynamic>)
        .map((e) => Course.fromJson(e))
        .toList();

    return SearchResponse(
      courses: courses,
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
      filters: FilterInfo.fromJson(json['filters'] ?? {}),
      source: json['source'] ?? '',
    );
  }
}

class CourseVideosResponse {
  final String courseId;
  final List<Video> videos;
  final int count;

  CourseVideosResponse({
    required this.courseId,
    required this.videos,
    required this.count,
  });

  factory CourseVideosResponse.fromJson(Map<String, dynamic> json) {
    debugPrint('Parsing videos for course: ${json['courseId']}');
    final videos = (json['videos'] as List<dynamic>)
        .map((e) => Video.fromJson(e))
        .toList();

    return CourseVideosResponse(
      courseId: json['courseId'] ?? '',
      videos: videos,
      count: json['count'] ?? 0,
    );
  }
}

class TopicsResponse {
  final List<String> topics; // Changed to List<String> for compatibility
  final List<String> departments;
  final Map<String, String> departmentNames;
  final int count;
  final String source;

  TopicsResponse({
    required this.topics,
    required this.departments,
    required this.departmentNames,
    required this.count,
    required this.source,
  });

  factory TopicsResponse.fromJson(Map<String, dynamic> json) {
    debugPrint('Parsing topics and departments...');

    // Extract topic names as strings for compatibility
    final topicsList =
        (json['topics'] as List<dynamic>?)?.map((e) {
          if (e is Map<String, dynamic>) {
            return e['name']?.toString() ?? '';
          }
          return e.toString();
        }).toList() ??
        [];

    final departments =
        (json['departments'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    // Create department names map
    final deptNames = <String, String>{};
    for (final dept in departments) {
      deptNames[dept] = dept; // Use department code as name for now
    }

    return TopicsResponse(
      topics: topicsList,
      departments: departments,
      departmentNames: deptNames,
      count: json['count'] ?? 0,
      source: json['source'] ?? '',
    );
  }
}

// ============================================================================
// EXCEPTIONS
// ============================================================================

class MitOcwApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  MitOcwApiException(this.message, {this.statusCode, this.originalError});

  @override
  String toString() => 'MitOcwApiException: $message';
}

class NetworkException extends MitOcwApiException {
  NetworkException(super.message, {super.originalError});
}

class ApiResponseException extends MitOcwApiException {
  ApiResponseException(super.message, int statusCode, {super.originalError})
    : super(statusCode: statusCode);
}

class ParseException extends MitOcwApiException {
  ParseException(super.message, {super.originalError});
}

// ============================================================================
// API SERVICE (Compatible with ViewModel)
// ============================================================================

class CoursesApiService {
  static const String _baseUrl = 'https://courses-api-1qr7.onrender.com';
  static bool isMockMode = false;
  final http.Client _httpClient;
  final Duration _timeout;

  CoursesApiService({
    http.Client? httpClient,
    Duration timeout = const Duration(seconds: 30),
  }) : _httpClient = httpClient ?? http.Client(),
       _timeout = timeout {
    debugPrint('MIT OCW API Service initialized with base URL: $_baseUrl');
  }

  static void setMockMode(bool useMock) {
    isMockMode = useMock;
    debugPrint('Mock mode set to: $useMock');
  }

  Future<Map<String, dynamic>> _makeRequest(
    String endpoint, {
    Map<String, String>? queryParameters,
  }) async {
    if (isMockMode) {
      debugPrint('Using mock data for: $endpoint');
      return _getMockData(endpoint);
    }

    final uri = Uri.parse(
      '$_baseUrl$endpoint',
    ).replace(queryParameters: queryParameters);
    debugPrint('Making request to: $uri');

    try {
      final response = await _httpClient
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(_timeout);

      if (response.statusCode == 200) {
        debugPrint('Request successful (${response.statusCode})');
        try {
          final jsonData = json.decode(response.body) as Map<String, dynamic>;
          return jsonData;
        } catch (e) {
          debugPrint('JSON parsing failed: $e');
          throw ParseException(
            'Failed to parse JSON response',
            originalError: e,
          );
        }
      } else {
        debugPrint('Request failed with status ${response.statusCode}');
        throw ApiResponseException(
          'API request failed: ${response.reasonPhrase}',
          response.statusCode,
          originalError: response.body,
        );
      }
    } catch (e) {
      if (e is MitOcwApiException) rethrow;
      debugPrint('Network error occurred: $e');
      throw NetworkException(
        'Network request failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Map<String, dynamic> _getMockData(String endpoint) {
    // Return mock data for development
    if (endpoint.contains('/topics')) {
      return {
        'topics': ['Mathematics', 'Physics', 'Computer Science', 'Engineering'],
        'departments': ['MIT', 'Harvard', 'Stanford'],
        'count': 4,
        'source': 'mock',
      };
    }

    if (endpoint.contains('/courses/search')) {
      return {
        'courses': [
          _createMockCourse('1', 'Introduction to Computer Science'),
          _createMockCourse('2', 'Advanced Mathematics'),
        ],
        'pagination': {'total': 2, 'page': 1, 'limit': 20, 'totalPages': 1},
        'filters': {'appliedFilters': {}},
        'source': 'mock',
      };
    }

    return {};
  }

  Map<String, dynamic> _createMockCourse(String id, String title) {
    return {
      'id': id,
      'courseNumber': 'CS$id',
      'title': title,
      'department': 'Computer Science',
      'url': 'https://example.com/course/$id',
      'videoGalleryUrl': '',
      'description': 'A comprehensive course on $title',
      'instructors': [
        {'name': 'Prof. Smith', 'title': 'Professor'},
      ],
      'semester': 'Fall 2024',
      'hasVideoLectures': true,
      'hasLectureNotes': true,
      'hasAssignments': false,
      'level': 'undergraduate',
      'topics': ['Computer Science'],
      'languages': ['English'],
      'license': 'CC BY-NC-SA',
      'units': 12,
      'estimatedHours': 120,
      'thumbnailImage': 'https://via.placeholder.com/300x200',
      'videoPlaylistId': '',
      'sampleVideos': [],
      'rating': 4.5,
      'enrollmentCount': 1000,
    };
  }

  // API Methods compatible with ViewModel

  Future<TopicsResponse> getTopics() async {
    debugPrint('Fetching topics from API...');
    try {
      final response = await _makeRequest('/topics');
      return TopicsResponse.fromJson(response);
    } catch (e) {
      debugPrint('Failed to get topics: $e');
      throw MitOcwApiException('Failed to get topics: ${e.toString()}');
    }
  }

  Future<List<FeaturedCourse>> getFeaturedCourses() async {
    debugPrint('Fetching featured courses from API...');
    try {
      final response = await _makeRequest('/courses/featured');
      if (response['id'] != null) {
        // Single featured course response
        final course = Course.fromJson(response);
        return [FeaturedCourse.fromCourse(course)];
      } else if (response['courses'] != null) {
        // Multiple featured courses
        final courses = (response['courses'] as List<dynamic>)
            .map((e) => Course.fromJson(e))
            .map((c) => FeaturedCourse.fromCourse(c))
            .toList();
        return courses;
      }
      return [];
    } catch (e) {
      debugPrint('Failed to get featured courses: $e');
      // Return empty list instead of throwing to maintain UI stability
      return [];
    }
  }

  Future<SearchResponse> searchCourses({
    String? query,
    String? department,
    String? topic,
    String? level,
    bool? hasVideoLectures,
    String? sort,
    int? page,
    int? limit,
  }) async {
    debugPrint(
      'Searching courses with query: $query, topic: $topic, level: $level',
    );

    try {
      final Map<String, String> queryParams = {};

      if (query != null && query.isNotEmpty) queryParams['q'] = query;
      if (department != null && department.isNotEmpty)
        queryParams['department'] = department;
      if (topic != null && topic.isNotEmpty && topic != 'All')
        queryParams['topic'] = topic;
      if (level != null && level.isNotEmpty) {
        // Map level to API expected format
        final apiLevel = level.toLowerCase().replaceAll(' ', '');
        if (apiLevel == 'undergraduate' || apiLevel == 'graduate') {
          queryParams['level'] = apiLevel;
        }
      }
      if (hasVideoLectures != null)
        queryParams['hasVideoLectures'] = hasVideoLectures.toString();
      if (sort != null) queryParams['sort'] = sort;
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();

      final response = await _makeRequest(
        '/courses/search',
        queryParameters: queryParams,
      );
      return SearchResponse.fromJson(response);
    } catch (e) {
      debugPrint('Failed to search courses: $e');
      throw MitOcwApiException('Failed to search courses: ${e.toString()}');
    }
  }

  Future<CourseVideosResponse> getCourseVideos(String courseId) async {
    if (courseId.isEmpty) {
      throw MitOcwApiException('Course ID cannot be empty');
    }

    debugPrint('Fetching videos for course: $courseId');
    try {
      final response = await _makeRequest('/courses/$courseId/videos');
      return CourseVideosResponse.fromJson(response);
    } catch (e) {
      debugPrint('Failed to get course videos: $e');
      throw MitOcwApiException('Failed to get course videos: ${e.toString()}');
    }
  }

  void dispose() {
    debugPrint('Disposing API service resources');
    _httpClient.close();
  }
}

// Mock pricing model for compatibility
enum PricingType { free, paid }

class CoursePricing {
  final PricingType type;
  final double? price;

  CoursePricing({required this.type, this.price});
}
