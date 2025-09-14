// import 'dart:async';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:http/http.dart' as http;
// import 'package:skillsbridge/config/scrapper_config.dart';

// class NetworkUtils {
//   static final NetworkUtils _instance = NetworkUtils._internal();
//   factory NetworkUtils() => _instance;
//   NetworkUtils._internal();

//   final Connectivity _connectivity = Connectivity();

//   // ✅ Updated subscription type for new API
//   StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

//   // Rate limiting
//   final List<DateTime> _requestTimes = [];
//   Timer? _cleanupTimer;

//   // Connection status
//   bool _isConnected = true;
//   bool get isConnected => _isConnected;

//   // Initialize network monitoring
//   void initialize() {
//     _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
//       results,
//     ) {
//       // ✅ results is now a List<ConnectivityResult>
//       _isConnected =
//           results.isNotEmpty &&
//           results.any((result) => result != ConnectivityResult.none);
//     });

//     // Start cleanup timer for rate limiting
//     _cleanupTimer = Timer.periodic(
//       const Duration(minutes: 1),
//       (_) => _cleanupOldRequests(),
//     );
//   }

//   // Check current connectivity (single result check)
//   Future<bool> checkConnectivity() async {
//     try {
//       final result = await _connectivity.checkConnectivity();
//       _isConnected = result != ConnectivityResult.none;
//       return _isConnected;
//     } catch (e) {
//       print('Error checking connectivity: $e');
//       return false;
//     }
//   }

//   // Make rate-limited HTTP request
//   Future<http.Response?> makeRateLimitedRequest(
//     String url, {
//     Map<String, String>? headers,
//     int maxRetries = 3,
//   }) async {
//     // Check rate limit
//     await _enforceRateLimit();

//     // Record request time
//     _requestTimes.add(DateTime.now());

//     // Attempt request with retries
//     for (int attempt = 0; attempt < maxRetries; attempt++) {
//       try {
//         final response = await http
//             .get(
//               Uri.parse(url),
//               headers: headers ?? ScrapingConfig.getHeaders(),
//             )
//             .timeout(ScrapingConfig.networkTimeout);

//         if (response.statusCode == 200) {
//           return response;
//         } else if (response.statusCode == 429) {
//           // Rate limited by server, wait longer
//           await Future.delayed(Duration(seconds: 30 * (attempt + 1)));
//         } else if (response.statusCode >= 500) {
//           // Server error, retry with exponential backoff
//           await Future.delayed(Duration(seconds: 2 * (attempt + 1)));
//         } else {
//           // Client error, don't retry
//           print('Request failed with status: ${response.statusCode}');
//           return null;
//         }
//       } catch (e) {
//         print('Request attempt ${attempt + 1} failed: $e');

//         if (attempt < maxRetries - 1) {
//           // Wait before retrying
//           await Future.delayed(Duration(seconds: 2 * (attempt + 1)));
//         }
//       }
//     }

//     return null;
//   }

//   // Enforce rate limiting
//   Future<void> _enforceRateLimit() async {
//     final now = DateTime.now();
//     final oneMinuteAgo = now.subtract(const Duration(minutes: 1));

//     // Remove old requests
//     _requestTimes.removeWhere((time) => time.isBefore(oneMinuteAgo));

//     // Check if we've hit the rate limit
//     if (_requestTimes.length >= ScrapingConfig.maxRequestsPerMinute) {
//       // Calculate how long to wait
//       final oldestRequest = _requestTimes.first;
//       final waitTime = oneMinuteAgo.difference(oldestRequest);

//       if (waitTime.isNegative) {
//         print(
//           'Rate limit reached, waiting ${waitTime.inSeconds.abs()} seconds',
//         );
//         await Future.delayed(Duration(seconds: waitTime.inSeconds.abs() + 1));
//       }
//     }
//   }

//   // Clean up old request times
//   void _cleanupOldRequests() {
//     final oneMinuteAgo = DateTime.now().subtract(const Duration(minutes: 1));
//     _requestTimes.removeWhere((time) => time.isBefore(oneMinuteAgo));
//   }

//   // Test connectivity to ZABursaries
//   Future<bool> testZABursariesConnection() async {
//     try {
//       final response = await http
//           .head(
//             Uri.parse(ScrapingConfig.zabursariesBaseUrl),
//             headers: ScrapingConfig.getHeaders(),
//           )
//           .timeout(const Duration(seconds: 10));

//       return response.statusCode == 200;
//     } catch (e) {
//       print('ZABursaries connection test failed: $e');
//       return false;
//     }
//   }

//   // Dispose resources
//   void dispose() {
//     _connectivitySubscription?.cancel();
//     _cleanupTimer?.cancel();
//   }
// }

// // Extension for parsing HTML content safely
// extension SafeHtmlParsing on String {
//   String cleanHtml() {
//     return replaceAll(
//       RegExp(r'<[^>]*>'),
//       '',
//     ).replaceAll(RegExp(r'\s+'), ' ').trim();
//   }

//   String? extractFirstMatch(String pattern) {
//     try {
//       final regex = RegExp(pattern, caseSensitive: false);
//       final match = regex.firstMatch(this);
//       return match?.group(0);
//     } catch (e) {
//       return null;
//     }
//   }

//   List<String> extractAllMatches(String pattern) {
//     try {
//       final regex = RegExp(pattern, caseSensitive: false);
//       final matches = regex.allMatches(this);
//       return matches
//           .map((m) => m.group(0) ?? '')
//           .where((s) => s.isNotEmpty)
//           .toList();
//     } catch (e) {
//       return [];
//     }
//   }
// }

// // Cache manager for scraped data
// class CacheManager {
//   static final CacheManager _instance = CacheManager._internal();
//   factory CacheManager() => _instance;
//   CacheManager._internal();

//   final Map<String, CachedData> _cache = {};

//   // Add data to cache
//   void addToCache(String key, dynamic data, {Duration? maxAge}) {
//     _cache[key] = CachedData(
//       data: data,
//       timestamp: DateTime.now(),
//       maxAge: maxAge ?? ScrapingConfig.cacheValidityDuration,
//     );
//   }

//   // Get data from cache
//   T? getFromCache<T>(String key) {
//     final cached = _cache[key];

//     if (cached == null) {
//       return null;
//     }

//     // Check if cache is still valid
//     if (DateTime.now().difference(cached.timestamp) > cached.maxAge) {
//       _cache.remove(key);
//       return null;
//     }

//     return cached.data as T?;
//   }

//   // Clear cache
//   void clearCache() {
//     _cache.clear();
//   }

//   // Remove expired entries
//   void cleanupCache() {
//     final now = DateTime.now();
//     _cache.removeWhere((key, value) {
//       return now.difference(value.timestamp) > value.maxAge;
//     });
//   }
// }

// class CachedData {
//   final dynamic data;
//   final DateTime timestamp;
//   final Duration maxAge;

//   CachedData({
//     required this.data,
//     required this.timestamp,
//     required this.maxAge,
//   });
// }
