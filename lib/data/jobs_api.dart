// 🎯 CareerJet API Service - Streamlined for SkillsBridge
// Clean version focused on core functionality used by the UI

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CareerJetApiService {
  static const String baseUrl = 'http://public.api.careerjet.net/search';
  static const String localeCode = 'en_ZA'; // 🇿🇦 South Africa focus!
  static const String affiliateId = 'dd29789628c3db4bb89dbe59675a7b1f';

  // ⏱️ Rate limiting: Keep it cool with 1000 requests per hour
  static const Duration rateLimitDelay = Duration(seconds: 4);
  static DateTime? _lastRequestTime;

  /// 🔍 Search for jobs on CareerJet South Africa
  static Future<CareerJetResponse?> searchJobs({
    String? keywords,
    String? location,
    String sort = 'relevance', // Options: 'relevance', 'date', 'salary'
    int page = 1,
    int pageSize = 20,
    String?
    contractType, // 'p'=permanent, 'c'=contract, 't'=temporary, 'i'=internship, 'v'=voluntary
    String? contractPeriod, // 'f'=full-time, 'p'=part-time
    String? userIp,
    String? userAgent,
    List<String>? filterTags, // Filter pills from UI
  }) async {
    try {
      // ⏳ Enforce rate limit to avoid getting blocked
      await _enforceRateLimit();

      // 🛡️ Generate default user agent and IP if not provided
      final defaultUserAgent = userAgent ?? _generateUserAgent();
      final defaultUserIp = userIp ?? _generateUserIp();

      // 🔨 Build query parameters
      final Map<String, String> queryParams = {
        'locale_code': localeCode,
        'affid': affiliateId,
        'sort': sort,
        'page': page.toString(),
        'pagesize': pageSize.toString(),
        'user_agent': defaultUserAgent,
        'user_ip': defaultUserIp,
      };

      // 🎨 Build keywords with filter tags
      String effectiveKeywords = keywords ?? '';

      // Add filter pills as keywords
      if (filterTags != null && filterTags.isNotEmpty) {
        for (final tag in filterTags) {
          if (tag.isNotEmpty) {
            effectiveKeywords = _addToKeywords(effectiveKeywords, tag);
          }
        }
        debugPrint('🏷️ Added filter tags: ${filterTags.join(', ')}');
      }

      // Set final keywords
      if (effectiveKeywords.isNotEmpty) {
        queryParams['keywords'] = effectiveKeywords.trim();
        debugPrint('🔍 Final keywords: ${queryParams['keywords']}');
      }

      // Handle location
      if (location != null &&
          location.isNotEmpty &&
          location != 'All Locations') {
        queryParams['location'] = _normalizeLocation(location);
        debugPrint('📍 Location: ${queryParams['location']}');
      }

      // Contract type and period
      if (contractType != null && contractType.isNotEmpty) {
        queryParams['contracttype'] = contractType;
      }
      if (contractPeriod != null && contractPeriod.isNotEmpty) {
        queryParams['contractperiod'] = contractPeriod;
      }

      // 🌐 Build the URI and make the request
      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
      debugPrint('🚀 CareerJet API Request URL: $uri');

      final httpResponse = await http
          .get(
            uri,
            headers: {
              'User-Agent': defaultUserAgent,
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                '⏰ Request timeout - CareerJet API took too long to respond',
              );
            },
          );

      debugPrint(
        '📥 CareerJet API Response Status: ${httpResponse.statusCode}',
      );

      if (httpResponse.statusCode == 200) {
        final jsonData = json.decode(httpResponse.body);

        // Check for API errors
        if (jsonData['type'] == 'ERROR') {
          String errorMessage = 'CareerJet API Error';
          if (jsonData['error'] != null) {
            errorMessage = 'CareerJet API Error: ${jsonData['error']}';
          }
          debugPrint('❌ $errorMessage');
          throw CareerJetApiException(errorMessage, jsonData);
        }

        debugPrint('✅ Successfully parsed response!');
        return CareerJetResponse.fromJson(jsonData);
      } else {
        return _handleHttpError(httpResponse);
      }
    } catch (e) {
      return _handleException(e);
    }
  }

  /// 🛠️ Helper method to add keywords intelligently
  static String _addToKeywords(String existing, String addition) {
    if (existing.isEmpty) return addition;
    return '$existing $addition';
  }

  /// 📍 Normalize location for better API compatibility
  static String _normalizeLocation(String location) {
    final locationMap = {
      'Johannesburg': 'Johannesburg, Gauteng',
      'Cape Town': 'Cape Town, Western Cape',
      'Durban': 'Durban, KwaZulu-Natal',
      'Pretoria': 'Pretoria, Gauteng',
      'Port Elizabeth': 'Port Elizabeth, Eastern Cape',
      'East London': 'East London, Eastern Cape',
      'Bloemfontein': 'Bloemfontein, Free State',
      'Pietermaritzburg': 'Pietermaritzburg, KwaZulu-Natal',
      'Nelspruit': 'Nelspruit, Mpumalanga',
      'Polokwane': 'Polokwane, Limpopo',
      'Kimberley': 'Kimberley, Northern Cape',
      'Rustenburg': 'Rustenburg, North West',
      'Sandton': 'Sandton, Gauteng',
      'Midrand': 'Midrand, Gauteng',
      'Centurion': 'Centurion, Gauteng',
      'Stellenbosch': 'Stellenbosch, Western Cape',
      'George': 'George, Western Cape',
    };

    return locationMap[location] ?? location;
  }

  /// 🚨 Handle HTTP errors
  static CareerJetResponse? _handleHttpError(http.Response response) {
    if (response.statusCode == 403) {
      debugPrint('🚫 Access denied - Check affiliate ID!');
      throw CareerJetApiException(
        'Access denied. Please verify your affiliate ID is valid.',
        {'statusCode': response.statusCode, 'body': response.body},
      );
    } else if (response.statusCode == 429) {
      debugPrint('⚠️ Rate limit hit - Slow down!');
      throw CareerJetApiException(
        'Rate limit exceeded. Please wait before making more requests.',
        {'statusCode': response.statusCode, 'body': response.body},
      );
    } else {
      debugPrint('❌ HTTP Error: ${response.statusCode}');
      throw CareerJetApiException(
        'HTTP Error ${response.statusCode}: ${response.reasonPhrase}',
        {'statusCode': response.statusCode, 'body': response.body},
      );
    }
  }

  /// 💥 Handle exceptions
  static CareerJetResponse? _handleException(dynamic e) {
    if (e is SocketException) {
      debugPrint('📵 No internet - Check your connection!');
      throw CareerJetApiException(
        'No internet connection available. Please check your network.',
        {'error': 'SocketException'},
      );
    } else if (e is HttpException) {
      debugPrint('🌐 Network hiccup!');
      throw CareerJetApiException('Network error occurred. Please try again.', {
        'error': 'HttpException',
      });
    } else if (e is FormatException) {
      debugPrint('🧩 Invalid response format!');
      throw CareerJetApiException(
        'Invalid response format from CareerJet API.',
        {'error': 'FormatException'},
      );
    } else {
      debugPrint('💥 Unexpected error: $e');
      if (e is CareerJetApiException) {
        throw e;
      }
      throw CareerJetApiException('Unexpected error: $e', {
        'error': e.toString(),
      });
    }
  }

  /// 🧪 Test API connection
  static Future<CareerJetTestResult> testConnection() async {
    debugPrint('🧪 Testing CareerJet API connection...');

    try {
      final response = await searchJobs(
        keywords: 'software developer',
        location: 'Cape Town',
        pageSize: 5,
      );

      if (response != null && response.jobs.isNotEmpty) {
        debugPrint('🎉 Connection successful with ${response.hits} jobs!');
        return CareerJetTestResult(
          success: true,
          message: 'API connection successful! Found ${response.hits} jobs.',
          totalJobs: response.hits,
          response: response,
        );
      } else if (response != null && response.hits == 0) {
        debugPrint('✅ Connected, but no jobs for test query.');
        return CareerJetTestResult(
          success: true,
          message:
              'API connection successful, but no jobs found for test query.',
          totalJobs: 0,
          response: response,
        );
      } else {
        debugPrint('⚠️ Response was null.');
        return CareerJetTestResult(
          success: false,
          message: 'API returned null response',
          totalJobs: 0,
        );
      }
    } catch (e) {
      debugPrint('❌ Test failed: $e');
      return CareerJetTestResult(
        success: false,
        message: 'Test failed: $e',
        totalJobs: 0,
      );
    }
  }

  /// ⏳ Enforce rate limiting
  static Future<void> _enforceRateLimit() async {
    if (_lastRequestTime != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!);
      if (timeSinceLastRequest < rateLimitDelay) {
        final waitTime = rateLimitDelay - timeSinceLastRequest;
        debugPrint('⏲️ Rate limiting: Waiting ${waitTime.inMilliseconds}ms...');
        await Future.delayed(waitTime);
      }
    }
    _lastRequestTime = DateTime.now();
  }

  /// 🎭 Generate realistic user agent
  static String _generateUserAgent() {
    final userAgents = [
      'Mozilla/5.0 (Linux; Android 12; SM-G991B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
      'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1',
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      'SkillsBridge-Flutter-App/1.0 (Mobile; Job Search)',
    ];

    final random = Random();
    return userAgents[random.nextInt(userAgents.length)];
  }

  /// 🌍 Generate South African IP address
  static String _generateUserIp() {
    final random = Random();
    final saIpRanges = [
      '41.0.', '41.1.', '41.2.', '41.3.', // Telkom ranges
      '196.', '197.', // Various SA ISPs
      '155.232.', '146.141.', // University networks
      '102.', '105.', // African IP ranges
    ];

    final baseIp = saIpRanges[random.nextInt(saIpRanges.length)];
    final thirdOctet = random.nextInt(255);
    final fourthOctet = random.nextInt(255);

    return '$baseIp$thirdOctet.$fourthOctet';
  }

  /// 📍 Get South African locations
  static List<String> getSouthAfricanLocations() {
    return [
      'All Locations',
      'Remote',
      'Cape Town',
      'Johannesburg',
      'Durban',
      'Pretoria',
      'Port Elizabeth',
      'Bloemfontein',
      'East London',
      'Sandton',
      'Midrand',
      'Centurion',
      'Stellenbosch',
      'George',
      'Pietermaritzburg',
      'Nelspruit',
      'Polokwane',
      'Kimberley',
      'Rustenburg',
    ];
  }

  /// 💼 Get contract type options
  static Map<String, String> getContractTypes() {
    return {
      'p': 'Permanent',
      'c': 'Contract',
      't': 'Temporary',
      'i': 'Internship',
      'v': 'Voluntary',
    };
  }

  /// ⏰ Get contract period options
  static Map<String, String> getContractPeriods() {
    return {'f': 'Full-time', 'p': 'Part-time'};
  }

  /// 🔄 Get sort options
  static List<String> getSortOptions() {
    return ['relevance', 'date', 'salary'];
  }
}

// Exception and data model classes

class CareerJetApiException implements Exception {
  final String message;
  final Map<String, dynamic> details;

  CareerJetApiException(this.message, this.details);

  @override
  String toString() => 'CareerJetApiException: $message';
}

class CareerJetTestResult {
  final bool success;
  final String message;
  final int totalJobs;
  final CareerJetResponse? response;
  final Map<String, dynamic>? error;

  CareerJetTestResult({
    required this.success,
    required this.message,
    required this.totalJobs,
    this.response,
    this.error,
  });
}

class CareerJetResponse {
  final String type;
  final int hits;
  final int pages;
  final int page;
  final List<CareerJetJob> jobs;

  CareerJetResponse({
    required this.type,
    required this.hits,
    required this.pages,
    required this.page,
    required this.jobs,
  });

  factory CareerJetResponse.fromJson(Map<String, dynamic> json) {
    try {
      debugPrint('🧩 Parsing CareerJet response JSON...');
      return CareerJetResponse(
        type: json['type']?.toString() ?? '',
        hits: int.tryParse(json['hits']?.toString() ?? '0') ?? 0,
        pages: int.tryParse(json['pages']?.toString() ?? '0') ?? 0,
        page: int.tryParse(json['page']?.toString() ?? '1') ?? 1,
        jobs:
            (json['jobs'] as List<dynamic>?)
                ?.map(
                  (job) => CareerJetJob.fromJson(job as Map<String, dynamic>),
                )
                .toList() ??
            [],
      );
    } catch (e) {
      debugPrint('❌ Failed to parse response: $e');
      throw CareerJetApiException('Failed to parse CareerJet response: $e', {
        'originalJson': json,
        'parseError': e.toString(),
      });
    }
  }
}

class CareerJetJob {
  final String title;
  final String company;
  final String locations;
  final String? salary;
  final String date;
  final String description;
  final String url;
  final String site;

  CareerJetJob({
    required this.title,
    required this.company,
    required this.locations,
    this.salary,
    required this.date,
    required this.description,
    required this.url,
    required this.site,
  });

  factory CareerJetJob.fromJson(Map<String, dynamic> json) {
    try {
      return CareerJetJob(
        title: json['title']?.toString() ?? 'Unknown Position',
        company: json['company']?.toString() ?? 'Unknown Company',
        locations: json['locations']?.toString() ?? 'Unknown Location',
        salary: json['salary']?.toString(),
        date: json['date']?.toString() ?? DateTime.now().toIso8601String(),
        description:
            json['description']?.toString() ?? 'No description available',
        url: json['url']?.toString() ?? '',
        site: json['site']?.toString() ?? 'careerjet.co.za',
      );
    } catch (e) {
      debugPrint('❌ Failed to parse job: $e');
      throw CareerJetApiException('Failed to parse job data: $e', {
        'originalJson': json,
        'parseError': e.toString(),
      });
    }
  }

  /// 🔄 Convert to app job format
  Map<String, dynamic> toAppJobFormat(int id) {
    // Parse location
    final locationParts = locations.split(',').map((e) => e.trim()).toList();
    final city = locationParts.isNotEmpty ? locationParts[0] : locations;
    final province = locationParts.length > 1 ? locationParts[1] : '';

    // Detect work type
    String workType = 'On-site';
    final contentLower =
        '${locations.toLowerCase()} ${title.toLowerCase()} ${description.toLowerCase()}';
    if (contentLower.contains('remote')) {
      workType = 'Remote';
    } else if (contentLower.contains('hybrid')) {
      workType = 'Hybrid';
    }

    // Parse salary
    String displaySalary = salary ?? 'Negotiable';

    // Extract basic skills
    final skills = _extractBasicSkills();

    // Detect employment type
    String employmentType = _detectEmploymentType();

    // Calculate basic match score
    final matchScore = _calculateBasicMatchScore();

    return {
      'id': id,
      'title': title,
      'company': company,
      'logo': _generateCompanyLogo(),
      'logoColor': _generateLogoColor(),
      'location': city,
      'province': province,
      'fullLocation': locations,
      'salary': displaySalary,
      'type': workType,
      'workType': employmentType,
      'tags': skills,
      'isNew': _isJobNew(),
      'matchScore': matchScore,
      'matchLevel': _getMatchLevel(matchScore),
      'description': description,
      'url': url,
      'site': site,
      'postedDate': date,
    };
  }

  List<String> _extractBasicSkills() {
    final skills = <String>[];
    final content = '${title.toLowerCase()} ${description.toLowerCase()}';

    final commonSkills = [
      'javascript',
      'python',
      'java',
      'react',
      'angular',
      'flutter',
      'sql',
      'aws',
      'docker',
      'git',
      'agile',
      'excel',
    ];

    for (final skill in commonSkills) {
      if (content.contains(skill) && !skills.contains(skill)) {
        skills.add(skill);
        if (skills.length >= 3) break;
      }
    }

    return skills.isEmpty ? ['General'] : skills;
  }

  String _detectEmploymentType() {
    final content = '${title.toLowerCase()} ${description.toLowerCase()}';

    if (content.contains('intern') || content.contains('trainee')) {
      return 'Internship';
    } else if (content.contains('part-time') || content.contains('part time')) {
      return 'Part-time';
    } else if (content.contains('contract') || content.contains('freelance')) {
      return 'Contract';
    } else if (content.contains('temporary')) {
      return 'Temporary';
    }
    return 'Full-time';
  }

  int _calculateBasicMatchScore() {
    int score = 50; // Base score

    // Title relevance
    if (title.toLowerCase().contains('developer') ||
        title.toLowerCase().contains('engineer')) {
      score += 20;
    }

    // Salary information
    if (salary != null && salary!.isNotEmpty) {
      score += 15;
    }

    // Work arrangement
    if (description.toLowerCase().contains('remote')) {
      score += 10;
    }

    // Recent posting
    if (_isJobNew()) {
      score += 10;
    }

    return score.clamp(0, 100);
  }

  String _getMatchLevel(int score) {
    if (score >= 75) return 'high';
    if (score >= 50) return 'medium';
    return 'low';
  }

  bool _isJobNew() {
    try {
      final postedDate = DateTime.parse(date);
      final daysDifference = DateTime.now().difference(postedDate).inDays;
      return daysDifference <= 7;
    } catch (e) {
      return false;
    }
  }

  String _generateCompanyLogo() {
    final companyLower = company.toLowerCase();

    if (companyLower.contains('tech') || companyLower.contains('software')) {
      return '💻';
    } else if (companyLower.contains('bank') ||
        companyLower.contains('financial')) {
      return '🏦';
    } else if (companyLower.contains('health') ||
        companyLower.contains('medical')) {
      return '🏥';
    } else if (companyLower.contains('education') ||
        companyLower.contains('school')) {
      return '🎓';
    }

    return '🏢'; // Default
  }

  Color _generateLogoColor() {
    final hash = company.hashCode;
    final colors = [
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF10B981), // Green
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFFF59E0B), // Orange
      const Color(0xFFEF4444), // Red
      const Color(0xFF06B6D4), // Cyan
    ];

    return colors[hash.abs() % colors.length];
  }
}
