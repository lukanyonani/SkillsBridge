// courses_models.dart
// Dart models for the MIT OpenCourseWare API (https://courses-api-1qr7.onrender.com/)
// Generated with cheerful comments and full null-safety.
// These plain Dart classes provide `fromJson` / `toJson` factories so you can
// easily decode responses from the API and encode objects back to JSON.

import 'dart:convert';

/// Top-level helpers to decode API responses from raw JSON strings.
SearchResponse searchResponseFromJson(String str) =>
    SearchResponse.fromJson(json.decode(str));
FeaturedCourse featuredCourseFromJson(String str) =>
    FeaturedCourse.fromJson(json.decode(str));
TopicsResponse topicsResponseFromJson(String str) =>
    TopicsResponse.fromJson(json.decode(str));
HealthResponse healthResponseFromJson(String str) =>
    HealthResponse.fromJson(json.decode(str));

String searchResponseToJson(SearchResponse data) => json.encode(data.toJson());
String featuredCourseToJson(FeaturedCourse data) => json.encode(data.toJson());
String topicsResponseToJson(TopicsResponse data) => json.encode(data.toJson());
String healthResponseToJson(HealthResponse data) => json.encode(data.toJson());

// -----------------------------------------------------------------------------
// Basic small models
// -----------------------------------------------------------------------------

/// Represents an instructor of a course.
class Instructor {
  Instructor({required this.name, this.title});

  final String name;
  final String? title;

  factory Instructor.fromJson(Map<String, dynamic> json) => Instructor(
    name: json['name'] as String? ?? '',
    title: json['title'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    if (title != null) 'title': title,
  };
}

// -----------------------------------------------------------------------------
// Course model(s)
// -----------------------------------------------------------------------------

/// Core Course model that mirrors the JSON returned in the API's `courses` array.
class Course {
  Course({
    required this.id,
    this.courseNumber,
    required this.title,
    this.department,
    this.url,
    this.description,
    this.instructors = const [],
    this.semester,
    this.hasVideoLectures = false,
    this.hasLectureNotes = false,
    this.hasAssignments = false,
    this.level,
    this.topics = const [],
    this.languages = const [],
    this.license,
    this.estimatedHours,
    this.thumbnailImage,
  });

  final String id; // e.g. "6-006-spring-2020"
  final String? courseNumber; // e.g. "6.006"
  final String title;
  final String? department;
  final String? url;
  final String? description;
  final List<Instructor> instructors;
  final String? semester;
  final bool hasVideoLectures;
  final bool hasLectureNotes;
  final bool hasAssignments;
  final String? level;
  final List<String> topics;
  final List<String> languages;
  final String? license;
  final int? estimatedHours;
  final String? thumbnailImage;

  factory Course.fromJson(Map<String, dynamic> json) => Course(
    id: json['id'] as String? ?? '',
    courseNumber: json['courseNumber'] as String?,
    title: json['title'] as String? ?? '',
    department: json['department'] as String?,
    url: json['url'] as String?,
    description: json['description'] as String?,
    instructors:
        (json['instructors'] as List<dynamic>?)
            ?.map((e) => Instructor.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    semester: json['semester'] as String?,
    hasVideoLectures: json['hasVideoLectures'] as bool? ?? false,
    hasLectureNotes: json['hasLectureNotes'] as bool? ?? false,
    hasAssignments: json['hasAssignments'] as bool? ?? false,
    level: json['level'] as String?,
    topics:
        (json['topics'] as List<dynamic>?)?.map((e) => e as String).toList() ??
        [],
    languages:
        (json['languages'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [],
    license: json['license'] as String?,
    estimatedHours: json['estimatedHours'] is int
        ? json['estimatedHours'] as int
        : (json['estimatedHours'] != null
              ? int.tryParse(json['estimatedHours'].toString())
              : null),
    thumbnailImage: json['thumbnailImage'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    if (courseNumber != null) 'courseNumber': courseNumber,
    'title': title,
    if (department != null) 'department': department,
    if (url != null) 'url': url,
    if (description != null) 'description': description,
    'instructors': instructors.map((i) => i.toJson()).toList(),
    if (semester != null) 'semester': semester,
    'hasVideoLectures': hasVideoLectures,
    'hasLectureNotes': hasLectureNotes,
    'hasAssignments': hasAssignments,
    if (level != null) 'level': level,
    'topics': topics,
    'languages': languages,
    if (license != null) 'license': license,
    if (estimatedHours != null) 'estimatedHours': estimatedHours,
    if (thumbnailImage != null) 'thumbnailImage': thumbnailImage,
  };
}

/// FeaturedCourse contains extra metadata commonly returned by `/courses/featured`.
class FeaturedCourse extends Course {
  FeaturedCourse({
    required String id,
    String? courseNumber,
    required String title,
    String? department,
    String? url,
    String? description,
    List<Instructor> instructors = const [],
    String? semester,
    bool hasVideoLectures = false,
    bool hasLectureNotes = false,
    bool hasAssignments = false,
    String? level,
    List<String> topics = const [],
    List<String> languages = const [],
    String? license,
    int? estimatedHours,
    String? thumbnailImage,
    this.heroImage,
    this.rating,
    this.enrollmentCount,
    this.lastUpdated,
  }) : super(
         id: id,
         courseNumber: courseNumber,
         title: title,
         department: department,
         url: url,
         description: description,
         instructors: instructors,
         semester: semester,
         hasVideoLectures: hasVideoLectures,
         hasLectureNotes: hasLectureNotes,
         hasAssignments: hasAssignments,
         level: level,
         topics: topics,
         languages: languages,
         license: license,
         estimatedHours: estimatedHours,
         thumbnailImage: thumbnailImage,
       );

  final String? heroImage;
  final double? rating; // e.g. 4.8
  final int? enrollmentCount;
  final DateTime? lastUpdated;

  factory FeaturedCourse.fromJson(Map<String, dynamic> json) {
    final base = Course.fromJson(json);
    return FeaturedCourse(
      id: base.id,
      courseNumber: base.courseNumber,
      title: base.title,
      department: base.department,
      url: base.url,
      description: base.description,
      instructors: base.instructors,
      semester: base.semester,
      hasVideoLectures: base.hasVideoLectures,
      hasLectureNotes: base.hasLectureNotes,
      hasAssignments: base.hasAssignments,
      level: base.level,
      topics: base.topics,
      languages: base.languages,
      license: base.license,
      estimatedHours: base.estimatedHours,
      thumbnailImage: base.thumbnailImage,
      heroImage: json['heroImage'] as String? ?? base.thumbnailImage,
      rating: json['rating'] is num
          ? (json['rating'] as num).toDouble()
          : (json['rating'] != null
                ? double.tryParse(json['rating'].toString())
                : null),
      enrollmentCount: json['enrollmentCount'] is int
          ? json['enrollmentCount'] as int
          : (json['enrollmentCount'] != null
                ? int.tryParse(json['enrollmentCount'].toString())
                : null),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.tryParse(json['lastUpdated'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    map.addAll({
      if (heroImage != null) 'heroImage': heroImage,
      if (rating != null) 'rating': rating,
      if (enrollmentCount != null) 'enrollmentCount': enrollmentCount,
      if (lastUpdated != null) 'lastUpdated': lastUpdated!.toIso8601String(),
    });
    return map;
  }
}

// -----------------------------------------------------------------------------
// Pagination & Filters (returned alongside search results)
// -----------------------------------------------------------------------------

class Pagination {
  Pagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  final int total;
  final int page;
  final int limit;
  final int totalPages;

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    total: (json['total'] as num?)?.toInt() ?? 0,
    page: (json['page'] as num?)?.toInt() ?? 1,
    limit: (json['limit'] as num?)?.toInt() ?? 20,
    totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
  );

  Map<String, dynamic> toJson() => {
    'total': total,
    'page': page,
    'limit': limit,
    'totalPages': totalPages,
  };
}

class Filters {
  Filters({this.departments = const [], this.topics = const []});

  final List<String> departments;
  final List<String> topics;

  factory Filters.fromJson(Map<String, dynamic> json) => Filters(
    departments:
        (json['departments'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [],
    topics:
        (json['topics'] as List<dynamic>?)?.map((e) => e as String).toList() ??
        [],
  );

  Map<String, dynamic> toJson() => {
    'departments': departments,
    'topics': topics,
  };
}

// -----------------------------------------------------------------------------
// Search Response wrapper
// -----------------------------------------------------------------------------

class SearchResponse {
  SearchResponse({
    required this.courses,
    required this.pagination,
    required this.filters,
  });

  final List<Course> courses;
  final Pagination pagination;
  final Filters filters;

  factory SearchResponse.fromJson(Map<String, dynamic> json) => SearchResponse(
    courses:
        (json['courses'] as List<dynamic>?)
            ?.map((e) => Course.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    pagination: json['pagination'] != null
        ? Pagination.fromJson(json['pagination'] as Map<String, dynamic>)
        : Pagination(total: 0, page: 1, limit: 20, totalPages: 1),
    filters: json['filters'] != null
        ? Filters.fromJson(json['filters'] as Map<String, dynamic>)
        : Filters(),
  );

  Map<String, dynamic> toJson() => {
    'courses': courses.map((c) => c.toJson()).toList(),
    'pagination': pagination.toJson(),
    'filters': filters.toJson(),
  };
}

// -----------------------------------------------------------------------------
// Topics response
// -----------------------------------------------------------------------------

class TopicItem {
  TopicItem({
    required this.id,
    required this.name,
    this.description,
    this.subcategories = const [],
    this.courseCount,
  });

  final String id;
  final String name;
  final String? description;
  final List<String> subcategories;
  final int? courseCount;

  factory TopicItem.fromJson(Map<String, dynamic> json) => TopicItem(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    description: json['description'] as String?,
    subcategories:
        (json['subcategories'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [],
    courseCount: json['courseCount'] is int
        ? json['courseCount'] as int
        : (json['courseCount'] != null
              ? int.tryParse(json['courseCount'].toString())
              : null),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (description != null) 'description': description,
    'subcategories': subcategories,
    if (courseCount != null) 'courseCount': courseCount,
  };
}

class TopicsResponse {
  TopicsResponse({
    this.topics = const [],
    this.departments = const [],
    this.availableFilters,
  });

  final List<TopicItem> topics;
  final List<String> departments;
  final Filters? availableFilters;

  factory TopicsResponse.fromJson(Map<String, dynamic> json) => TopicsResponse(
    topics:
        (json['topics'] as List<dynamic>?)
            ?.map((e) => TopicItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    departments:
        (json['departments'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [],
    availableFilters: json['availableFilters'] != null
        ? Filters.fromJson(json['availableFilters'] as Map<String, dynamic>)
        : null,
  );

  Map<String, dynamic> toJson() => {
    'topics': topics.map((t) => t.toJson()).toList(),
    'departments': departments,
    if (availableFilters != null)
      'availableFilters': availableFilters!.toJson(),
  };
}

// -----------------------------------------------------------------------------
// Health response
// -----------------------------------------------------------------------------

class HealthResponse {
  HealthResponse({required this.status, required this.timestamp});

  final String status;
  final DateTime timestamp;

  factory HealthResponse.fromJson(Map<String, dynamic> json) => HealthResponse(
    status: json['status'] as String? ?? 'unknown',
    timestamp: DateTime.parse(json['timestamp'] as String),
  );

  Map<String, dynamic> toJson() => {
    'status': status,
    'timestamp': timestamp.toIso8601String(),
  };
}

// -----------------------------------------------------------------------------
// End of models
// -----------------------------------------------------------------------------

// Small usage example (commented):
//
// final resp = await http.get(Uri.parse('https://courses-api-1qr7.onrender.com/courses/search'));
// final model = SearchResponse.fromJson(json.decode(resp.body));
// print('Found ${model.pagination.total} courses');
//
// If you want json_serializable or freezed-compatible versions, tell me and
// I will generate those annotations & build_runner commands for you.
