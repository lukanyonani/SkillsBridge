// lib/models/course_models.dart

class Course {
  final String id;
  final String title;
  final String description;
  final String instructor;
  final String thumbnailUrl;
  final CourseLevel level;
  final CourseCategory category;
  final double rating;
  final int reviewCount;
  final CoursePricing pricing;
  final Duration totalDuration;
  final List<Lesson> lessons;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFeatured;
  final bool isPopular;
  final List<String> tags;
  final int enrollmentCount;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    required this.thumbnailUrl,
    required this.level,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.pricing,
    required this.totalDuration,
    required this.lessons,
    required this.createdAt,
    required this.updatedAt,
    this.isFeatured = false,
    this.isPopular = false,
    this.tags = const [],
    this.enrollmentCount = 0,
  });

  // Computed properties
  int get totalVideos => lessons.length;

  String get formattedDuration {
    final hours = totalDuration.inHours;
    final minutes = totalDuration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String get formattedRating => rating.toStringAsFixed(1);

  bool get isFree => pricing.type == PricingType.free;

  // Factory constructor from JSON
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      instructor: json['instructor'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      level: CourseLevel.fromString(json['level'] as String),
      category: CourseCategory.fromString(json['category'] as String),
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      pricing: CoursePricing.fromJson(json['pricing'] as Map<String, dynamic>),
      totalDuration: Duration(seconds: json['totalDurationSeconds'] as int),
      lessons: (json['lessons'] as List<dynamic>)
          .map(
            (lessonJson) => Lesson.fromJson(lessonJson as Map<String, dynamic>),
          )
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isFeatured: json['isFeatured'] as bool? ?? false,
      isPopular: json['isPopular'] as bool? ?? false,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      enrollmentCount: json['enrollmentCount'] as int? ?? 0,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'instructor': instructor,
      'thumbnailUrl': thumbnailUrl,
      'level': level.value,
      'category': category.value,
      'rating': rating,
      'reviewCount': reviewCount,
      'pricing': pricing.toJson(),
      'totalDurationSeconds': totalDuration.inSeconds,
      'lessons': lessons.map((lesson) => lesson.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isFeatured': isFeatured,
      'isPopular': isPopular,
      'tags': tags,
      'enrollmentCount': enrollmentCount,
    };
  }

  // Copy with method for immutable updates
  Course copyWith({
    String? id,
    String? title,
    String? description,
    String? instructor,
    String? thumbnailUrl,
    CourseLevel? level,
    CourseCategory? category,
    double? rating,
    int? reviewCount,
    CoursePricing? pricing,
    Duration? totalDuration,
    List<Lesson>? lessons,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFeatured,
    bool? isPopular,
    List<String>? tags,
    int? enrollmentCount,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      instructor: instructor ?? this.instructor,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      level: level ?? this.level,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      pricing: pricing ?? this.pricing,
      totalDuration: totalDuration ?? this.totalDuration,
      lessons: lessons ?? this.lessons,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFeatured: isFeatured ?? this.isFeatured,
      isPopular: isPopular ?? this.isPopular,
      tags: tags ?? this.tags,
      enrollmentCount: enrollmentCount ?? this.enrollmentCount,
    );
  }
}

class Lesson {
  final String id;
  final String title;
  final String description;
  final String videoUrl;
  final String? thumbnailUrl;
  final Duration duration;
  final int orderIndex;
  final bool isPreview;
  final LessonType type;
  final List<String> resources; // URLs to additional resources
  final Map<String, dynamic>? metadata; // Additional lesson data

  Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.duration,
    required this.orderIndex,
    this.isPreview = false,
    this.type = LessonType.video,
    this.resources = const [],
    this.metadata,
  });

  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      videoUrl: json['videoUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      duration: Duration(seconds: json['durationSeconds'] as int),
      orderIndex: json['orderIndex'] as int,
      isPreview: json['isPreview'] as bool? ?? false,
      type: LessonType.fromString(json['type'] as String? ?? 'video'),
      resources: (json['resources'] as List<dynamic>?)?.cast<String>() ?? [],
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'durationSeconds': duration.inSeconds,
      'orderIndex': orderIndex,
      'isPreview': isPreview,
      'type': type.value,
      'resources': resources,
      'metadata': metadata,
    };
  }

  Lesson copyWith({
    String? id,
    String? title,
    String? description,
    String? videoUrl,
    String? thumbnailUrl,
    Duration? duration,
    int? orderIndex,
    bool? isPreview,
    LessonType? type,
    List<String>? resources,
    Map<String, dynamic>? metadata,
  }) {
    return Lesson(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      duration: duration ?? this.duration,
      orderIndex: orderIndex ?? this.orderIndex,
      isPreview: isPreview ?? this.isPreview,
      type: type ?? this.type,
      resources: resources ?? this.resources,
      metadata: metadata ?? this.metadata,
    );
  }
}

enum CourseLevel {
  all('All Levels'),
  undergraduate('Undergraduate'),
  graduate('Graduate'),
  beginner('Beginner'),
  intermediate('Intermediate'),
  advanced('Advanced');

  const CourseLevel(this.value);
  final String value;

  static CourseLevel fromString(String value) {
    return CourseLevel.values.firstWhere(
      (level) => level.value == value,
      orElse: () => CourseLevel.all,
    );
  }
}

enum CourseCategory {
  all('All'),
  programming('Programming'),
  design('Design'),
  business('Business'),
  marketing('Marketing'),
  dataScience('Data Science'),
  engineering('Engineering'),
  mathematics('Mathematics'),
  language('Language'),
  arts('Arts'),
  health('Health'),
  music('Music');

  const CourseCategory(this.value);
  final String value;

  static CourseCategory fromString(String value) {
    return CourseCategory.values.firstWhere(
      (category) => category.value == value,
      orElse: () => CourseCategory.all,
    );
  }
}

enum PricingType {
  free('Free'),
  paid('Paid'),
  subscription('Subscription');

  const PricingType(this.value);
  final String value;

  static PricingType fromString(String value) {
    return PricingType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => PricingType.free,
    );
  }
}

class CoursePricing {
  final PricingType type;
  final double? amount;
  final String? currency;
  final double? discountedAmount;
  final DateTime? discountExpiry;

  CoursePricing({
    required this.type,
    this.amount,
    this.currency = 'USD',
    this.discountedAmount,
    this.discountExpiry,
  });

  bool get isFree => type == PricingType.free;
  bool get hasDiscount =>
      discountedAmount != null && discountedAmount! < amount!;

  String get displayPrice {
    if (isFree) return 'Free';
    if (hasDiscount) return '\$${discountedAmount!.toStringAsFixed(2)}';
    return '\$${amount!.toStringAsFixed(2)}';
  }

  factory CoursePricing.fromJson(Map<String, dynamic> json) {
    return CoursePricing(
      type: PricingType.fromString(json['type'] as String),
      amount: (json['amount'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      discountedAmount: (json['discountedAmount'] as num?)?.toDouble(),
      discountExpiry: json['discountExpiry'] != null
          ? DateTime.parse(json['discountExpiry'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.value,
      'amount': amount,
      'currency': currency,
      'discountedAmount': discountedAmount,
      'discountExpiry': discountExpiry?.toIso8601String(),
    };
  }
}

enum LessonType {
  video('video'),
  quiz('quiz'),
  reading('reading'),
  assignment('assignment'),
  discussion('discussion');

  const LessonType(this.value);
  final String value;

  static LessonType fromString(String value) {
    return LessonType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => LessonType.video,
    );
  }
}

// Additional model for user progress tracking
class CourseProgress {
  final String courseId;
  final String userId;
  final List<String> completedLessons;
  final DateTime lastAccessedAt;
  final double progressPercentage;
  final Duration totalWatchTime;

  CourseProgress({
    required this.courseId,
    required this.userId,
    required this.completedLessons,
    required this.lastAccessedAt,
    required this.progressPercentage,
    required this.totalWatchTime,
  });

  bool isLessonCompleted(String lessonId) {
    return completedLessons.contains(lessonId);
  }

  factory CourseProgress.fromJson(Map<String, dynamic> json) {
    return CourseProgress(
      courseId: json['courseId'] as String,
      userId: json['userId'] as String,
      completedLessons: (json['completedLessons'] as List<dynamic>)
          .cast<String>(),
      lastAccessedAt: DateTime.parse(json['lastAccessedAt'] as String),
      progressPercentage: (json['progressPercentage'] as num).toDouble(),
      totalWatchTime: Duration(seconds: json['totalWatchTimeSeconds'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'userId': userId,
      'completedLessons': completedLessons,
      'lastAccessedAt': lastAccessedAt.toIso8601String(),
      'progressPercentage': progressPercentage,
      'totalWatchTimeSeconds': totalWatchTime.inSeconds,
    };
  }
}

// lib/models/api_response_models.dart

/// Search response from the courses API
class SearchResponse {
  final List<Course> courses;
  final int totalCount;
  final int page;
  final int limit;
  final int totalPages;
  final Map<String, dynamic>? filters;

  SearchResponse({
    required this.courses,
    required this.totalCount,
    required this.page,
    required this.limit,
    required this.totalPages,
    this.filters,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    return SearchResponse(
      courses: (json['courses'] as List<dynamic>)
          .map(
            (courseJson) => Course.fromJson(courseJson as Map<String, dynamic>),
          )
          .toList(),
      totalCount: json['totalCount'] as int,
      page: json['page'] as int,
      limit: json['limit'] as int,
      totalPages: json['totalPages'] as int,
      filters: json['filters'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courses': courses.map((course) => course.toJson()).toList(),
      'totalCount': totalCount,
      'page': page,
      'limit': limit,
      'totalPages': totalPages,
      'filters': filters,
    };
  }
}

/// Featured course model for highlighted courses
class FeaturedCourse {
  final String id;
  final String title;
  final String description;
  final String instructor;
  final String thumbnailUrl;
  final CourseLevel level;
  final CourseCategory category;
  final double rating;
  final int enrollmentCount;
  final String? reason; // Why this course is featured
  final int? rank; // Featured ranking

  FeaturedCourse({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    required this.thumbnailUrl,
    required this.level,
    required this.category,
    required this.rating,
    required this.enrollmentCount,
    this.reason,
    this.rank,
  });

  factory FeaturedCourse.fromJson(Map<String, dynamic> json) {
    return FeaturedCourse(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      instructor: json['instructor'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      level: CourseLevel.fromString(json['level'] as String),
      category: CourseCategory.fromString(json['category'] as String),
      rating: (json['rating'] as num).toDouble(),
      enrollmentCount: json['enrollmentCount'] as int,
      reason: json['reason'] as String?,
      rank: json['rank'] as int?,
    );
  }

  factory FeaturedCourse.fromCourse(
    Course course, {
    String? reason,
    int? rank,
  }) {
    return FeaturedCourse(
      id: course.id,
      title: course.title,
      description: course.description,
      instructor: course.instructor,
      thumbnailUrl: course.thumbnailUrl,
      level: course.level,
      category: course.category,
      rating: course.rating,
      enrollmentCount: course.enrollmentCount,
      reason: reason,
      rank: rank,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'instructor': instructor,
      'thumbnailUrl': thumbnailUrl,
      'level': level.value,
      'category': category.value,
      'rating': rating,
      'enrollmentCount': enrollmentCount,
      'reason': reason,
      'rank': rank,
    };
  }
}

/// Topics and departments response
class TopicsResponse {
  final List<String> departments;
  final List<String> topics;
  final List<String> levels;
  final List<String> languages;
  final Map<String, String> departmentNames;

  TopicsResponse({
    required this.departments,
    required this.topics,
    required this.levels,
    required this.languages,
    required this.departmentNames,
  });

  factory TopicsResponse.fromJson(Map<String, dynamic> json) {
    return TopicsResponse(
      departments: (json['departments'] as List<dynamic>).cast<String>(),
      topics: (json['topics'] as List<dynamic>).cast<String>(),
      levels: (json['levels'] as List<dynamic>).cast<String>(),
      languages: (json['languages'] as List<dynamic>).cast<String>(),
      departmentNames: Map<String, String>.from(json['departmentNames'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'departments': departments,
      'topics': topics,
      'levels': levels,
      'languages': languages,
      'departmentNames': departmentNames,
    };
  }
}

/// API health check response
class HealthResponse {
  final String status;
  final String timestamp;
  final Map<String, dynamic>? info;

  HealthResponse({required this.status, required this.timestamp, this.info});

  factory HealthResponse.fromJson(Map<String, dynamic> json) {
    return HealthResponse(
      status: json['status'] as String,
      timestamp: json['timestamp'] as String,
      info: json['info'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'timestamp': timestamp, 'info': info};
  }
}
