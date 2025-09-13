import 'package:flutter/material.dart';
import 'package:skillsbridge/data/sample.dart';
import 'package:skillsbridge/models/course_model.dart';

class LearningScreenViewModel extends ChangeNotifier {
  int _currentNavIndex = 1; // Learn tab is active
  int _selectedCategoryIndex = 0;
  List<String> _activeFilters = ['All Levels'];
  String _searchQuery = '';

  // Course detail state
  bool _isEnrolled = false;
  List<bool> _expandedSections = [false, false, false, false];

  // Getters
  int get currentNavIndex => _currentNavIndex;
  int get selectedCategoryIndex => _selectedCategoryIndex;
  List<String> get activeFilters => _activeFilters;
  String get searchQuery => _searchQuery;
  bool get isEnrolled => _isEnrolled;
  List<bool> get expandedSections => _expandedSections;

  Map<String, dynamic> get apiFeaturedCourse => SampleData.featuredCourse;
  List<Map<String, dynamic>> get apiPopularCourses => SampleData.popularCourses;
  List<String> get apiCategories => SampleData.categories;

  final List<String> categories = [
    'All',
    'Science',
    'Engineering',
    'Mathematics',
    'Physics',
    'Social Science',
    'Computer Science',
    'Differential Equations',
    'Linear Algebra',
    'Chemistry',
    'Systems Engineering',
    'Business',
    'Classical Mechanics',
    'Electrical Engineering',
    'Biology',
    'Calculus',
    'Economics',
    'Probability and Statistics',
    'Mechanical Engineering',
    'Applied Mathematics',
    'Quantum Mechanics',
    'Algorithms and Data Structures',
    'Chemical Engineering',
    'Materials Science and Engineering',
    'Solid Mechanics',
    'Health and Medicine',
    'Psychology',
    'Cognitive Science',
    'Digital Systems',
    'Discrete Mathematics',
    'Energy',
    'Atomic, Molecular, Optical Physics',
    'Signal Processing',
    'Physical Chemistry',
    'Biochemistry',
    'Computation',
    'Artificial Intelligence',
    'Project Management',
    'Thermodynamics',
    'Theory of Computation',
    'Computational Science and Engineering',
    'Fine Arts',
    'Microeconomics',
    'Telecommunications',
    'Public Health',
    'Aerospace Engineering',
    'Particle Physics',
    'Innovation',
    'Software Design and Engineering',
    'Theoretical Physics',
    'Systems Optimization',
    'Health Care Management',
    'Biological Engineering',
    'Finance',
    'Mathematical Analysis',
    'Electricity',
    'Humanities',
    'Renewables',
    'Society',
    'Computer Networks',
    'Developmental Economics',
    'Cell Biology',
    'Computational Modeling and Simulation',
    'Structural Biology',
    'Nuclear Physics',
    'Transport Processes',
    'Community Development',
    'Cryptography',
    'Digital Media',
    'Electronics',
    'Media Studies',
    'Sociology',
    'Nanotechnology',
    'Leadership',
    'Organic Chemistry',
    'Neuroscience',
    'Sensory-Neural Systems',
    'Operations Management',
    'Organizational Behavior',
    'Graphics and Visualization',
    'Programming Languages',
    'Relativity',
    'Information Technology',
    'Public Administration',
    'Robotics and Control Systems',
    'Systems Design',
    'Entrepreneurship',
    'Macroeconomics',
    'Econometrics',
    'Electromagnetism',
    'Computation and Systems Biology',
    'Urban Studies',
    'Genetics',
    'Microtechnology',
    'Molecular Biology',
    'Process Control Systems',
    'Globalization',
    'Nuclear Engineering',
    'Computational Biology',
    'Astrophysics',
    'Electric Power',
    'Electronic Materials',
    'Cancer',
    'Fossil Fuels',
    'Functional Genomics',
    'Inorganic Chemistry',
    'Microbiology',
    'Virology',
    'Game Design',
    'History',
    'History of Science and Technology',
    'Modern History',
    'International Development',
    'Financial Economics',
    'Combustion',
    'Fluid Mechanics',
    'Architectural Design',
    'Architecture',
    'Condensed Matter Physics',
    'Industrial Organization',
    'Linguistics',
    'Film and Video',
    'Human-Computer Interfaces',
    'Medical Imaging',
    'Visual Arts',
    'Public Economics',
    'Synthetic Biology',
    'Anatomy and Physiology',
    'Neurobiology',
    'Computer Design and Engineering',
    'Global Poverty',
    'Social Welfare',
    'International Economics',
    'Science and Technology Policy',
    'Biomedical Signal and Image Processing',
    'Biophysics',
    'Data Mining',
    'Cell and Tissue Engineering',
    'Urban Planning',
    'Environmental Engineering',
    'Language',
    'Analytical Chemistry',
    'Management',
    'Buildings',
    'Earth Science',
    'Real Estate',
    'Sustainability',
    'Japanese',
    'Teaching and Education',
    'American History',
    'Developmental Biology',
    'Higher Education',
    'Hydrogen and Alternatives',
    'Nuclear',
    'Nuclear Systems, Policy, and Economics',
    'Climate',
    'Environmental Management',
    'Environmental Policy',
    'Fiction',
    'Literature',
    'Periodic Literature',
    'Communication',
    'Music',
    'Music History',
    'Music Performance',
    'Music Theory',
    'Regional Planning',
    'Biomedical Enterprise',
    'Latin and Caribbean Studies',
    'Spectroscopy',
    'Curriculum and Teaching',
    'Educational Technology',
  ];

  final List<String> filterOptions = [
    'All Levels',
    'Undergraduate',
    'Graduate',
    'High School',
  ];

  // Featured course data
  Map<String, dynamic> get selectedCourse => {
    'image':
        'https://ocw.mit.edu/courses/4-241j-theory-of-city-form-spring-2013/121f278b7066ebae182261855776df1e_4-241js13.jpg',

    'title': 'Theory of City Form',
    'instructors': 'Prof. Julian Beinart',
    'courseDescription':
        'This course covers theories about the form that settlements should take and attempts a distinction between descriptive and normative theory by examining examples of various theories of city form over time. Case studies will highlight the origins of the modern city and theories about its emerging form, including the transformation of the nineteenth-century city and its organization. Through examples and historical context, current issues of city form in relation to city-making, social structure, and physical design will also be discussed and analyzed.',
    'category': 'Fine Arts',
    'lectures': [
      Lecture(name: 'Lec 1: Introduction', url: 'https://youtu.be/k2_wuThLG6o'),
    ],
    'numberOfVideos': '30 Lectures',
  };

  // Featured course data
  Map<String, dynamic> get featuredCourse => {
    'title': 'Complete Web Development Bootcamp',
    'provider': 'CodeSpace Academy',
    'rating': 4.8,
    'reviews': '2.3k',
    'duration': '40 hours',
    'type': 'Certificate',
    'price': 'Free',
    'description':
        'Master web development from scratch with this comprehensive bootcamp designed specifically for South African learners. Build real-world projects, learn industry best practices, and prepare for a career in tech.\n\nThis course covers everything from basic HTML to advanced full-stack development, with practical examples relevant to the South African job market.',
    'location': 'Cape Town',
    'enrolled': '12,450',
    'skills': ['HTML/CSS', 'JavaScript', 'React', 'Node.js', 'MongoDB', 'Git'],
  };

  // Popular courses data
  List<CourseCard> get popularCourses => [
    CourseCard(
      emoji: '🐍',
      title: 'Python for Data Science',
      provider: 'DataCamp',
      rating: 4.7,
      price: 'Free',
    ),
    CourseCard(
      emoji: '📱',
      title: 'Mobile App Development',
      provider: 'Google Africa',
      rating: 4.9,
      price: 'Free',
      gradient: [const Color(0xFFFEF3C7), const Color(0xFFF59E0B)],
    ),
    CourseCard(
      emoji: '💼',
      title: 'Digital Marketing Basics',
      provider: 'Facebook',
      rating: 4.6,
      price: 'Free',
      gradient: [const Color(0xFFD1FAE5), const Color(0xFF10B981)],
    ),
    CourseCard(
      emoji: '🎨',
      title: 'UI/UX Design Fundamentals',
      provider: 'Coursera',
      rating: 4.8,
      price: 'Free',
      gradient: [const Color(0xFFFEE2E2), const Color(0xFFEF4444)],
    ),
  ];

  List<CourseModel> get recentCourses => [
    CourseModel(
      title: 'Theory of City Form',
      image:
          'https://ocw.mit.edu/courses/4-241j-theory-of-city-form-spring-2013/121f278b7066ebae182261855776df1e_4-241js13.jpg',
      instructors: 'Prof. Julian Beinart',
      courseDescription:
          'This course covers theories about the form that settlements should take and attempts a distinction between descriptive and normative theory by examining examples of various theories of city form over time. Case studies will highlight the origins of the modern city and theories about its emerging form, including the transformation of the nineteenth-century city and its organization. Through examples and historical context, current issues of city form in relation to city-making, social structure, and physical design will also be discussed and analyzed.',
      category: 'Fine Arts',
      lectures: [
        Lecture(
          name: 'Lec 1: Introduction',
          url: 'https://youtu.be/k2_wuThLG6o',
        ),
      ],
    ),
  ];

  // All courses data
  List<ListCourse> get allCourses => [
    ListCourse(
      emoji: '🔐',
      title: 'Cybersecurity Essentials',
      provider: 'Cisco Networking Academy',
      category: 'Software',
      duration: '30 videos',
      type: 'Certificate',
    ),
    ListCourse(
      emoji: '📊',
      title: 'Excel for Business Analysis',
      provider: 'Microsoft Learn',
      category: 'Technology',
      duration: '15 videos',
      type: 'Free',
      gradient: [const Color(0xFFE0E7FF), const Color(0xFF8B5CF6)],
    ),
    ListCourse(
      emoji: '💡',
      title: 'Entrepreneurship in South Africa',
      provider: 'UCT Online',
      category: 'Software',
      duration: '20 videos',
      type: 'R299',
      gradient: [const Color(0xFFFCE7F3), const Color(0xFFEC4899)],
    ),
    ListCourse(
      emoji: '🌐',
      title: 'Web3 and Blockchain Basics',
      provider: 'Binance Academy',
      category: 'Software',
      duration: '10 videos',
      type: 'Free',
      gradient: [const Color(0xFFCFFAFE), const Color(0xFF06B6D4)],
    ),
  ];

  // Syllabus modules
  List<SyllabusModule> get syllabusModules => [
    SyllabusModule(
      title: 'Module 1: Web Fundamentals',
      content:
          '• Introduction to the Web\n• HTML5 Basics and Semantics\n• CSS3 Styling and Layouts\n• Responsive Design Principles\n• Project: Build Your First Website',
    ),
    SyllabusModule(
      title: 'Module 2: JavaScript Programming',
      content:
          '• JavaScript Fundamentals\n• DOM Manipulation\n• ES6+ Features\n• Asynchronous JavaScript\n• Project: Interactive Web App',
    ),
    SyllabusModule(
      title: 'Module 3: React Development',
      content:
          '• React Components and Props\n• State Management\n• React Hooks\n• Routing and Navigation\n• Project: Build a React Application',
    ),
    SyllabusModule(
      title: 'Module 4: Backend with Node.js',
      content:
          '• Node.js and Express\n• RESTful APIs\n• Database Integration\n• Authentication & Security\n• Project: Full-Stack Application',
    ),
  ];

  // Related courses
  List<Map<String, dynamic>> get relatedCourses => [
    {
      'emoji': '⚛️',
      'title': 'Advanced React Patterns',
      'provider': 'Frontend Masters',
      'rating': 4.9,
      'duration': '15 hours',
      'price': 'R299',
    },
    {
      'emoji': '🔧',
      'title': 'Backend API Development',
      'provider': 'Udemy',
      'rating': 4.6,
      'duration': '25 hours',
      'price': 'Free',
    },
  ];

  // Methods
  void updateNavIndex(int index) {
    _currentNavIndex = index;
    notifyListeners();
  }

  void selectCategory(int index) {
    _selectedCategoryIndex = index;
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleFilter(String filter) {
    if (_activeFilters.contains(filter)) {
      _activeFilters.remove(filter);
    } else {
      _activeFilters.add(filter);
    }
    notifyListeners();
  }

  void addFilter(String filter) {
    if (!_activeFilters.contains(filter)) {
      _activeFilters.add(filter);
      notifyListeners();
    }
  }

  void removeFilter(String filter) {
    _activeFilters.remove(filter);
    notifyListeners();
  }

  void clearFilters() {
    _activeFilters.clear();
    _activeFilters.add('All Levels'); // Keep default filter
    notifyListeners();
  }

  bool isFilterActive(String filter) {
    return _activeFilters.contains(filter);
  }

  // Course detail methods
  void toggleEnrollment() {
    _isEnrolled = !_isEnrolled;
    notifyListeners();
  }

  void enrollInCourse() {
    _isEnrolled = true;
    notifyListeners();
  }

  void unenrollFromCourse() {
    _isEnrolled = false;
    notifyListeners();
  }

  void toggleSyllabusSection(int index) {
    if (index < _expandedSections.length) {
      _expandedSections[index] = !_expandedSections[index];
      notifyListeners();
    }
  }

  void expandSyllabusSection(int index) {
    if (index < _expandedSections.length) {
      _expandedSections[index] = true;
      notifyListeners();
    }
  }

  void collapseSyllabusSection(int index) {
    if (index < _expandedSections.length) {
      _expandedSections[index] = false;
      notifyListeners();
    }
  }

  void collapseAllSyllabusSections() {
    _expandedSections = List.filled(_expandedSections.length, false);
    notifyListeners();
  }

  void expandAllSyllabusSections() {
    _expandedSections = List.filled(_expandedSections.length, true);
    notifyListeners();
  }

  bool isSyllabusSectionExpanded(int index) {
    return index < _expandedSections.length ? _expandedSections[index] : false;
  }

  // Filtered courses based on search and active filters
  List<CourseCard> get filteredPopularCourses {
    List<CourseCard> courses = popularCourses;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      courses = courses.where((course) {
        return course.title.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            course.provider.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply active filters
    for (String filter in _activeFilters) {
      switch (filter) {
        case 'Free':
          courses = courses.where((course) => course.price == 'Free').toList();
          break;
        case 'Certificate':
          // Add certificate logic if needed
          break;
        case '< 10 hours':
          // Add duration logic if needed
          break;
        case 'Beginner':
          // Add difficulty logic if needed
          break;
        // Add more filter cases as needed
      }
    }

    return courses;
  }

  List<ListCourse> get filteredAllCourses {
    List<ListCourse> courses = allCourses;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      courses = courses.where((course) {
        return course.title.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            course.provider.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply active filters
    for (String filter in _activeFilters) {
      switch (filter) {
        case 'Free':
          courses = courses.where((course) => course.type == 'Free').toList();
          break;
        case 'Certificate':
          courses = courses
              .where((course) => course.type == 'Certificate')
              .toList();
          break;
        case '< 10 hours':
          courses = courses.where((course) {
            // Extract hours from duration string and compare
            final hours = int.tryParse(course.duration.split(' ')[0]) ?? 0;
            return hours < 10;
          }).toList();
          break;
        // Add more filter cases as needed
      }
    }

    return courses;
  }

  // Reset all state (useful for testing or when leaving the screen)
  void reset() {
    _currentNavIndex = 1;
    _selectedCategoryIndex = 0;
    _activeFilters = ['All Levels'];
    _searchQuery = '';
    _isEnrolled = false;
    _expandedSections = [false, false, false, false];
    notifyListeners();
  }
}

// Data Models (same as before but moved here for better organization)
class CourseCard {
  final String emoji;
  final String title;
  final String provider;
  final double rating;
  final String price;
  final List<Color>? gradient;

  CourseCard({
    required this.emoji,
    required this.title,
    required this.provider,
    required this.rating,
    required this.price,
    this.gradient,
  });
}

class ListCourse {
  final String emoji;
  final String title;
  final String provider;
  final String category;
  final String duration;
  final String type;
  final List<Color>? gradient;

  ListCourse({
    required this.emoji,
    required this.title,
    required this.provider,
    required this.category,
    required this.duration,
    required this.type,
    this.gradient,
  });
}

class SyllabusModule {
  final String title;
  final String content;

  SyllabusModule({required this.title, required this.content});
}
