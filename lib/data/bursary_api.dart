// 🎓 Bursary API Service - Your gateway to educational funding opportunities!
// This service connects to the ZA Bursaries scraping API and handles all the heavy lifting
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

// // 🚀 Main API Service Class
// class BursaryApiService {
//   // 🌍 API Configuration
//   static const String _baseUrl = 'https://bursary-api.onrender.com';
//   static const Duration _timeout = Duration(seconds: 60);

//   // 🔧 Dio instance for making HTTP requests
//   late final Dio _dio;

//   // 🎯 Singleton pattern - only one instance of this service exists
//   static final BursaryApiService _instance = BursaryApiService._internal();
//   factory BursaryApiService() => _instance;

//   // 🏗️ Private constructor for singleton
//   BursaryApiService._internal() {
//     _dio = Dio(
//       BaseOptions(
//         baseUrl: _baseUrl,
//         connectTimeout: _timeout,
//         receiveTimeout: _timeout,
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       ),
//     );

//     // 🔍 Add logging interceptor in debug mode for easier debugging
//     if (kDebugMode) {
//       _dio.interceptors.add(
//         LogInterceptor(
//           requestBody: true,
//           responseBody: true,
//           requestHeader: true,
//           responseHeader: false,
//           error: true,
//           logPrint: (log) => debugPrint('🌐 API: $log'),
//         ),
//       );
//     }
//   }

//   // 🎯 Get filtered and paginated bursaries
//   // This is the main method you'll use to fetch bursaries!
//   Future<BursariesResponse> getBursaries({
//     String? search,
//     String? field,
//     String? province,
//     String? closingMonth,
//     String? studyLevel,
//     String? workBack,
//     String? coverageType,
//     int page = 1,
//     int limit = 10,
//     String? sort,
//   }) async {
//     try {
//       // 🎨 Building query parameters dynamically
//       final queryParams = <String, dynamic>{'page': page, 'limit': limit};

//       // 🔍 Only add parameters if they have values
//       if (search != null && search.isNotEmpty) queryParams['search'] = search;
//       if (field != null && field.isNotEmpty) queryParams['field'] = field;
//       if (province != null && province.isNotEmpty)
//         queryParams['province'] = province;
//       if (closingMonth != null && closingMonth.isNotEmpty)
//         queryParams['closing_month'] = closingMonth;
//       if (studyLevel != null && studyLevel.isNotEmpty)
//         queryParams['study_level'] = studyLevel;
//       if (workBack != null && workBack.isNotEmpty)
//         queryParams['work_back'] = workBack;
//       if (coverageType != null && coverageType.isNotEmpty)
//         queryParams['coverage_type'] = coverageType;
//       if (sort != null && sort.isNotEmpty) queryParams['sort'] = sort;

//       debugPrint('🔍 Fetching bursaries with params: $queryParams');

//       // 🚀 Make the API call
//       final response = await _dio.get(
//         '/bursaries',
//         queryParameters: queryParams,
//       );

//       // ✅ Parse and return the response
//       return BursariesResponse.fromJson(response.data);
//     } on DioException catch (e) {
//       // 🚨 Handle Dio-specific errors
//       throw _handleDioError(e);
//     } catch (e) {
//       // 🔥 Handle any other errors
//       throw BursaryApiException(
//         message: 'Unexpected error occurred: $e',
//         statusCode: 500,
//       );
//     }
//   }

//   // 📚 Get all field categories and subcategories
//   // Perfect for populating dropdown menus!
//   Future<FieldsResponse> getFieldCategories() async {
//     try {
//       debugPrint('📚 Fetching field categories...');

//       final response = await _dio.get('/bursaries/fields');

//       // ✅ Parse and return the fields
//       return FieldsResponse.fromJson(response.data);
//     } on DioException catch (e) {
//       throw _handleDioError(e);
//     } catch (e) {
//       throw BursaryApiException(
//         message: 'Failed to fetch field categories: $e',
//         statusCode: 500,
//       );
//     }
//   }

//   // ⏰ Get bursaries that are closing soon
//   // Critical for urgent notifications!
//   Future<ClosingSoonResponse> getClosingSoonBursaries({
//     String? month,
//     int days = 30,
//   }) async {
//     try {
//       // 🏃‍♂️ Building query parameters
//       final queryParams = <String, dynamic>{'days': days};

//       if (month != null && month.isNotEmpty) queryParams['month'] = month;

//       debugPrint('⏰ Fetching bursaries closing within $days days...');

//       final response = await _dio.get(
//         '/bursaries/closing-soon',
//         queryParameters: queryParams,
//       );

//       // ✅ Parse and return urgent bursaries
//       return ClosingSoonResponse.fromJson(response.data);
//     } on DioException catch (e) {
//       throw _handleDioError(e);
//     } catch (e) {
//       throw BursaryApiException(
//         message: 'Failed to fetch closing soon bursaries: $e',
//         statusCode: 500,
//       );
//     }
//   }

//   // 🏥 Check API health status
//   // Use this to verify the API is up and running!
//   Future<HealthResponse> checkHealth() async {
//     try {
//       debugPrint('🏥 Checking API health...');

//       final response = await _dio.get('/health');

//       final health = HealthResponse.fromJson(response.data);

//       // 🎉 Log the health status
//       if (health.isHealthy) {
//         debugPrint('✅ API is healthy! Service: ${health.service}');
//       } else {
//         debugPrint('⚠️ API health check returned: ${health.status}');
//       }

//       return health;
//     } on DioException catch (e) {
//       throw _handleDioError(e);
//     } catch (e) {
//       throw BursaryApiException(
//         message: 'Health check failed: $e',
//         statusCode: 500,
//       );
//     }
//   }

//   // 🔍 Search bursaries with smart filtering
//   // Convenience method that combines search and filters
//   Future<BursariesResponse> searchBursaries({
//     required String query,
//     Map<String, String>? filters,
//     int page = 1,
//     int limit = 10,
//   }) async {
//     return getBursaries(
//       search: query,
//       field: filters?['field'],
//       province: filters?['province'],
//       studyLevel: filters?['studyLevel'],
//       workBack: filters?['workBack'],
//       coverageType: filters?['coverageType'],
//       sort: filters?['sort'],
//       page: page,
//       limit: limit,
//     );
//   }

//   // 🎯 Get bursaries for a specific field of study
//   Future<BursariesResponse> getBursariesByField({
//     required String field,
//     int page = 1,
//     int limit = 10,
//   }) async {
//     debugPrint('🎯 Fetching bursaries for field: $field');
//     return getBursaries(field: field, page: page, limit: limit);
//   }

//   // 🆘 Get urgent bursaries (closing in 7 days or less)
//   Future<ClosingSoonResponse> getUrgentBursaries() async {
//     debugPrint('🆘 Fetching URGENT bursaries (closing in 7 days)');
//     return getClosingSoonBursaries(days: 7);
//   }

//   // 📍 Get bursaries for a specific province
//   Future<BursariesResponse> getBursariesByProvince({
//     required String province,
//     int page = 1,
//     int limit = 10,
//   }) async {
//     debugPrint('📍 Fetching bursaries for province: $province');
//     return getBursaries(province: province, page: page, limit: limit);
//   }

//   // 🔥 Private method to handle Dio errors gracefully
//   BursaryApiException _handleDioError(DioException error) {
//     debugPrint('❌ API Error: ${error.type} - ${error.message}');

//     switch (error.type) {
//       case DioExceptionType.connectionTimeout:
//       case DioExceptionType.sendTimeout:
//       case DioExceptionType.receiveTimeout:
//         return BursaryApiException(
//           message:
//               '⏱️ Request timed out. Please check your internet connection.',
//           statusCode: 408,
//         );

//       case DioExceptionType.badResponse:
//         final statusCode = error.response?.statusCode ?? 500;
//         final message =
//             error.response?.data?['detail'] ??
//             error.response?.data?['message'] ??
//             'Server error occurred';
//         return BursaryApiException(
//           message: '🚨 Server error ($statusCode): $message',
//           statusCode: statusCode,
//         );

//       case DioExceptionType.cancel:
//         return BursaryApiException(
//           message: '🛑 Request was cancelled',
//           statusCode: 499,
//         );

//       case DioExceptionType.unknown:
//         if (error.error is SocketException) {
//           return BursaryApiException(
//             message: '📵 No internet connection. Please check your network.',
//             statusCode: 503,
//           );
//         }
//         return BursaryApiException(
//           message: '❓ Unknown error occurred: ${error.message}',
//           statusCode: 500,
//         );

//       default:
//         return BursaryApiException(
//           message: '⚠️ Unexpected error: ${error.message}',
//           statusCode: 500,
//         );
//     }
//   }

//   // 🧹 Clean up resources (call this when disposing)
//   void dispose() {
//     _dio.close();
//   }
// }

// // 🚨 Custom Exception class for API errors
// class BursaryApiException implements Exception {
//   final String message;
//   final int statusCode;
//   final dynamic data;

//   BursaryApiException({
//     required this.message,
//     required this.statusCode,
//     this.data,
//   });

//   @override
//   String toString() => 'BursaryApiException: [$statusCode] $message';

//   // 🎯 Helper to check if this is a network error
//   bool get isNetworkError => statusCode == 503 || statusCode == 408;

//   // 🎯 Helper to check if this is a server error
//   bool get isServerError => statusCode >= 500 && statusCode < 600;

//   // 🎯 Helper to check if this is a client error
//   bool get isClientError => statusCode >= 400 && statusCode < 500;
// }

// 🎓 Bursary API Service - Your gateway to educational funding opportunities!
// This service connects to the ZA Bursaries scraping API and handles all the heavy lifting
// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
import 'package:skillsbridge/models/bursary_models.dart';
import 'package:skillsbridge/data/offline/bursary_data.dart';

// 🚀 Main API Service Class
class BursaryApiService {
  // 🌍 API Configuration
  static const String _baseUrl = 'https://bursary-api.onrender.com';
  static const Duration _timeout = Duration(seconds: 60);

  // 🔧 Dio instance for making HTTP requests
  late final Dio _dio;

  // 🎯 Singleton pattern - only one instance of this service exists
  static final BursaryApiService _instance = BursaryApiService._internal();
  factory BursaryApiService() => _instance;

  // 🏗️ Private constructor for singleton
  BursaryApiService._internal() {
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
          logPrint: (log) => debugPrint('🌐 API: $log'),
        ),
      );
    }
  }

  // 🔄 Flag to enable mock data
  bool useMock = true; // Set to true to always use mock data

  // 🎯 Get filtered and paginated bursaries
  // This is the main method you'll use to fetch bursaries!
  Future<BursariesResponse> getBursaries({
    String? search,
    String? field,
    String? province,
    String? closingMonth,
    String? studyLevel,
    String? workBack,
    String? coverageType,
    int page = 1,
    int limit = 10,
    String? sort,
  }) async {
    if (useMock) {
      return _mockGetBursaries(
        search: search,
        field: field,
        province: province,
        closingMonth: closingMonth,
        studyLevel: studyLevel,
        workBack: workBack,
        coverageType: coverageType,
        page: page,
        limit: limit,
        sort: sort,
      );
    }
    try {
      // 🎨 Building query parameters dynamically
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      // 🔍 Only add parameters if they have values
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (field != null && field.isNotEmpty) queryParams['field'] = field;
      if (province != null && province.isNotEmpty) {
        queryParams['province'] = province;
      }
      if (closingMonth != null && closingMonth.isNotEmpty) {
        queryParams['closing_month'] = closingMonth;
      }
      if (studyLevel != null && studyLevel.isNotEmpty) {
        queryParams['study_level'] = studyLevel;
      }
      if (workBack != null && workBack.isNotEmpty) {
        queryParams['work_back'] = workBack;
      }
      if (coverageType != null && coverageType.isNotEmpty) {
        queryParams['coverage_type'] = coverageType;
      }
      if (sort != null && sort.isNotEmpty) queryParams['sort'] = sort;

      debugPrint('🔍 Fetching bursaries with params: $queryParams');

      // 🚀 Make the API call
      final response = await _dio.get(
        '/bursaries',
        queryParameters: queryParams,
      );

      // ✅ Parse and return the response
      return BursariesResponse.fromJson(response.data);
    } on DioException catch (e) {
      final exception = _handleDioError(e);
      if (exception.isNetworkError) {
        debugPrint('📵 Offline detected - falling back to local sample data!');
        return _mockGetBursaries(
          search: search,
          field: field,
          province: province,
          closingMonth: closingMonth,
          studyLevel: studyLevel,
          workBack: workBack,
          coverageType: coverageType,
          page: page,
          limit: limit,
          sort: sort,
        );
      }
      throw exception;
    } catch (e) {
      // 🔥 Handle any other errors
      throw BursaryApiException(
        message: 'Unexpected error occurred: $e',
        statusCode: 500,
      );
    }
  }

  // 📚 Get all field categories and subcategories
  // Perfect for populating dropdown menus!
  Future<FieldsResponse> getFieldCategories() async {
    if (useMock) {
      return _mockGetFieldCategories();
    }
    try {
      debugPrint('📚 Fetching field categories...');

      final response = await _dio.get('/bursaries/fields');

      // ✅ Parse and return the fields
      return FieldsResponse.fromJson(response.data);
    } on DioException catch (e) {
      final exception = _handleDioError(e);
      if (exception.isNetworkError) {
        debugPrint('📵 Offline detected - falling back to local sample data!');
        return _mockGetFieldCategories();
      }
      throw exception;
    } catch (e) {
      throw BursaryApiException(
        message: 'Failed to fetch field categories: $e',
        statusCode: 500,
      );
    }
  }

  // ⏰ Get bursaries that are closing soon
  // Critical for urgent notifications!
  Future<ClosingSoonResponse> getClosingSoonBursaries({
    String? month,
    int days = 30,
  }) async {
    if (useMock) {
      return _mockGetClosingSoonBursaries(month: month, days: days);
    }
    try {
      // 🏃‍♂️ Building query parameters
      final queryParams = <String, dynamic>{'days': days};

      if (month != null && month.isNotEmpty) queryParams['month'] = month;

      debugPrint('⏰ Fetching bursaries closing within $days days...');

      final response = await _dio.get(
        '/bursaries/closing-soon',
        queryParameters: queryParams,
      );

      // ✅ Parse and return urgent bursaries
      return ClosingSoonResponse.fromJson(response.data);
    } on DioException catch (e) {
      final exception = _handleDioError(e);
      if (exception.isNetworkError) {
        debugPrint('📵 Offline detected - falling back to local sample data!');
        return _mockGetClosingSoonBursaries(month: month, days: days);
      }
      throw exception;
    } catch (e) {
      throw BursaryApiException(
        message: 'Failed to fetch closing soon bursaries: $e',
        statusCode: 500,
      );
    }
  }

  // 🏥 Check API health status
  // Use this to verify the API is up and running!
  Future<HealthResponse> checkHealth() async {
    if (useMock) {
      return _mockCheckHealth();
    }
    try {
      debugPrint('🏥 Checking API health...');

      final response = await _dio.get('/health');

      final health = HealthResponse.fromJson(response.data);

      // 🎉 Log the health status
      if (health.isHealthy) {
        debugPrint('✅ API is healthy! Service: ${health.service}');
      } else {
        debugPrint('⚠️ API health check returned: ${health.status}');
      }

      return health;
    } on DioException catch (e) {
      final exception = _handleDioError(e);
      if (exception.isNetworkError) {
        debugPrint('📵 Offline detected - falling back to local sample data!');
        return _mockCheckHealth();
      }
      throw exception;
    } catch (e) {
      throw BursaryApiException(
        message: 'Health check failed: $e',
        statusCode: 500,
      );
    }
  }

  // 🔍 Search bursaries with smart filtering
  // Convenience method that combines search and filters
  Future<BursariesResponse> searchBursaries({
    required String query,
    Map<String, String>? filters,
    int page = 1,
    int limit = 10,
  }) async {
    return getBursaries(
      search: query,
      field: filters?['field'],
      province: filters?['province'],
      studyLevel: filters?['studyLevel'],
      workBack: filters?['workBack'],
      coverageType: filters?['coverageType'],
      sort: filters?['sort'],
      page: page,
      limit: limit,
    );
  }

  // 🎯 Get bursaries for a specific field of study
  Future<BursariesResponse> getBursariesByField({
    required String field,
    int page = 1,
    int limit = 10,
  }) async {
    debugPrint('🎯 Fetching bursaries for field: $field');
    return getBursaries(field: field, page: page, limit: limit);
  }

  // 🆘 Get urgent bursaries (closing in 7 days or less)
  Future<ClosingSoonResponse> getUrgentBursaries() async {
    debugPrint('🆘 Fetching URGENT bursaries (closing in 7 days)');
    return getClosingSoonBursaries(days: 7);
  }

  // 📍 Get bursaries for a specific province
  Future<BursariesResponse> getBursariesByProvince({
    required String province,
    int page = 1,
    int limit = 10,
  }) async {
    debugPrint('📍 Fetching bursaries for province: $province');
    return getBursaries(province: province, page: page, limit: limit);
  }

  // 🔥 Private method to handle Dio errors gracefully
  BursaryApiException _handleDioError(DioException error) {
    debugPrint('❌ API Error: ${error.type} - ${error.message}');

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return BursaryApiException(
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
        return BursaryApiException(
          message: '🚨 Server error ($statusCode): $message',
          statusCode: statusCode,
        );

      case DioExceptionType.cancel:
        return BursaryApiException(
          message: '🛑 Request was cancelled',
          statusCode: 499,
        );

      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return BursaryApiException(
            message: '📵 No internet connection. Please check your network.',
            statusCode: 503,
          );
        }
        return BursaryApiException(
          message: '❓ Unknown error occurred: ${error.message}',
          statusCode: 500,
        );

      default:
        return BursaryApiException(
          message: '⚠️ Unexpected error: ${error.message}',
          statusCode: 500,
        );
    }
  }

  // 🧹 Clean up resources (call this when disposing)
  void dispose() {
    _dio.close();
  }

  // 🧪 Mock methods for local sample data

  Future<BursariesResponse> _mockGetBursaries({
    String? search,
    String? field,
    String? province,
    String? closingMonth,
    String? studyLevel,
    String? workBack,
    String? coverageType,
    int page = 1,
    int limit = 10,
    String? sort,
  }) async {
    var bursaries = sampleBursaries;

    // Basic filtering (extend as needed)
    if (search != null && search.isNotEmpty) {
      bursaries = bursaries
          .where((b) => b.title.toLowerCase().contains(search.toLowerCase()))
          .toList();
    }
    if (field != null && field.isNotEmpty) {
      bursaries = bursaries.where((b) => b.fields.contains(field)).toList();
    }
    // Province, workBack, coverageType: add if model supports
    if (studyLevel != null && studyLevel.isNotEmpty) {
      bursaries = bursaries
          .where(
            (b) =>
                b.studyLevel.toLowerCase().contains(studyLevel.toLowerCase()),
          )
          .toList();
    }
    if (closingMonth != null && closingMonth.isNotEmpty) {
      bursaries = bursaries.where((b) {
        final date = DateTime.tryParse(b.deadline.closingDate);
        return date != null && date.month.toString() == closingMonth;
      }).toList();
    }

    // Basic sorting (extend as needed)
    if (sort != null) {
      if (sort.contains('title')) {
        bursaries.sort((a, b) => a.title.compareTo(b.title));
      }
      // Add more sort options
    }

    final total = bursaries.length;
    final sliced = bursaries.skip((page - 1) * limit).take(limit).toList();

    // Simple filter info
    final urgentCount = 0; // Calculate if needed
    final closingSoon = 0; // Calculate if needed

    return BursariesResponse(
      bursaries: sliced,
      pagination: PaginationInfo(
        total: total,
        page: page,
        limit: limit,
        totalPages: (total / limit).ceil(),
      ),
      filters: FilterInfo(
        urgentCount: urgentCount,
        closingSoon: closingSoon,
        totalResults: total,
      ),
    );
  }

  Future<FieldsResponse> _mockGetFieldCategories() async {
    // Extract unique fields from sample
    final uniqueFields = sampleBursaries.expand((b) => b.fields).toSet();
    final categories = uniqueFields
        .map(
          (f) =>
              FieldCategory(slug: f.toLowerCase(), name: f, subcategories: []),
        )
        .toList();
    return FieldsResponse(categories: categories);
  }

  Future<ClosingSoonResponse> _mockGetClosingSoonBursaries({
    String? month,
    int days = 30,
  }) async {
    final now = DateTime.now();
    final closing = sampleBursaries.where((b) {
      final date = DateTime.tryParse(b.deadline.closingDate);
      if (date == null) return false;
      final diff = date.difference(now).inDays;
      if (month != null && date.month.toString() != month) return false;
      return diff <= days && diff > 0;
    }).toList();

    final items = closing.map((b) {
      final date = DateTime.parse(b.deadline.closingDate);
      final daysLeft = date.difference(now).inDays;
      return ClosingSoonItem(
        id: b.id,
        provider: b.provider.name,
        title: b.title,
        closingDate: b.deadline.closingDate,
        displayText: b.deadline.displayText,
        daysLeft: daysLeft,
        isUrgent: daysLeft <= 7,
        field: b.fields.isNotEmpty ? b.fields.first : '',
        amount: b.coverage.amount ?? '',
      );
    }).toList();

    final urgentCount = items.where((i) => i.isUrgent).length;
    final thisMonth = items
        .where((i) => DateTime.parse(i.closingDate ?? '').month == now.month)
        .length;
    final nextMonth = items
        .where(
          (i) =>
              DateTime.parse(i.closingDate ?? '').month == (now.month % 12) + 1,
        )
        .length;

    return ClosingSoonResponse(
      closingSoon: items,
      summary: ClosingSoonSummary(
        urgentCount: urgentCount,
        thisMonth: thisMonth,
        nextMonth: nextMonth,
      ),
    );
  }

  HealthResponse _mockCheckHealth() {
    return HealthResponse(
      status: 'healthy',
      timestamp: DateTime.now().toIso8601String(),
      service: 'Mock Service',
      targetSite: 'Local Sample Data',
    );
  }
}

// 🚨 Custom Exception class for API errors
class BursaryApiException implements Exception {
  final String message;
  final int statusCode;
  final dynamic data;

  BursaryApiException({
    required this.message,
    required this.statusCode,
    this.data,
  });

  @override
  String toString() => 'BursaryApiException: [$statusCode] $message';

  // 🎯 Helper to check if this is a network error
  bool get isNetworkError => statusCode == 503 || statusCode == 408;

  // 🎯 Helper to check if this is a server error
  bool get isServerError => statusCode >= 500 && statusCode < 600;

  // 🎯 Helper to check if this is a client error
  bool get isClientError => statusCode >= 400 && statusCode < 500;
}
