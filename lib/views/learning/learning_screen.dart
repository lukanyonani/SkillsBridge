import 'package:flutter/material.dart';

class LearningHubScreen extends StatefulWidget {
  const LearningHubScreen({super.key});

  @override
  _LearningHubScreenState createState() => _LearningHubScreenState();
}

class _LearningHubScreenState extends State<LearningHubScreen> {
  int currentNavIndex = 1; // Learn tab is active
  int selectedCategoryIndex = 0;
  List<String> activeFilters = ['All Levels'];
  TextEditingController searchController = TextEditingController();

  final List<String> categories = [
    'All',
    'Technology',
    'Business',
    'Design',
    'Marketing',
    'Languages',
  ];

  final List<String> filterOptions = [
    'All Levels',
    'Free',
    'Certificate',
    '< 10 hours',
    'Beginner',
    'Online',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildCategoryTabs(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildFeaturedCourse(),
                    _buildPopularCourses(),
                    _buildAllCourses(),
                    SizedBox(height: 100), // Space for bottom nav
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      //bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          // Header top
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Learning Hub',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              Row(
                children: [
                  _buildIconButton('🔔'),
                  SizedBox(width: 12),
                  _buildIconButton('⚙️'),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),

          // Search bar
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search courses, skills, or topics...',
                prefixIcon: Icon(Icons.search, color: Color(0xFF9CA3AF)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          SizedBox(height: 12),

          // Filter pills
          Container(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filterOptions.length,
              itemBuilder: (context, index) {
                final filter = filterOptions[index];
                final isActive = activeFilters.contains(filter);
                return Container(
                  margin: EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isActive,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          activeFilters.add(filter);
                        } else {
                          activeFilters.remove(filter);
                        }
                      });
                    },
                    backgroundColor: Color(0xFFF3F4F6),
                    selectedColor: Color(0xFF2563EB),
                    labelStyle: TextStyle(
                      color: isActive ? Colors.white : Color(0xFF6B7280),
                      fontSize: 13,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(String emoji) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Center(child: Text(emoji, style: TextStyle(fontSize: 20))),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 20),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final isSelected = selectedCategoryIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategoryIndex = index;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    margin: EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected
                              ? Color(0xFF2563EB)
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Text(
                      categories[index],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Color(0xFF2563EB)
                            : Color(0xFF6B7280),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(height: 1, color: Color(0xFFE5E7EB)),
        ],
      ),
    );
  }

  Widget _buildFeaturedCourse() {
    return Container(
      margin: EdgeInsets.all(20),
      child: GestureDetector(
        onTap: () => _navigateToCourseDetail(),
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '🔥 FEATURED TODAY',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Complete Web Development Bootcamp',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'by CodeSpace Academy',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  _buildFeaturedStat('⭐', '4.8 (2.3k)'),
                  SizedBox(width: 16),
                  _buildFeaturedStat('⏱️', '40 hours'),
                  SizedBox(width: 16),
                  _buildFeaturedStat('🎓', 'Certificate'),
                  SizedBox(width: 16),
                  _buildFeaturedStat('💚', 'Free'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedStat(String icon, String text) {
    return Row(
      children: [
        Text(icon, style: TextStyle(fontSize: 13)),
        SizedBox(width: 4),
        Text(text, style: TextStyle(color: Colors.white, fontSize: 13)),
      ],
    );
  }

  Widget _buildPopularCourses() {
    final courses = [
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
        gradient: [Color(0xFFFEF3C7), Color(0xFFF59E0B)],
      ),
      CourseCard(
        emoji: '💼',
        title: 'Digital Marketing Basics',
        provider: 'Facebook',
        rating: 4.6,
        price: 'Free',
        gradient: [Color(0xFFD1FAE5), Color(0xFF10B981)],
      ),
      CourseCard(
        emoji: '🎨',
        title: 'UI/UX Design Fundamentals',
        provider: 'Coursera',
        rating: 4.8,
        price: 'R199',
        gradient: [Color(0xFFFEE2E2), Color(0xFFEF4444)],
      ),
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Popular Courses',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Text(
                'See all →',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2563EB),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: courses.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 200,
                  margin: EdgeInsets.only(right: 12),
                  child: _buildCourseCard(courses[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(CourseCard course) {
    return GestureDetector(
      onTap: () => _navigateToCourseDetail(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      course.gradient ?? [Color(0xFFDBEAFE), Color(0xFF3B82F6)],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Center(
                child: Text(course.emoji, style: TextStyle(fontSize: 48)),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    course.provider,
                    style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text('⭐', style: TextStyle(fontSize: 12)),
                          SizedBox(width: 4),
                          Text(
                            course.rating.toString(),
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      Text(
                        course.price,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: course.price == 'Free'
                              ? Color(0xFF10B981)
                              : Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllCourses() {
    final courses = [
      ListCourse(
        emoji: '🔐',
        title: 'Cybersecurity Essentials',
        provider: 'Cisco Networking Academy',
        rating: 4.7,
        duration: '30 hours',
        type: 'Certificate',
      ),
      ListCourse(
        emoji: '📊',
        title: 'Excel for Business Analysis',
        provider: 'Microsoft Learn',
        rating: 4.5,
        duration: '15 hours',
        type: 'Free',
        gradient: [Color(0xFFE0E7FF), Color(0xFF8B5CF6)],
      ),
      ListCourse(
        emoji: '💡',
        title: 'Entrepreneurship in South Africa',
        provider: 'UCT Online',
        rating: 4.9,
        duration: '20 hours',
        type: 'R299',
        gradient: [Color(0xFFFCE7F3), Color(0xFFEC4899)],
      ),
      ListCourse(
        emoji: '🌐',
        title: 'Web3 and Blockchain Basics',
        provider: 'Binance Academy',
        rating: 4.4,
        duration: '10 hours',
        type: 'Free',
        gradient: [Color(0xFFCFFAFE), Color(0xFF06B6D4)],
      ),
    ];

    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'All Courses',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Text(
                'Filter →',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2563EB),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...courses.map((course) => _buildCourseListItem(course)).toList(),
        ],
      ),
    );
  }

  Widget _buildCourseListItem(ListCourse course) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: GestureDetector(
        onTap: () => _navigateToCourseDetail(),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      course.gradient ?? [Color(0xFFF3F4F6), Color(0xFFE5E7EB)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(course.emoji, style: TextStyle(fontSize: 32)),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4),
                  Text(
                    course.provider,
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '⭐ ${course.rating}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                      Text(
                        ' • ${course.duration}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                      Text(
                        ' • ${course.type}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Color(0xFF2563EB), size: 20),
          ],
        ),
      ),
    );
  }

  void _navigateToCourseDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CourseDetailScreen()),
    );
  }
}

class CourseDetailScreen extends StatefulWidget {
  @override
  _CourseDetailScreenState createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  bool isEnrolled = false;
  List<bool> expandedSections = [false, false, false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeroSection(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildCourseInfo(),
                  _buildSyllabus(),
                  _buildRelatedCourses(),
                  SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildEnrollSection(),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2563EB), Color(0xFF8B5CF6)],
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 20,
              left: 20,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
            ),
            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Icon(
                  Icons.play_arrow,
                  color: Color(0xFF2563EB),
                  size: 32,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseInfo() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Complete Web Development Bootcamp',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 8),
          Text(
            'by CodeSpace Academy • Cape Town',
            style: TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
          ),
          SizedBox(height: 16),

          // Stats
          Container(
            padding: EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('⭐', '4.8 (2,342 reviews)'),
                _buildStat('👥', '12,450 enrolled'),
                _buildStat('⏱️', '40 hours'),
              ],
            ),
          ),
          SizedBox(height: 20),

          // Skills chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                ['HTML/CSS', 'JavaScript', 'React', 'Node.js', 'MongoDB', 'Git']
                    .map(
                      (skill) => Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFFDBEAFE),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          skill,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
          SizedBox(height: 20),

          // Description
          Text(
            'Master web development from scratch with this comprehensive bootcamp designed specifically for South African learners. Build real-world projects, learn industry best practices, and prepare for a career in tech.\n\nThis course covers everything from basic HTML to advanced full-stack development, with practical examples relevant to the South African job market.',
            style: TextStyle(
              fontSize: 14,
              //lineHeight: 1.6,
              color: Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String icon, String text) {
    return Column(
      children: [
        Text(icon, style: TextStyle(fontSize: 16)),
        SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSyllabus() {
    final modules = [
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

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Course Syllabus',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 16),
          ...modules.asMap().entries.map((entry) {
            final index = entry.key;
            final module = entry.value;
            return _buildSyllabusItem(module, index);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSyllabusItem(SyllabusModule module, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                expandedSections[index] = !expandedSections[index];
              });
            },
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      module.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: expandedSections[index] ? 0.5 : 0,
                    duration: Duration(milliseconds: 300),
                    child: Icon(Icons.keyboard_arrow_down, size: 20),
                  ),
                ],
              ),
            ),
          ),
          if (expandedSections[index])
            Container(
              padding: EdgeInsets.all(16),
              width: double.infinity,
              child: Text(
                module.content,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF4B5563),
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRelatedCourses() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Related Courses',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 16),
          _buildRelatedCourseItem(
            '⚛️',
            'Advanced React Patterns',
            'Frontend Masters',
            4.9,
            '15 hours',
            'R299',
          ),
          SizedBox(height: 12),
          _buildRelatedCourseItem(
            '🔧',
            'Backend API Development',
            'Udemy',
            4.6,
            '25 hours',
            'Free',
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedCourseItem(
    String emoji,
    String title,
    String provider,
    double rating,
    String duration,
    String price,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Text(emoji, style: TextStyle(fontSize: 24))),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text(
                  provider,
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '⭐ $rating',
                      style: TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
                    ),
                    Text(
                      ' • $duration',
                      style: TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
                    ),
                    Text(
                      ' • $price',
                      style: TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: Color(0xFF2563EB), size: 16),
        ],
      ),
    );
  }

  Widget _buildEnrollSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FREE',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  Text(
                    'Limited time offer',
                    style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isEnrolled = !isEnrolled;
                  });
                  if (isEnrolled) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Welcome to the course! Check your email for access details.',
                        ),
                        backgroundColor: Color(0xFF10B981),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEnrolled
                      ? Color(0xFF10B981)
                      : Color(0xFF2563EB),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isEnrolled ? 'Enrolled! ✓' : 'Enroll Now',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Data Models
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
  final double rating;
  final String duration;
  final String type;
  final List<Color>? gradient;

  ListCourse({
    required this.emoji,
    required this.title,
    required this.provider,
    required this.rating,
    required this.duration,
    required this.type,
    this.gradient,
  });
}

class BottomNavItem {
  final String icon;
  final String label;

  BottomNavItem({required this.icon, required this.label});
}

class SyllabusModule {
  final String title;
  final String content;

  SyllabusModule({required this.title, required this.content});
}
