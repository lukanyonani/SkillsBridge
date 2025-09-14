import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider;
import 'package:skillsbridge/data/bursary_api.dart';
import '../models/bursary_models.dart';

// State class that holds all the data
class BursaryFinderState {
  final List<Bursary> bursaryList;
  final List<String> fieldOptions;
  final String selectedField;
  final double currentAmount;
  final String sortOption;
  final int totalResults;
  final bool isLoading;
  final bool isRefreshing;
  final bool isLoadingMore;
  final String? errorMessage;
  final Set<String> savedIds;
  final Set<String> activeQuickFilters;
  final int urgentCount;

  const BursaryFinderState({
    this.bursaryList = const [],
    this.fieldOptions = const ['All'],
    this.selectedField = 'All',
    this.currentAmount = 0,
    this.sortOption = 'Relevance',
    this.totalResults = 0,
    this.isLoading = false,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.savedIds = const {},
    this.activeQuickFilters = const {},
    this.urgentCount = 0,
  });

  BursaryFinderState copyWith({
    List<Bursary>? bursaryList,
    List<String>? fieldOptions,
    String? selectedField,
    double? currentAmount,
    String? sortOption,
    int? totalResults,
    bool? isLoading,
    bool? isRefreshing,
    bool? isLoadingMore,
    String? errorMessage,
    Set<String>? savedIds,
    Set<String>? activeQuickFilters,
    int? urgentCount,
  }) {
    return BursaryFinderState(
      bursaryList: bursaryList ?? this.bursaryList,
      fieldOptions: fieldOptions ?? this.fieldOptions,
      selectedField: selectedField ?? this.selectedField,
      currentAmount: currentAmount ?? this.currentAmount,
      sortOption: sortOption ?? this.sortOption,
      totalResults: totalResults ?? this.totalResults,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
      savedIds: savedIds ?? this.savedIds,
      activeQuickFilters: activeQuickFilters ?? this.activeQuickFilters,
      urgentCount: urgentCount ?? this.urgentCount,
    );
  }

  // Computed properties
  int get resultsCount => totalResults > 0 ? totalResults : bursaryList.length;
  int get urgentBursariesCount => urgentCount;
  int get savedCount => savedIds.length;
  bool isBursarySaved(String id) => savedIds.contains(id);
  bool isFilterActive(String filter) => activeQuickFilters.contains(filter);
}

// StateNotifier that manages the state
class BursaryFinderNotifier extends StateNotifier<BursaryFinderState> {
  BursaryFinderNotifier() : super(const BursaryFinderState()) {
    initialize();
  }

  final BursaryApiService _api = BursaryApiService();
  final List<String> quickFilterOptions = const [
    'Open Now',
    'Full Funding',
    'Undergraduate',
    'Postgraduate',
    'Work Back',
    'Saved',
  ];
  final List<String> sortOptions = const [
    'Relevance',
    'Closing Soon',
    'Newest',
    'Highest Amount',
    'Lowest Amount',
  ];

  // Private variables for internal use
  String _searchQuery = '';
  int _page = 1;
  final int _limit = 10;
  Timer? _debounceTimer;

  /// Initialize the notifier
  Future<void> initialize() async {
    debugPrint('🚀 Initializing Bursary Notifier with lively spirit!');
    await _fetchFieldCategories();
    await _fetchUrgentCount();
    await refreshBursaries();
  }

  /// Refresh the list (reset pagination)
  Future<void> refreshBursaries() async {
    debugPrint('🔄 Refreshing bursaries - let\'s get fresh data!');
    _page = 1;
    state = state.copyWith(isRefreshing: true, errorMessage: null);

    try {
      await _fetchBursaries(reset: true);
      await _fetchUrgentCount();
    } finally {
      state = state.copyWith(isRefreshing: false);
    }
  }

  /// Load next page (pagination)
  Future<void> loadMore() async {
    if (state.isLoadingMore || state.isLoading) return;
    if (_hasLocalFilters()) {
      debugPrint('📄 Local filters active - skipping pagination load more!');
      return;
    }
    if (state.totalResults > 0 &&
        state.bursaryList.length >= state.totalResults) {
      debugPrint('🏁 No more bursaries to load - we\'ve reached the end!');
      return;
    }

    _page += 1;
    state = state.copyWith(isLoadingMore: true);

    try {
      await _fetchBursaries(reset: false);
    } finally {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  /// Update search query with debouncing
  void updateSearchQuery(String q) {
    _searchQuery = q.trim();
    debugPrint('🔍 User typing search: "$_searchQuery" - debouncing...');

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      refreshBursaries();
    });
  }

  /// Update field selection
  void updateField(String newField) {
    state = state.copyWith(selectedField: newField);
    debugPrint('🎓 Field updated to: $newField - refreshing!');
    refreshBursaries();
  }

  /// Toggle quick filter
  void toggleQuickFilter(String filter) {
    final newFilters = Set<String>.from(state.activeQuickFilters);
    if (newFilters.contains(filter)) {
      newFilters.remove(filter);
      debugPrint('⚡ Removed quick filter: $filter');
    } else {
      newFilters.add(filter);
      debugPrint('⚡ Added quick filter: $filter');
    }
    state = state.copyWith(activeQuickFilters: newFilters);
    refreshBursaries();
  }

  /// Update amount slider
  void updateAmount(double amount) {
    state = state.copyWith(currentAmount: amount);
    debugPrint(
      '💰 Amount updated to: R${amount.toInt()} - applying local filter!',
    );
    refreshBursaries();
  }

  /// Set preset amount
  void setPresetAmount(double amount) {
    state = state.copyWith(currentAmount: amount);
    debugPrint('💰 Preset amount set to: R${amount.toInt()} - refreshing!');
    refreshBursaries();
  }

  /// Handle bookmark tap
  void onBookmarkTapped() {
    toggleQuickFilter('Saved');
    debugPrint('🔖 Bookmark tapped - toggling saved filter!');
  }

  /// Toggle save bursary
  void toggleSaveBursary(String id) {
    final newSavedIds = Set<String>.from(state.savedIds);
    if (newSavedIds.contains(id)) {
      newSavedIds.remove(id);
      debugPrint('🔖 Removed save for bursary ID: $id');
    } else {
      newSavedIds.add(id);
      debugPrint('🔖 Saved bursary ID: $id');
    }
    state = state.copyWith(savedIds: newSavedIds);
  }

  /// Handle view all deadlines
  void onViewAllDeadlinesTapped() {
    state = state.copyWith(sortOption: 'Closing Soon');
    debugPrint('⏰ View all deadlines tapped - sorting by closing soon!');
    refreshBursaries();
  }

  /// Update sort option
  void updateSortOption(String option) {
    state = state.copyWith(sortOption: option);
    debugPrint('📊 Sort option updated to: $option - refreshing!');
    refreshBursaries();
  }

  /// Get bursary details
  Future<Bursary?> getBursaryDetails(String id) async {
    debugPrint('📖 Fetching details for bursary ID: $id');

    // 1) local cache
    final local = state.bursaryList.firstWhere(
      (b) => b.id == id,
      orElse: () => Bursary(
        id: '',
        provider: Provider(name: ''),
        title: '',
        fields: [],
        studyLevel: '',
        academicYear: '',
        coverage: Coverage(type: '', covers: []),
        workBackObligation: WorkBackObligation(
          required: false,
          additionalBenefits: [],
        ),
        deadline: Deadline(closingDate: '', displayText: '', isUrgent: false),
        eligibility: Eligibility(qualifications: []),
        applicationProcess: ApplicationProcess(method: '', steps: []),
        requiredDocuments: [],
        selectionProcess: SelectionProcess(noResponseMeansRejection: false),
        scraped: ScrapedInfo(sourceUrl: '', lastUpdated: '', scrapedAt: ''),
        tags: [],
        isSaved: false,
      ),
    );
    if (local.id.isNotEmpty) {
      debugPrint('✅ Found details in local cache!');
      return local;
    }

    // 2) fallback search
    try {
      debugPrint('🔍 Falling back to API search for ID: $id');
      final resp = await _api.getBursaries(search: id, page: 1, limit: 1);
      if (resp.bursaries.isNotEmpty) {
        debugPrint('✅ Found details via API search!');
        return resp.bursaries.first;
      }
    } catch (e) {
      debugPrint('❌ Error fetching bursary details fallback: $e');
    }

    debugPrint('⚠️ No details found for ID: $id');
    return null;
  }

  // Utility methods
  String getPresetAmountLabel(double amount) {
    if (amount >= 1000) {
      final rounded = (amount / 1000).round();
      return 'R${rounded}k';
    }
    return 'R${amount.toInt()}';
  }

  String getFormattedAmount() {
    final v = state.currentAmount.toInt();
    return 'R${_formatNumberWithCommas(v)}';
  }

  // Private methods
  Future<void> _fetchFieldCategories() async {
    debugPrint('📚 Fetching field categories from API...');
    try {
      final resp = await _api.getFieldCategories();
      final remote = resp.categories.map((c) => c.name).toList();
      if (remote.isNotEmpty) {
        state = state.copyWith(fieldOptions: ['All', ...remote]);
        debugPrint('✅ Loaded ${state.fieldOptions.length} field options!');
      } else {
        state = state.copyWith(
          fieldOptions: [
            'All',
            'Engineering',
            'Business',
            'Health',
            'IT',
            'Education',
            'Law',
          ],
        );
        debugPrint('⚠️ Using default field options (API returned empty)');
      }
    } catch (e) {
      debugPrint('❌ Failed to fetch field categories: $e');
      state = state.copyWith(
        fieldOptions: [
          'All',
          'Engineering',
          'Business',
          'Health',
          'IT',
          'Education',
          'Law',
        ],
      );
      debugPrint('⚠️ Falling back to default field options');
    }
  }

  Future<void> _fetchUrgentCount() async {
    debugPrint('🆘 Fetching urgent bursaries count...');
    try {
      final resp = await _api.getUrgentBursaries();
      state = state.copyWith(urgentCount: resp.summary.urgentCount);
      debugPrint('✅ Urgent count: ${state.urgentCount}');
    } catch (e) {
      debugPrint('❌ Failed to fetch urgent count: $e');
      state = state.copyWith(urgentCount: 0);
    }
  }

  Future<void> _fetchBursaries({required bool reset}) async {
    debugPrint('🚀 Fetching bursaries (page: $_page, reset: $reset)...');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final String? fieldParam =
          (state.selectedField.isNotEmpty && state.selectedField != 'All')
          ? state.selectedField
          : null;

      // Quick filter mappings
      String? studyLevel;
      String? workBack;
      String? coverageType;

      if (state.activeQuickFilters.contains('Full Funding')) {
        coverageType = 'full';
        debugPrint('⚡ Applying full funding filter');
      }
      if (state.activeQuickFilters.contains('Undergraduate')) {
        studyLevel = 'undergraduate';
        debugPrint('⚡ Applying undergraduate filter');
      }
      if (state.activeQuickFilters.contains('Postgraduate')) {
        studyLevel = 'postgraduate';
        debugPrint('⚡ Applying postgraduate filter');
      }
      if (state.activeQuickFilters.contains('Work Back')) {
        workBack = 'yes';
        debugPrint('⚡ Applying work back filter');
      }

      // Handle "Saved" filter locally
      if (state.activeQuickFilters.contains('Saved')) {
        debugPrint('🔖 Applying saved filter locally');
        final saved = state.bursaryList
            .where((b) => state.savedIds.contains(b.id))
            .toList();
        final newList = reset ? saved : [...state.bursaryList, ...saved];
        state = state.copyWith(
          bursaryList: newList,
          totalResults: newList.length,
          isLoading: false,
        );
        return;
      }

      // Map sort options
      String? sortParam;
      switch (state.sortOption) {
        case 'Closing Soon':
          sortParam = 'closing_date:asc';
          break;
        case 'Newest':
          sortParam = 'scraped_at:desc';
          break;
        case 'Highest Amount':
          sortParam = 'amount:desc';
          break;
        case 'Lowest Amount':
          sortParam = 'amount:asc';
          break;
        default:
          sortParam = 'relevance:desc';
      }

      int fetchLimit = _limit;
      int fetchPage = _page;
      if (_hasLocalFilters()) {
        fetchLimit = 1000;
        fetchPage = 1;
        debugPrint(
          '⚠️ Local filters active - fetching larger batch for filtering!',
        );
      }

      // API call
      final BursariesResponse resp = await _api.getBursaries(
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        field: fieldParam,
        studyLevel: studyLevel,
        workBack: workBack,
        coverageType: coverageType,
        page: fetchPage,
        limit: fetchLimit,
        sort: sortParam,
      );

      List<Bursary> fetched = resp.bursaries;

      // Apply local filters
      if (state.currentAmount > 0) {
        debugPrint(
          '💰 Applying local amount filter: >= R${state.currentAmount.toInt()}',
        );
        fetched = fetched.where((b) {
          final amtStr =
              b.coverage.amount?.replaceAll('R', '').replaceAll(',', '') ?? '0';
          final amt = double.tryParse(amtStr) ?? 0;
          return amt >= state.currentAmount;
        }).toList();
      }

      if (state.activeQuickFilters.contains('Open Now')) {
        final now = DateTime.now();
        debugPrint(
          '⏰ Applying local open now filter: closing after ${now.toIso8601String()}',
        );
        fetched = fetched.where((b) {
          final close = DateTime.tryParse(b.deadline.closingDate);
          return close != null && close.isAfter(now);
        }).toList();
      }

      // Update state
      final newList = reset || _hasLocalFilters()
          ? fetched
          : [...state.bursaryList, ...fetched];

      state = state.copyWith(
        bursaryList: newList,
        totalResults: _hasLocalFilters()
            ? fetched.length
            : resp.pagination.total,
        isLoading: false,
      );

      debugPrint(
        '✅ Fetched ${fetched.length} bursaries - total now: ${state.bursaryList.length}',
      );
    } on BursaryApiException catch (e) {
      state = state.copyWith(errorMessage: e.message, isLoading: false);
      debugPrint('❌ BursaryApiException: ${e.message} (${e.statusCode})');
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to fetch bursaries. Please try again.',
        isLoading: false,
      );
      debugPrint('❌ Unexpected error while fetching bursaries: $e');
    }
  }

  bool _hasLocalFilters() =>
      state.currentAmount > 0 || state.activeQuickFilters.contains('Open Now');

  String _formatNumberWithCommas(int number) {
    final str = number.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) buffer.write(',');
    }
    return buffer.toString().split('').reversed.join('');
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    debugPrint('🧹 Disposing Bursary Notifier - cleanup complete!');
    super.dispose();
  }
}

// Provider definition
final bursaryFinderProvider =
    StateNotifierProvider<BursaryFinderNotifier, BursaryFinderState>(
      (ref) => BursaryFinderNotifier(),
    );
