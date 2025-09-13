import 'package:flutter/material.dart';

class BursaryFinderViewModel extends ChangeNotifier {
  // Filter and search state
  double _currentAmount = 50000;
  int _savedCount = 5;
  String _selectedField = 'All Fields';
  String _sortOption = 'Deadline ↑';
  int _resultsCount = 47;
  final Set<String> _activeFilters = {'All'};
  final Set<int> _savedBursaries = {1}; // Allan Gray is saved by default
  String _searchQuery = '';

  // Available filter options
  final List<String> _fieldOptions = [
    'All Fields',
    'Computer Science & IT',
    'Engineering',
    'Business & Commerce',
    'Medicine & Health Sciences',
    'Education',
    'Law',
    'Arts & Humanities',
    'Science & Mathematics',
    'Agriculture',
  ];

  final List<String> _quickFilterOptions = [
    'All',
    'Full Funding',
    'Partial',
    'Merit-based',
    'Need-based',
    'Women',
    'Postgrad',
  ];

  final List<String> _sortOptions = [
    'Deadline ↑',
    'Amount ↓',
    'Match Score',
    'Recently Added',
  ];

  // Bursary data
  final List<BursaryData> _bursaryList = [
    BursaryData(
      id: 0,
      provider: 'National Student Financial Aid Scheme',
      title: 'NSFAS Comprehensive Student Funding',
      amount: 'Up to R90,000',
      deadline: 'Closes in 2 days',
      isUrgent: true,
      level: 'Undergraduate',
      location: 'All SA Universities',
      eligibility: [
        EligibilityItem('South African citizen', EligibilityStatus.met),
        EligibilityItem('Household income < R350,000', EligibilityStatus.met),
        EligibilityItem(
          'Academic record (60%+ average)',
          EligibilityStatus.partial,
        ),
      ],
      tags: ['Full Funding', 'Living Allowance', 'Popular'],
    ),
    BursaryData(
      id: 1,
      provider: 'Allan Gray Orbis Foundation',
      title: 'Fellowship Programme',
      amount: 'R150,000+',
      deadline: 'Closes in 15 days',
      isUrgent: false,
      level: 'All Levels',
      location: 'Entrepreneurship Focus',
      eligibility: [
        EligibilityItem('Academic excellence (75%+)', EligibilityStatus.met),
        EligibilityItem('Leadership potential', EligibilityStatus.met),
        EligibilityItem('Entrepreneurial mindset', EligibilityStatus.met),
      ],
      tags: ['Full Funding', 'Mentorship', 'Prestigious'],
    ),
    BursaryData(
      id: 2,
      provider: 'Sasol',
      title: 'Science & Engineering Bursary',
      amount: 'R120,000',
      deadline: 'Closes in 21 days',
      isUrgent: false,
      level: 'Undergraduate',
      location: 'STEM Fields',
      eligibility: [
        EligibilityItem('Mathematics 70%+', EligibilityStatus.met),
        EligibilityItem('Physical Science 70%+', EligibilityStatus.notMet),
        EligibilityItem('Engineering/Science student', EligibilityStatus.met),
      ],
      tags: ['Work-back Agreement', 'Vacation Work'],
    ),
    BursaryData(
      id: 3,
      provider: 'Google South Africa',
      title: 'Career Certificates Scholarship',
      amount: 'Full Course Funding',
      deadline: 'Closes in 5 days',
      isUrgent: true,
      level: 'Online Learning',
      location: 'Tech Skills',
      eligibility: [
        EligibilityItem('18+ years old', EligibilityStatus.met),
        EligibilityItem('Interest in tech', EligibilityStatus.met),
        EligibilityItem('Committed to 3-6 months', EligibilityStatus.met),
      ],
      tags: ['New', 'No Experience Required', 'Certificate'],
    ),
  ];

  // Getters
  double get currentAmount => _currentAmount;
  int get savedCount => _savedCount;
  String get selectedField => _selectedField;
  String get sortOption => _sortOption;
  int get resultsCount => _resultsCount;
  Set<String> get activeFilters => _activeFilters;
  Set<int> get savedBursaries => _savedBursaries;
  String get searchQuery => _searchQuery;
  List<String> get fieldOptions => _fieldOptions;
  List<String> get quickFilterOptions => _quickFilterOptions;
  List<String> get sortOptions => _sortOptions;
  List<BursaryData> get bursaryList => _bursaryList;

  // Initialize the view model
  void initialize() {
    _updateResults();
  }

  // Update search query
  void updateSearchQuery(String query) {
    _searchQuery = query;
    _updateResults();
    notifyListeners();
  }

  // Update amount slider
  void updateAmount(double amount) {
    _currentAmount = amount;
    _updateResults();
    notifyListeners();
  }

  // Set preset amount
  void setPresetAmount(double amount) {
    _currentAmount = amount;
    _updateResults();
    notifyListeners();
  }

  // Update field of study
  void updateField(String field) {
    _selectedField = field;
    _updateResults();
    notifyListeners();
  }

  // Toggle quick filter
  void toggleQuickFilter(String filter) {
    if (filter == 'All') {
      _activeFilters.clear();
      _activeFilters.add('All');
    } else {
      _activeFilters.remove('All');
      if (_activeFilters.contains(filter)) {
        _activeFilters.remove(filter);
        if (_activeFilters.isEmpty) {
          _activeFilters.add('All');
        }
      } else {
        _activeFilters.add(filter);
      }
    }
    _updateResults();
    notifyListeners();
  }

  // Update sort option
  void updateSortOption(String option) {
    _sortOption = option;
    // Here you would normally re-sort the bursary list
    notifyListeners();
  }

  // Toggle save bursary
  void toggleSaveBursary(int id) {
    if (_savedBursaries.contains(id)) {
      _savedBursaries.remove(id);
      _savedCount--;
    } else {
      _savedBursaries.add(id);
      _savedCount++;
    }
    notifyListeners();
  }

  // Check if bursary is saved
  bool isBursarySaved(int id) {
    return _savedBursaries.contains(id);
  }

  // Update results count based on filters
  void _updateResults() {
    _resultsCount = 47 - (_activeFilters.length - 1) * 8;
    if (_resultsCount < 5) _resultsCount = 5;
  }

  // Format amount for display
  String getFormattedAmount() {
    return 'R${_currentAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]!},')}';
  }

  // Get preset amount label
  String getPresetAmountLabel(double amount) {
    return 'R${(amount / 1000).toStringAsFixed(0)}k';
  }

  // Check if filter is active
  bool isFilterActive(String filter) {
    return _activeFilters.contains(filter);
  }

  // Get urgent bursaries count
  int getUrgentBursariesCount() {
    return _bursaryList.where((bursary) => bursary.isUrgent).length;
  }

  // Handle user interactions
  void onBookmarkTapped() {
    // Navigate to saved bursaries
    debugPrint('Bookmark tapped - $_savedCount saved bursaries');
  }

  void onNotificationTapped() {
    // Navigate to notifications
    debugPrint('Notifications tapped');
  }

  void onViewAllDeadlinesTapped() {
    // Navigate to urgent deadlines
    debugPrint('View all urgent deadlines tapped');
  }

  void onBursaryCardTapped(BursaryData bursary) {
    // Show bursary detail modal
    debugPrint('Bursary tapped: ${bursary.title}');
  }

  void onApplyNowTapped(BursaryData bursary) {
    // Handle apply now action
    debugPrint('Apply now tapped for: ${bursary.title}');
  }

  // Filter bursaries based on current filters
  List<BursaryData> getFilteredBursaries() {
    List<BursaryData> filtered = List.from(_bursaryList);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (bursary) =>
                bursary.title.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                bursary.provider.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                bursary.tags.any(
                  (tag) =>
                      tag.toLowerCase().contains(_searchQuery.toLowerCase()),
                ),
          )
          .toList();
    }

    // Apply amount filter
    // This would need more complex logic based on actual bursary amounts

    // Apply field filter
    if (_selectedField != 'All Fields') {
      // Filter based on field - would need field mapping in bursary data
    }

    // Apply quick filters
    if (!_activeFilters.contains('All')) {
      // Apply active filters - would need more detailed filtering logic
    }

    return filtered;
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// Data models
class BursaryData {
  final int id;
  final String provider;
  final String title;
  final String amount;
  final String deadline;
  final bool isUrgent;
  final String level;
  final String location;
  final List<EligibilityItem> eligibility;
  final List<String> tags;

  BursaryData({
    required this.id,
    required this.provider,
    required this.title,
    required this.amount,
    required this.deadline,
    required this.isUrgent,
    required this.level,
    required this.location,
    required this.eligibility,
    required this.tags,
  });
}

enum EligibilityStatus { met, partial, notMet }

class EligibilityItem {
  final String text;
  final EligibilityStatus status;

  EligibilityItem(this.text, this.status);
}
