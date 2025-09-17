import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillsbridge/data/jobs_api.dart';

// Provider for the API service
final jobsApiServiceProvider = Provider<CareerJetApiService>((ref) {
  return CareerJetApiService();
});

// Main ViewModel Provider
final jobsScreenViewModelProvider =
    ChangeNotifierProvider.autoDispose<JobsScreenViewModel>((ref) {
      return JobsScreenViewModel();
    });

class JobsScreenViewModel extends ChangeNotifier {
  // 🎯 CORE STATE MANAGEMENT
  // These variables control the main functionality of our job portal
  int _savedJobsCount = 0;
  String _searchQuery = '';
  String _locationQuery = 'All Locations'; // Default to all of South Africa
  String _sortOption = 'Relevance';
  int _jobsCount = 0; // Will be updated from API response
  int _currentPage = 1; // For pagination support
  int _totalPages = 1; // Total pages from API response

  // 🔍 FILTER & SELECTION STATE
  // Managing user interactions and selections
  final Set<String> _activeFilters = {}; // Start with no filters
  final Set<int> _savedJobs = {}; // Saved job IDs

  // 📡 API & LOADING STATE
  // Critical for managing API calls and user experience
  bool _isLoading = false; // Shows loading spinner
  bool _isLoadingMore = false; // Shows loading for pagination
  String? _errorMessage; // Displays API errors to user
  List<Map<String, dynamic>> _jobs = []; // Real job data from API

  // 🎛️ GETTERS - Public API for UI Components
  // These provide access to our private state for the UI
  int get savedJobsCount => _savedJobsCount;
  String get searchQuery => _searchQuery;
  String get locationQuery => _locationQuery;
  String get sortOption => _sortOption;
  int get jobsCount => _jobsCount;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  Set<String> get activeFilters => _activeFilters;
  Set<int> get savedJobs => _savedJobs;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  List<Map<String, dynamic>> get jobs => _jobs;
  bool get hasError => _errorMessage != null;
  bool get hasJobs => _jobs.isNotEmpty;
  bool get hasMorePages => _currentPage < _totalPages;

  // 🌍 LOCATION OPTIONS
  // Using CareerJet's South African location options
  List<String> get availableLocations =>
      CareerJetApiService.getSouthAfricanLocations();

  // 🏷️ FILTER OPTIONS
  // Smart filtering options that work with our API
  final List<String> filterOptions = [
    'All Jobs', // Default - no filter
    'Remote', // Work from home opportunities
    'Hybrid', // Hybrid work arrangements
    'On-site', // Office-based work
    'Entry Level', // Perfect for new graduates
    'Mid Level', // Experienced professionals
    'Senior Level', // Leadership roles
    'Full-time', // Permanent positions
    'Part-time', // Flexible working
    'Internship', // Learning opportunities
    'Contract', // Short-term positions
    'This Week', // Recently posted
  ];

  // 📊 SORT OPTIONS
  // Different ways to organize job results
  final List<String> sortOptions = [
    'Relevance', // Best matches first (default)
    'Date Posted', // Newest jobs first
    'Salary', // Highest salary first
    'Match Score', // Our custom matching algorithm
  ];

  // 🚀 INITIALIZATION
  // Sets up the view model and loads initial data
  JobsScreenViewModel() {
    debugPrint('🎯 JobsScreenViewModel: Initializing...');
    _initializeWithWelcomeSearch();
  }

  /// 🌟 Initial Welcome Search
  /// Loads some default jobs when the user first opens the app
  Future<void> _initializeWithWelcomeSearch() async {
    debugPrint(
      '👋 Welcome! Loading job opportunities from all of South Africa...',
    );

    try {
      // Start with a broad search to show users what's available across SA
      await searchJobs(
        keywords: null, // No keyword filter to show all jobs
        forceRefresh: true,
      );
      debugPrint('✅ Welcome search completed! Found $_jobsCount opportunities');
    } catch (e) {
      debugPrint('⚠️ Welcome search failed, but that\'s okay: $e');
      // Don't show error on initial load - just log it
      _errorMessage = null;
    }
  }

  // 🔍 SEARCH FUNCTIONALITY

  /// 📝 Updates the search query and triggers new search
  void updateSearchQuery(String query) {
    debugPrint('🔍 User searching for: "$query"');
    _searchQuery = query;

    // 🎯 Smart Search Strategy:
    // If user typed something meaningful, search immediately
    // If they cleared it, show all jobs
    if (query.trim().length >= 2) {
      debugPrint('💡 Query is substantial - starting search...');
      searchJobs(keywords: query, forceRefresh: true);
    } else if (query.trim().isEmpty) {
      debugPrint('🔄 Query cleared - loading all jobs...');
      searchJobs(keywords: null, forceRefresh: true); // Show all jobs
    }

    notifyListeners();
  }

  /// 📍 Updates location filter
  void updateLocationQuery(String location) {
    debugPrint('📍 User changed location to: $location');
    _locationQuery = location;

    // Immediately search with new location
    searchJobs(
      keywords: _searchQuery.isNotEmpty ? _searchQuery : null,
      location: location,
      forceRefresh: true,
    );

    notifyListeners();
  }

  /// 📊 Updates sort option and re-sorts results
  void updateSortOption(String option) {
    debugPrint('📊 User changed sort to: $option');
    _sortOption = option;

    // Convert our UI sort option to CareerJet API format
    String apiSort = _convertSortOption(option);

    searchJobs(
      keywords: _searchQuery.isNotEmpty ? _searchQuery : null,
      location: _locationQuery,
      sort: apiSort,
      forceRefresh: true,
    );

    notifyListeners();
  }

  /// 🎛️ Converts UI sort options to CareerJet API format
  String _convertSortOption(String uiSort) {
    switch (uiSort) {
      case 'Date Posted':
        return 'date'; // Newest first
      case 'Salary':
        return 'salary'; // Highest salary first
      case 'Relevance':
      case 'Match Score':
      default:
        return 'relevance'; // Most relevant first
    }
  }

  // 🏷️ FILTER MANAGEMENT

  /// 🎯 Smart filter toggle with immediate search
  void toggleFilter(String filter) {
    debugPrint('🏷️ User toggled filter: $filter');

    if (filter == 'All Jobs') {
      // Reset to show all jobs
      debugPrint('🔄 Resetting to show all jobs');
      _activeFilters.clear();
    } else {
      // Toggle specific filter
      if (_activeFilters.contains(filter)) {
        debugPrint('➖ Removing filter: $filter');
        _activeFilters.remove(filter);
      } else {
        debugPrint('➕ Adding filter: $filter');
        _activeFilters.add(filter);
      }
    }

    debugPrint('🏷️ Active filters: ${_activeFilters.join(", ")}');

    // Apply filters with new search
    _applyFiltersAndSearch();
    notifyListeners();
  }

  /// 🔄 Applies current filters and searches
  Future<void> _applyFiltersAndSearch() async {
    debugPrint('🔄 Applying filters and searching...');

    // Build search parameters based on active filters
    String keywords = _searchQuery.isNotEmpty ? _searchQuery : '';
    String? contractType;
    String? contractPeriod;

    // 🎯 Smart Filter Translation:
    // Convert UI filters to CareerJet API parameters
    for (String filter in _activeFilters) {
      switch (filter) {
        case 'Full-time':
          contractPeriod = 'f'; // Full-time
          debugPrint('💼 Filter: Full-time jobs only');
          break;
        case 'Part-time':
          contractPeriod = 'p'; // Part-time
          debugPrint('⏰ Filter: Part-time jobs only');
          break;
        case 'Internship':
          contractType = 'i'; // Internship
          debugPrint('🎓 Filter: Internships only');
          break;
        case 'Contract':
          contractType = 'c'; // Contract
          debugPrint('📝 Filter: Contract positions only');
          break;
        case 'Remote':
          // Add remote to keywords for better matching
          keywords = keywords.isEmpty ? 'remote' : '$keywords remote';
          debugPrint('🏠 Filter: Remote work opportunities');
          break;
        case 'Hybrid':
          // Add hybrid to keywords for better matching
          keywords = keywords.isEmpty ? 'hybrid' : '$keywords hybrid';
          debugPrint('🏢 Filter: Hybrid work opportunities');
          break;
        case 'Tech Jobs':
          // Add tech keywords for better matching
          keywords = keywords.isEmpty
              ? 'tech software developer IT'
              : '$keywords tech';
          debugPrint('💻 Filter: Technology sector jobs');
          break;
        case 'Entry Level':
          // Add entry level keywords
          keywords = keywords.isEmpty
              ? 'junior entry graduate trainee'
              : '$keywords junior entry';
          debugPrint('🌱 Filter: Entry level positions');
          break;
        case 'Mid Level':
          // Add mid level keywords
          keywords = keywords.isEmpty
              ? 'mid intermediate experienced'
              : '$keywords mid intermediate';
          debugPrint('📈 Filter: Mid level positions');
          break;
        case 'Senior Level':
          // Add senior level keywords
          keywords = keywords.isEmpty
              ? 'senior lead principal manager'
              : '$keywords senior lead';
          debugPrint('👑 Filter: Senior level positions');
          break;
      }
    }

    // Execute the search with filters
    await searchJobs(
      keywords: keywords,
      contractType: contractType,
      contractPeriod: contractPeriod,
      forceRefresh: true,
    );
  }

  // 📡 CORE API INTEGRATION

  /// 🚀 Main search function - connects to CareerJet API
  Future<void> searchJobs({
    String? keywords,
    String? location,
    String sort = 'relevance',
    int page = 1,
    String? contractType,
    String? contractPeriod,
    bool forceRefresh = false,
  }) async {
    debugPrint('🚀 Starting job search...');
    debugPrint('📝 Keywords: ${keywords ?? "none"}');
    debugPrint('📍 Location: ${location ?? _locationQuery}');
    debugPrint('📊 Sort: $sort');
    debugPrint('📄 Page: $page');
    debugPrint('🔄 Force refresh: $forceRefresh');

    // Don't search if already loading (prevent duplicate calls)
    if ((_isLoading || _isLoadingMore) && !forceRefresh) {
      debugPrint('⏳ Already searching, skipping duplicate request');
      return;
    }

    // Set loading state
    if (page == 1) {
      _isLoading = true;
      _errorMessage = null; // Clear previous errors
      if (forceRefresh) {
        _jobs.clear(); // Clear existing results for fresh search
        _currentPage = 1; // Reset pagination
      }
    } else {
      _isLoadingMore = true; // Loading more pages
    }

    notifyListeners();

    try {
      debugPrint('📞 Calling CareerJet API...');

      // 🌟 Make the API call
      final response = await CareerJetApiService.searchJobs(
        keywords: keywords?.isNotEmpty == true ? keywords : null,
        location: location ?? _locationQuery,
        sort: sort,
        page: page,
        pageSize: 20, // Good balance between performance and content
        contractType: contractType,
        contractPeriod: contractPeriod,
      );

      if (response != null) {
        debugPrint('✅ API Success! Processing ${response.jobs.length} jobs...');
        debugPrint('📊 Total hits: ${response.hits}');
        debugPrint('📄 Current page: ${response.page}/${response.pages}');

        // 🔄 Process the response
        _jobsCount = response.hits;
        _currentPage = response.page;
        _totalPages = response.pages;

        // 🎯 Convert CareerJet jobs to our app format
        List<Map<String, dynamic>> newJobs = [];
        for (int i = 0; i < response.jobs.length; i++) {
          try {
            final appJob = response.jobs[i].toAppJobFormat(
              (_jobs.length + i), // Unique ID based on total jobs
            );

            // 🔍 Apply client-side filtering for better accuracy
            if (_shouldIncludeJob(appJob)) {
              newJobs.add(appJob);
              debugPrint(
                '✅ Processed job: ${appJob['title']} at ${appJob['company']}',
              );
            } else {
              debugPrint(
                '🚫 Filtered out job: ${appJob['title']} (doesn\'t match filters)',
              );
            }
          } catch (e) {
            debugPrint('⚠️ Failed to process job $i: $e');
          }
        }

        // 📝 Update job list
        if (page == 1) {
          _jobs = newJobs; // Replace for new search
          debugPrint('🔄 Replaced job list with ${newJobs.length} new jobs');
        } else {
          _jobs.addAll(newJobs); // Append for pagination
          debugPrint(
            '➕ Added ${newJobs.length} more jobs (total: ${_jobs.length})',
          );
        }

        // 🎉 Success feedback
        debugPrint('🎉 Search completed successfully!');
        debugPrint(
          '📊 Final stats: ${_jobs.length} jobs displayed, $_jobsCount total available',
        );
      } else {
        throw Exception('API returned null response');
      }
    } catch (e) {
      debugPrint('❌ Search failed: $e');

      // 🎭 User-friendly error handling
      if (e is CareerJetApiException) {
        _errorMessage = _getFriendlyErrorMessage(e);
        debugPrint('🎭 Showing user-friendly error: $_errorMessage');
      } else {
        _errorMessage =
            'Unable to load jobs right now. Please check your connection and try again.';
        debugPrint('🔧 Generic error shown to user');
      }

      // Keep existing jobs if this was a filter/search update
      if (_jobs.isEmpty) {
        debugPrint('💡 No existing jobs, will show error state');
      } else {
        debugPrint('📋 Keeping ${_jobs.length} existing jobs visible');
      }
    } finally {
      // 🏁 Always clean up loading states
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
      debugPrint('🏁 Search operation completed');
    }
  }

  /// 🔍 Client-side filtering for better accuracy
  bool _shouldIncludeJob(Map<String, dynamic> job) {
    // If no filters are active, include everything
    if (_activeFilters.isEmpty) {
      return true;
    }

    // Check each active filter
    for (String filter in _activeFilters) {
      switch (filter) {
        case 'Remote':
          // More thorough remote job detection
          String title = job['title']?.toLowerCase() ?? '';
          String location = job['location']?.toLowerCase() ?? '';
          String type = job['type']?.toLowerCase() ?? '';
          String description = job['description']?.toLowerCase() ?? '';

          bool isRemote =
              location.contains('remote') ||
              type.contains('remote') ||
              title.contains('remote') ||
              description.contains('remote') ||
              description.contains('work from home') ||
              description.contains('home office');

          if (!isRemote) {
            debugPrint('🚫 Job "${job['title']}" filtered out: not remote');
            return false;
          }
          break;

        case 'Hybrid':
          String title = job['title']?.toLowerCase() ?? '';
          String type = job['type']?.toLowerCase() ?? '';
          String description = job['description']?.toLowerCase() ?? '';

          bool isHybrid =
              type.contains('hybrid') ||
              title.contains('hybrid') ||
              description.contains('hybrid') ||
              description.contains('flexible working');

          if (!isHybrid) {
            debugPrint('🚫 Job "${job['title']}" filtered out: not hybrid');
            return false;
          }
          break;

        case 'On-site':
          String type = job['type']?.toLowerCase() ?? '';
          String description = job['description']?.toLowerCase() ?? '';

          bool isOnSite =
              !type.contains('remote') &&
              !type.contains('hybrid') &&
              !description.contains('remote') &&
              !description.contains('work from home');

          if (!isOnSite) {
            debugPrint('🚫 Job "${job['title']}" filtered out: not on-site');
            return false;
          }
          break;

        case 'Entry Level':
          String title = job['title']?.toLowerCase() ?? '';
          String description = job['description']?.toLowerCase() ?? '';

          bool isEntryLevel =
              title.contains('junior') ||
              title.contains('entry') ||
              title.contains('graduate') ||
              title.contains('trainee') ||
              title.contains('intern') ||
              description.contains('entry level') ||
              description.contains('graduate') ||
              description.contains('no experience');

          if (!isEntryLevel) {
            debugPrint(
              '🚫 Job "${job['title']}" filtered out: not entry level',
            );
            return false;
          }
          break;

        case 'Mid Level':
          String title = job['title']?.toLowerCase() ?? '';
          String description = job['description']?.toLowerCase() ?? '';

          bool isMidLevel =
              title.contains('mid') ||
              title.contains('intermediate') ||
              description.contains('2-5 years') ||
              description.contains('3-5 years') ||
              description.contains('experienced');

          if (!isMidLevel) {
            debugPrint('🚫 Job "${job['title']}" filtered out: not mid level');
            return false;
          }
          break;

        case 'Senior Level':
          String title = job['title']?.toLowerCase() ?? '';
          String description = job['description']?.toLowerCase() ?? '';

          bool isSeniorLevel =
              title.contains('senior') ||
              title.contains('lead') ||
              title.contains('principal') ||
              title.contains('manager') ||
              description.contains('5+ years') ||
              description.contains('senior level');

          if (!isSeniorLevel) {
            debugPrint(
              '🚫 Job "${job['title']}" filtered out: not senior level',
            );
            return false;
          }
          break;

        case 'Full-time':
          String workType = job['workType']?.toLowerCase() ?? '';
          String description = job['description']?.toLowerCase() ?? '';

          bool isFullTime =
              workType.contains('full') ||
              description.contains('full time') ||
              description.contains('full-time');

          if (!isFullTime) {
            debugPrint('🚫 Job "${job['title']}" filtered out: not full-time');
            return false;
          }
          break;

        case 'Part-time':
          String workType = job['workType']?.toLowerCase() ?? '';
          String description = job['description']?.toLowerCase() ?? '';

          bool isPartTime =
              workType.contains('part') ||
              description.contains('part time') ||
              description.contains('part-time');

          if (!isPartTime) {
            debugPrint('🚫 Job "${job['title']}" filtered out: not part-time');
            return false;
          }
          break;

        case 'Internship':
          String workType = job['workType']?.toLowerCase() ?? '';
          String title = job['title']?.toLowerCase() ?? '';

          bool isInternship =
              workType.contains('intern') ||
              title.contains('intern') ||
              title.contains('trainee');

          if (!isInternship) {
            debugPrint('🚫 Job "${job['title']}" filtered out: not internship');
            return false;
          }
          break;

        case 'Contract':
          String workType = job['workType']?.toLowerCase() ?? '';
          String description = job['description']?.toLowerCase() ?? '';

          bool isContract =
              workType.contains('contract') ||
              description.contains('contract') ||
              description.contains('temporary');

          if (!isContract) {
            debugPrint('🚫 Job "${job['title']}" filtered out: not contract');
            return false;
          }
          break;

        case 'Tech Jobs':
          String title = job['title']?.toLowerCase() ?? '';
          String description = job['description']?.toLowerCase() ?? '';
          List<String> tags = (job['tags'] as List<String>? ?? [])
              .map((tag) => tag.toLowerCase())
              .toList();

          bool isTech =
              title.contains('developer') ||
              title.contains('engineer') ||
              title.contains('programmer') ||
              title.contains('analyst') ||
              title.contains('tech') ||
              title.contains('software') ||
              title.contains('data') ||
              title.contains('web') ||
              title.contains('mobile') ||
              title.contains('frontend') ||
              title.contains('backend') ||
              title.contains('fullstack') ||
              description.contains('programming') ||
              description.contains('coding') ||
              description.contains('software') ||
              tags.any(
                (tag) => [
                  'javascript',
                  'python',
                  'java',
                  'react',
                  'angular',
                  'vue',
                  'node',
                  'sql',
                  'git',
                ].contains(tag),
              );

          if (!isTech) {
            debugPrint('🚫 Job "${job['title']}" filtered out: not tech');
            return false;
          }
          break;

        case 'This Week':
          String postedDate = job['postedDate'] ?? '';
          if (postedDate.isNotEmpty) {
            try {
              DateTime posted = DateTime.parse(postedDate);
              DateTime weekAgo = DateTime.now().subtract(Duration(days: 7));
              if (posted.isBefore(weekAgo)) {
                debugPrint(
                  '🚫 Job "${job['title']}" filtered out: not from this week',
                );
                return false;
              }
            } catch (e) {
              // If date parsing fails, include the job
              debugPrint('⚠️ Could not parse date for job: ${job['title']}');
            }
          }
          break;

        case 'Easy Apply':
          String url = job['url']?.toLowerCase() ?? '';
          String description = job['description']?.toLowerCase() ?? '';

          bool hasEasyApply =
              url.contains('apply') ||
              description.contains('apply now') ||
              description.contains('quick apply') ||
              description.contains('easy apply');

          if (!hasEasyApply) {
            debugPrint('🚫 Job "${job['title']}" filtered out: no easy apply');
            return false;
          }
          break;

        case 'New Jobs':
          bool isNew = job['isNew'] ?? false;
          if (!isNew) {
            debugPrint('🚫 Job "${job['title']}" filtered out: not new');
            return false;
          }
          break;

        case 'High Salary':
          String salary = job['salary']?.toLowerCase() ?? '';
          // Simple salary range check - could be more sophisticated
          if (salary.contains('negotiable') || salary.isEmpty) {
            // Include negotiable salaries as they might be in range
            continue;
          }

          // Extract numbers from salary string for basic range checking
          RegExp numberRegex = RegExp(r'(\d+)');
          Iterable<Match> matches = numberRegex.allMatches(salary);
          if (matches.isNotEmpty) {
            int firstNumber = int.tryParse(matches.first.group(0) ?? '0') ?? 0;
            // If salary mentions a number below 30k, exclude it
            if (firstNumber > 0 && firstNumber < 25) {
              debugPrint(
                '🚫 Job "${job['title']}" filtered out: salary too low',
              );
              return false;
            }
          }
          break;
      }
    }

    return true;
  }

  /// 🎭 Converts technical errors to user-friendly messages
  String _getFriendlyErrorMessage(CareerJetApiException e) {
    if (e.message.contains('timeout')) {
      return '⏱️ The job search is taking longer than usual. Please try again.';
    } else if (e.message.contains('network') ||
        e.message.contains('connection')) {
      return '📡 Please check your internet connection and try again.';
    } else if (e.message.contains('rate limit')) {
      return '🚦 Too many searches! Please wait a moment before trying again.';
    } else if (e.message.contains('403') || e.message.contains('access')) {
      return '🔐 Service temporarily unavailable. We\'re working on it!';
    } else {
      return '🔧 Something went wrong while searching for jobs. Please try again.';
    }
  }

  // 📄 PAGINATION SUPPORT

  /// ➕ Load more jobs (next page)
  Future<void> loadMoreJobs() async {
    if (!hasMorePages || _isLoadingMore) {
      debugPrint('📄 No more pages to load or already loading');
      return;
    }

    debugPrint('📄 Loading page ${_currentPage + 1}...');

    // Build the same search parameters as the current search
    String keywords = _searchQuery.isNotEmpty ? _searchQuery : '';
    String? contractType;
    String? contractPeriod;

    // Apply the same filters as the current search
    for (String filter in _activeFilters) {
      switch (filter) {
        case 'Full-time':
          contractPeriod = 'f';
          break;
        case 'Part-time':
          contractPeriod = 'p';
          break;
        case 'Internship':
          contractType = 'i';
          break;
        case 'Contract':
          contractType = 'c';
          break;
        case 'Remote':
          keywords = keywords.isEmpty ? 'remote' : '$keywords remote';
          break;
        case 'Hybrid':
          keywords = keywords.isEmpty ? 'hybrid' : '$keywords hybrid';
          break;
        case 'Tech Jobs':
          keywords = keywords.isEmpty
              ? 'tech software developer IT'
              : '$keywords tech';
          break;
        case 'Entry Level':
          keywords = keywords.isEmpty
              ? 'junior entry graduate trainee'
              : '$keywords junior entry';
          break;
        case 'Mid Level':
          keywords = keywords.isEmpty
              ? 'mid intermediate experienced'
              : '$keywords mid intermediate';
          break;
        case 'Senior Level':
          keywords = keywords.isEmpty
              ? 'senior lead principal manager'
              : '$keywords senior lead';
          break;
      }
    }

    await searchJobs(
      keywords: keywords,
      location: _locationQuery,
      sort: _convertSortOption(_sortOption),
      page: _currentPage + 1,
      contractType: contractType,
      contractPeriod: contractPeriod,
    );
  }

  /// 🔄 Refresh current search
  Future<void> refreshJobs() async {
    debugPrint('🔄 User requested refresh');
    await searchJobs(
      keywords: _searchQuery.isNotEmpty ? _searchQuery : null,
      location: _locationQuery,
      sort: _convertSortOption(_sortOption),
      forceRefresh: true,
    );
  }

  // 💾 SAVED JOBS MANAGEMENT

  /// 💾 Toggle save status of a job
  void toggleSaveJob(int jobId) {
    debugPrint('💾 User toggled save for job ID: $jobId');

    if (_savedJobs.contains(jobId)) {
      _savedJobs.remove(jobId);
      _savedJobsCount--;
      debugPrint(
        '➖ Removed job from saved list (total saved: $_savedJobsCount)',
      );
    } else {
      _savedJobs.add(jobId);
      _savedJobsCount++;
      debugPrint('➕ Added job to saved list (total saved: $_savedJobsCount)');
    }
    notifyListeners();
  }

  /// ✅ Check if job is saved
  bool isJobSaved(int jobId) => _savedJobs.contains(jobId);

  /// 📋 Get saved jobs list
  List<Map<String, dynamic>> getSavedJobs() {
    return _jobs.where((job) => _savedJobs.contains(job['id'])).toList();
  }

  // 🎯 FILTER UTILITIES

  /// ✅ Check if filter is active
  bool isFilterActive(String filter) => _activeFilters.contains(filter);

  /// 📊 Get formatted job count string
  String getJobCountString() {
    if (_isLoading) {
      return 'Loading jobs...';
    }

    if (hasError) {
      return 'Unable to load jobs';
    }

    if (_jobsCount == 0) {
      return 'No jobs found';
    }

    // Format the total job count with thousands separator
    String formattedTotal = _formatNumber(_jobsCount);
    String formattedShowing = _formatNumber(_jobs.length);

    if (_jobs.length == _jobsCount) {
      // Showing all available jobs
      if (_jobsCount == 1) {
        return '1 job available';
      } else {
        return '$formattedTotal jobs available';
      }
    } else {
      // Showing subset of jobs (pagination)
      return 'Showing $formattedShowing of $formattedTotal jobs';
    }
  }

  /// 🔢 Format numbers with thousands separators
  String _formatNumber(int number) {
    if (number < 1000) {
      return number.toString();
    } else if (number < 1000000) {
      return '${(number / 1000).toStringAsFixed(number % 1000 == 0 ? 0 : 1)}k';
    } else {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    }
  }

  /// 🎨 Get gradient colors for match level
  List<Color> getMatchGradient(String level) {
    switch (level) {
      case 'high':
        return [const Color(0xFF10B981), const Color(0xFF34D399)];
      case 'medium':
        return [const Color(0xFFF59E0B), const Color(0xFFFBBF24)];
      case 'low':
        return [const Color(0xFF9CA3AF), const Color(0xFF6B7280)];
      default:
        return [const Color(0xFF10B981), const Color(0xFF34D399)];
    }
  }

  // 📊 JOB DETAIL DATA

  /// 🎯 Get similar jobs (mock data for now - could be enhanced with API)
  List<Map<String, dynamic>> getSimilarJobs() {
    debugPrint('🔍 Generating similar jobs recommendations...');

    // For now, return some of our current jobs as "similar"
    // In a real app, this could use ML or API recommendations
    return _jobs
        .take(3)
        .map(
          (job) => {
            'title': job['title'],
            'company': job['company'],
            'location': job['location'],
            'salary': job['salary'],
            'match': job['matchScore'] ?? 75,
          },
        )
        .toList();
  }

  /// ✅ Get job requirements (extracted from actual job description)
  List<Map<String, String>> getJobRequirements(Map<String, dynamic> job) {
    debugPrint('📋 Extracting job requirements from description...');

    final description = job['description']?.toLowerCase() ?? '';
    final title = job['title']?.toLowerCase() ?? '';
    final requirements = <Map<String, String>>[];

    // Extract education requirements
    if (description.contains('degree') ||
        description.contains('diploma') ||
        description.contains('qualification')) {
      requirements.add({
        'text': _extractEducationRequirement(description),
        'status': 'met', // Assume user has basic education
      });
    }

    // Extract experience requirements
    final experienceReq = _extractExperienceRequirement(description);
    if (experienceReq.isNotEmpty) {
      requirements.add({
        'text': experienceReq,
        'status': _assessExperienceMatch(experienceReq),
      });
    }

    // Extract technical skills
    final techSkills = _extractTechnicalSkills(description, title);
    for (final skill in techSkills) {
      requirements.add({'text': skill, 'status': _assessSkillMatch(skill)});
    }

    // Extract soft skills
    final softSkills = _extractSoftSkills(description);
    for (final skill in softSkills) {
      requirements.add({
        'text': skill,
        'status': 'met', // Assume user has basic soft skills
      });
    }

    // Extract location/visa requirements
    if (description.contains('south africa') ||
        description.contains('citizenship') ||
        description.contains('work permit')) {
      requirements.add({
        'text': 'South African citizenship or valid work permit',
        'status': 'met',
      });
    }

    return requirements.isNotEmpty ? requirements : _getDefaultRequirements();
  }

  String _extractEducationRequirement(String description) {
    if (description.contains('bachelor') || description.contains('degree')) {
      return 'Bachelor\'s degree in Computer Science, IT, or related field';
    } else if (description.contains('diploma')) {
      return 'Diploma in Computer Science, IT, or related field';
    } else if (description.contains('matric') ||
        description.contains('grade 12')) {
      return 'Matric certificate or equivalent';
    }
    return 'Relevant qualification in Computer Science, IT, or related field';
  }

  String _extractExperienceRequirement(String description) {
    final experiencePatterns = [
      r'(\d+)\+?\s*years?\s*experience',
      r'(\d+)\+?\s*years?\s*in\s*',
      r'minimum\s*(\d+)\s*years?',
      r'at\s*least\s*(\d+)\s*years?',
    ];

    for (final pattern in experiencePatterns) {
      final regex = RegExp(pattern, caseSensitive: false);
      final match = regex.firstMatch(description);
      if (match != null) {
        final years = match.group(1);
        return 'Minimum $years years of relevant experience';
      }
    }

    if (description.contains('senior') || description.contains('lead')) {
      return '5+ years of relevant experience';
    } else if (description.contains('mid') ||
        description.contains('intermediate')) {
      return '2-5 years of relevant experience';
    } else if (description.contains('junior') ||
        description.contains('entry')) {
      return '0-2 years of relevant experience';
    }

    return '';
  }

  List<String> _extractTechnicalSkills(String description, String title) {
    final skills = <String>[];
    final content = '$description $title'.toLowerCase();

    final skillMap = {
      'javascript': 'JavaScript programming',
      'python': 'Python programming',
      'java': 'Java programming',
      'react': 'React framework',
      'angular': 'Angular framework',
      'vue': 'Vue.js framework',
      'node': 'Node.js development',
      'sql': 'SQL database knowledge',
      'mongodb': 'MongoDB database',
      'aws': 'Amazon Web Services',
      'azure': 'Microsoft Azure',
      'docker': 'Docker containerization',
      'kubernetes': 'Kubernetes orchestration',
      'git': 'Git version control',
      'agile': 'Agile methodology',
      'scrum': 'Scrum framework',
      'html': 'HTML markup',
      'css': 'CSS styling',
      'flutter': 'Flutter development',
      'dart': 'Dart programming',
      'typescript': 'TypeScript programming',
      'php': 'PHP programming',
      'c#': 'C# programming',
      '.net': '.NET framework',
      'spring': 'Spring framework',
      'express': 'Express.js framework',
      'mysql': 'MySQL database',
      'postgresql': 'PostgreSQL database',
      'redis': 'Redis caching',
      'elasticsearch': 'Elasticsearch search',
      'kafka': 'Apache Kafka messaging',
      'microservices': 'Microservices architecture',
      'rest': 'REST API development',
      'graphql': 'GraphQL API development',
      'jwt': 'JWT authentication',
      'oauth': 'OAuth authentication',
      'ci/cd': 'CI/CD pipeline knowledge',
      'jenkins': 'Jenkins automation',
      'terraform': 'Terraform infrastructure',
      'linux': 'Linux administration',
      'windows': 'Windows administration',
    };

    for (final entry in skillMap.entries) {
      if (content.contains(entry.key)) {
        skills.add(entry.value);
      }
    }

    return skills.take(5).toList(); // Limit to 5 most relevant skills
  }

  List<String> _extractSoftSkills(String description) {
    final skills = <String>[];
    final content = description.toLowerCase();

    final softSkillMap = {
      'communication': 'Excellent communication skills',
      'teamwork': 'Strong teamwork abilities',
      'problem solving': 'Problem-solving skills',
      'analytical': 'Analytical thinking',
      'leadership': 'Leadership qualities',
      'time management': 'Time management skills',
      'attention to detail': 'Attention to detail',
      'adaptability': 'Adaptability and flexibility',
      'creativity': 'Creative thinking',
      'initiative': 'Self-motivation and initiative',
    };

    for (final entry in softSkillMap.entries) {
      if (content.contains(entry.key)) {
        skills.add(entry.value);
      }
    }

    return skills.take(3).toList(); // Limit to 3 most relevant soft skills
  }

  String _assessExperienceMatch(String requirement) {
    // This is a simplified assessment - in a real app, you'd compare against user profile
    if (requirement.contains('0-2') ||
        requirement.contains('junior') ||
        requirement.contains('entry')) {
      return 'met';
    } else if (requirement.contains('2-5') || requirement.contains('mid')) {
      return 'partial';
    } else if (requirement.contains('5+') || requirement.contains('senior')) {
      return 'unmet';
    }
    return 'partial';
  }

  String _assessSkillMatch(String skill) {
    // This is a simplified assessment - in a real app, you'd compare against user skills
    final commonSkills = [
      'javascript',
      'html',
      'css',
      'git',
      'problem solving',
      'communication',
    ];
    final skillLower = skill.toLowerCase();

    for (final commonSkill in commonSkills) {
      if (skillLower.contains(commonSkill)) {
        return 'met';
      }
    }
    return 'partial';
  }

  List<Map<String, String>> _getDefaultRequirements() {
    return [
      {
        'text': 'Bachelor\'s degree in Computer Science, IT, or related field',
        'status': 'met',
      },
      {
        'text': 'Basic knowledge of JavaScript and modern frameworks',
        'status': 'met',
      },
      {
        'text': 'Understanding of HTML, CSS, and responsive design',
        'status': 'met',
      },
      {'text': 'Experience with Git version control', 'status': 'partial'},
      {
        'text': 'Strong problem-solving skills and attention to detail',
        'status': 'met',
      },
      {'text': 'Knowledge of SQL and database concepts', 'status': 'unmet'},
      {'text': 'Excellent communication skills in English', 'status': 'met'},
      {
        'text': 'South African citizenship or valid work permit',
        'status': 'met',
      },
    ];
  }

  /// 🛠️ Get required skills analysis (extracted from actual job description)
  List<Map<String, dynamic>> getSkillsRequired(Map<String, dynamic> job) {
    debugPrint('🛠️ Analyzing skill requirements from job description...');

    final description = job['description']?.toLowerCase() ?? '';
    final title = job['title']?.toLowerCase() ?? '';

    final skills = <Map<String, dynamic>>[];

    // Extract technical skills from job description
    final techSkills = _extractTechnicalSkills(description, title);
    for (final skill in techSkills) {
      skills.add({
        'name': skill,
        'hasSkill': _assessSkillMatch(skill) == 'met',
      });
    }

    // Extract soft skills
    final softSkills = _extractSoftSkills(description);
    for (final skill in softSkills) {
      skills.add({
        'name': skill,
        'hasSkill': true, // Assume user has basic soft skills
      });
    }

    // If no skills found, return default skills
    return skills.isNotEmpty ? skills : _getDefaultSkills();
  }

  List<Map<String, dynamic>> _getDefaultSkills() {
    return [
      {'name': 'JavaScript', 'hasSkill': true},
      {'name': 'HTML/CSS', 'hasSkill': true},
      {'name': 'React', 'hasSkill': true},
      {'name': 'Git', 'hasSkill': false},
      {'name': 'SQL', 'hasSkill': false},
      {'name': 'Problem Solving', 'hasSkill': true},
      {'name': 'Team Work', 'hasSkill': true},
      {'name': 'Agile', 'hasSkill': false},
    ];
  }

  /// 📝 Get job description
  String getJobDescription(Map<String, dynamic> job) {
    if (job['description'] != null) {
      return job['description'];
    }

    // Fallback description
    return 'We\'re looking for a passionate developer to join our growing team. This is an excellent opportunity to work on exciting projects and advance your career in technology.';
  }

  /// 🎁 Get job benefits
  String getJobBenefits() {
    return '• Competitive salary\n'
        '• Medical aid contribution\n'
        '• Annual performance bonus\n'
        '• Flexible working arrangement\n'
        '• Professional development opportunities\n'
        '• Modern office environment\n'
        '• Team building events\n'
        '• Clear career progression path';
  }

  // 🧪 TESTING & DEBUG UTILITIES

  /// 🧪 Test API connection
  Future<void> testApiConnection() async {
    debugPrint('🧪 Testing CareerJet API connection...');

    try {
      final testResult = await CareerJetApiService.testConnection();
      if (testResult.success) {
        debugPrint('✅ API Test Success: ${testResult.message}');
        _errorMessage = null;
      } else {
        debugPrint('❌ API Test Failed: ${testResult.message}');
        _errorMessage = testResult.message;
      }
    } catch (e) {
      debugPrint('💥 API Test Exception: $e');
      _errorMessage = 'API test failed: $e';
    }

    notifyListeners();
  }

  /// 📊 Get debug info
  Map<String, dynamic> getDebugInfo() {
    return {
      'jobsCount': _jobsCount,
      'currentPage': _currentPage,
      'totalPages': _totalPages,
      'searchQuery': _searchQuery,
      'locationQuery': _locationQuery,
      'activeFilters': _activeFilters.toList(),
      'isLoading': _isLoading,
      'hasError': hasError,
      'errorMessage': _errorMessage,
      'savedJobsCount': _savedJobsCount,
      'totalJobsLoaded': _jobs.length,
      'hasMorePages': hasMorePages,
      'isLoadingMore': _isLoadingMore,
    };
  }

  // 🧹 CLEANUP

  @override
  void dispose() {
    debugPrint('🧹 JobsScreenViewModel disposing...');
    super.dispose();
  }
}
