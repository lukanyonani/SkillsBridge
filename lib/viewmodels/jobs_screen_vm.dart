import 'package:flutter/material.dart';

class JobsScreenViewModel extends ChangeNotifier {
  int _savedJobsCount = 3;
  String _searchQuery = '';
  String _locationQuery = 'Cape Town';
  String _sortOption = 'Relevance';
  int _jobsCount = 123;

  final Set<String> _activeFilters = {'All Jobs'};
  final Set<int> _savedJobs = {2}; // Third job is saved by default

  bool _showDetail = false;
  Map<String, dynamic>? _selectedJob;

  // Getters
  int get savedJobsCount => _savedJobsCount;
  String get searchQuery => _searchQuery;
  String get locationQuery => _locationQuery;
  String get sortOption => _sortOption;
  int get jobsCount => _jobsCount;
  Set<String> get activeFilters => _activeFilters;
  Set<int> get savedJobs => _savedJobs;
  bool get showDetail => _showDetail;
  Map<String, dynamic>? get selectedJob => _selectedJob;

  // Available locations for dropdown
  final List<String> availableLocations = [
    'Cape Town',
    'Johannesburg',
    'Durban',
    'Pretoria',
    'Port Elizabeth',
    'Bloemfontein',
    'East London',
    'Pietermaritzburg',
    'Remote',
    'Nationwide',
  ];

  // Available filter options
  final List<String> filterOptions = [
    'All Jobs',
    'Remote',
    'Entry Level',
    'Full-time',
    'Internship',
    'R10k-20k',
    'Tech',
    'This Week',
  ];

  // Sort options
  final List<String> sortOptions = [
    'Relevance',
    'Date Posted',
    'Salary',
    'Match Score',
  ];

  // Sample job data
  final List<Map<String, dynamic>> jobs = [
    {
      'id': 0,
      'title': 'Junior Software Developer',
      'company': 'TechCorp South Africa',
      'logo': '🏢',
      'logoColor': const Color(0xFFF3F4F6),
      'location': 'Cape Town, WC',
      'salary': 'R15,000 - R20,000',
      'type': 'Hybrid',
      'workType': 'Full-time',
      'tags': ['JavaScript', 'React'],
      'isNew': true,
      'matchScore': 85,
      'matchLevel': 'high',
    },
    {
      'id': 1,
      'title': 'IT Support Specialist',
      'company': 'First National Bank',
      'logo': '🏦',
      'logoColor': const Color(0xFFFEF3C7),
      'location': 'Johannesburg, GP',
      'salary': 'R12,000 - R18,000',
      'type': 'On-site',
      'workType': 'Full-time',
      'tags': ['Help Desk', 'Windows'],
      'isNew': false,
      'matchScore': 78,
      'matchLevel': 'high',
    },
    {
      'id': 2,
      'title': 'Digital Marketing Intern',
      'company': 'Takealot.com',
      'logo': '📱',
      'logoColor': const Color(0xFFD1FAE5),
      'location': 'Cape Town, WC',
      'salary': 'R8,000 - R10,000',
      'type': 'Hybrid',
      'workType': 'Internship',
      'tags': ['Social Media', 'SEO'],
      'isNew': false,
      'matchScore': 72,
      'matchLevel': 'medium',
    },
    {
      'id': 3,
      'title': 'Data Analyst',
      'company': 'Discovery Limited',
      'logo': '📊',
      'logoColor': const Color(0xFFFEE2E2),
      'location': 'Sandton, GP',
      'salary': 'R25,000 - R35,000',
      'type': 'On-site',
      'workType': 'Full-time',
      'tags': ['SQL', 'Python', 'Excel'],
      'isNew': false,
      'matchScore': 68,
      'matchLevel': 'medium',
    },
    {
      'id': 4,
      'title': 'Full Stack Developer',
      'company': 'Afrihost',
      'logo': '💻',
      'logoColor': const Color(0xFFE0E7FF),
      'location': 'Remote',
      'salary': 'R30,000 - R45,000',
      'type': 'Remote',
      'workType': 'Full-time',
      'tags': ['Node.js', 'React', 'MongoDB'],
      'isNew': false,
      'matchScore': 62,
      'matchLevel': 'low',
    },
  ];

  // Methods
  void updateSearchQuery(String query) {
    _searchQuery = query;
    _updateJobsCount();
    notifyListeners();
  }

  void updateLocationQuery(String location) {
    _locationQuery = location;
    notifyListeners();
  }

  void updateSortOption(String option) {
    _sortOption = option;
    notifyListeners();
  }

  void toggleFilter(String filter) {
    if (filter == 'All Jobs') {
      _activeFilters.clear();
      _activeFilters.add('All Jobs');
    } else {
      _activeFilters.remove('All Jobs');
      if (_activeFilters.contains(filter)) {
        _activeFilters.remove(filter);
        if (_activeFilters.isEmpty) {
          _activeFilters.add('All Jobs');
        }
      } else {
        _activeFilters.add(filter);
      }
    }
    _updateJobsCount();
    notifyListeners();
  }

  void toggleSaveJob(int jobId) {
    if (_savedJobs.contains(jobId)) {
      _savedJobs.remove(jobId);
      _savedJobsCount--;
    } else {
      _savedJobs.add(jobId);
      _savedJobsCount++;
    }
    notifyListeners();
  }

  void selectJob(Map<String, dynamic> job) {
    _selectedJob = job;
    _showDetail = true;
    notifyListeners();
  }

  void goBackToJobList() {
    _showDetail = false;
    _selectedJob = null;
    notifyListeners();
  }

  void _updateJobsCount() {
    if (_searchQuery.isNotEmpty) {
      _jobsCount = 10 + (_searchQuery.length * 5);
    } else {
      _jobsCount = 123 - (_activeFilters.length * 15);
    }
    _jobsCount = _jobsCount.clamp(10, 200);
  }

  bool isJobSaved(int jobId) {
    return _savedJobs.contains(jobId);
  }

  bool isFilterActive(String filter) {
    return _activeFilters.contains(filter);
  }

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

  List<Map<String, dynamic>> getSimilarJobs() {
    return [
      {
        'title': 'Frontend Developer',
        'company': 'Digital Agency',
        'location': 'Cape Town',
        'salary': 'R18k-25k',
        'match': 82,
      },
      {
        'title': 'Junior Web Developer',
        'company': 'StartupSA',
        'location': 'Remote',
        'salary': 'R14k-18k',
        'match': 79,
      },
      {
        'title': 'Graduate Developer Programme',
        'company': 'Standard Bank',
        'location': 'Johannesburg',
        'salary': 'R20k-25k',
        'match': 75,
      },
    ];
  }

  List<Map<String, String>> getJobRequirements() {
    return [
      {
        'text': 'Bachelor\'s degree in Computer Science, IT, or related field',
        'status': 'met',
      },
      {
        'text':
            'Basic knowledge of JavaScript and modern frameworks (React/Vue/Angular)',
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
      {
        'text': 'Knowledge of SQL and database concepts (training provided)',
        'status': 'unmet',
      },
      {'text': 'Excellent communication skills in English', 'status': 'met'},
      {
        'text': 'South African citizenship or valid work permit',
        'status': 'met',
      },
    ];
  }

  List<Map<String, dynamic>> getSkillsRequired() {
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

  String getJobDescription() {
    return 'We\'re looking for a passionate Junior Software Developer to join our growing team in Cape Town. This is an excellent opportunity for a recent graduate or someone with 0-2 years of experience to kick-start their career in tech.\n\nYou\'ll work alongside senior developers on exciting projects for South African and international clients, using modern technologies and best practices. We offer mentorship, continuous learning opportunities, and a clear path for career growth.\n\nOur hybrid work model allows for flexibility while maintaining team collaboration. You\'ll spend 2-3 days in our modern Cape Town office and the rest working from home.';
  }

  String getJobBenefits() {
    return '• Competitive salary: R15,000 - R20,000 per month\n• Medical aid contribution\n• Annual performance bonus\n• Flexible hybrid working arrangement\n• Professional development budget\n• Mentorship from senior developers\n• Modern office in Cape Town CBD\n• Team building events and hackathons\n• Clear career progression path';
  }
}
