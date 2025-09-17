import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillsbridge/models/course_models.dart';
import 'package:skillsbridge/viewmodels/learning_screen_vm.dart';

class CourseDetailScreen extends ConsumerStatefulWidget {
  final Course course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  ConsumerState<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _showAppBarTitle = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset > 200 && !_showAppBarTitle) {
      setState(() => _showAppBarTitle = true);
    } else if (_scrollController.offset <= 200 && _showAppBarTitle) {
      setState(() => _showAppBarTitle = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(learningHubViewModelProvider);

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildCourseHeader(),
                _buildTabSection(),
                _buildTabContent(viewModel),
                const SizedBox(height: 100), // Space for bottom button
              ],
            ),
          ),
        ],
      ),
      //bottomNavigationBar: _buildBottomEnrollSection(viewModel),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF2563EB),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.bookmark_border, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Course bookmarked!'),
                  backgroundColor: Color(0xFF10B981),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ),
      ],
      title: _showAppBarTitle
          ? Text(
              widget.course.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            )
          : null,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF2563EB),
                const Color(0xFF8B5CF6),
                Colors.purple.shade400,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Background pattern
              Positioned.fill(
                child: Opacity(
                  opacity: 0.1,
                  child: Container(
                    // decoration: const BoxDecoration(
                    //   image: DecorationImage(
                    //     image: AssetImage(
                    //       'assets/pattern.png',
                    //     ), // Add your pattern
                    //     repeat: ImageRepeat.repeat,
                    //   ),
                    // ),
                  ),
                ),
              ),
              // Play button
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Color(0xFF2563EB),
                    size: 40,
                  ),
                ),
              ),
              // Course category badge
              Positioned(
                bottom: 100,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.course.category.value ?? 'General',
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourseHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.course.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'by ${widget.course.instructor}',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),

          // Course stats row
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.star,
                  iconColor: Colors.amber,
                  value: widget.course.rating.toString(),
                  label: 'Rating',
                ),
                _buildStatItem(
                  icon: Icons.people,
                  iconColor: const Color(0xFF3B82F6),
                  value: '${widget.course.enrollmentCount}',
                  label: 'Students',
                ),
                _buildStatItem(
                  icon: Icons.access_time,
                  iconColor: const Color(0xFF10B981),
                  value: '30h',
                  label: 'Duration',
                ),
                _buildStatItem(
                  icon: Icons.trending_up,
                  iconColor: const Color(0xFF8B5CF6),
                  value: widget.course.level.value,
                  label: 'Level',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _buildTabSection() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: const Color(0xFF64748B),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'About'),
                Tab(text: 'Syllabus'),
                Tab(text: 'Reviews'),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTabContent(LearningHubViewModel viewModel) {
    return SizedBox(
      height: 600, // Fixed height for tab content
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildAboutTab(),
          _buildSyllabusTab(viewModel),
          _buildReviewsTab(),
        ],
      ),
    );
  }

  Widget _buildAboutTab() {
    return SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Course Description',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.course.description ??
                'This comprehensive course will take you through all the essential concepts and practical applications. You\'ll learn from industry experts and work on real-world projects that will enhance your skills and prepare you for success in your field.',
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 32),

          // What you'll learn section
          const Text(
            'What You\'ll Learn',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          ..._buildLearningPoints(),

          const SizedBox(height: 32),

          // Requirements section
          const Text(
            'Requirements',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          ..._buildRequirements(),
        ],
      ),
    );
  }

  List<Widget> _buildLearningPoints() {
    final points = [
      'Master the fundamental concepts and principles',
      'Apply knowledge to real-world scenarios',
      'Develop practical skills through hands-on projects',
      'Understand industry best practices and standards',
      'Build a portfolio of completed projects',
    ];

    return points
        .map(
          (point) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 12),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    point,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF374151),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  List<Widget> _buildRequirements() {
    final requirements = [
      'Basic computer literacy and internet access',
      'Motivation to learn and practice regularly',
      'No prior experience required - we\'ll start from the basics',
    ];

    return requirements
        .map(
          (req) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.fiber_manual_record,
                  color: Color(0xFF6B7280),
                  size: 8,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    req,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF374151),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  Widget _buildSyllabusTab(LearningHubViewModel viewModel) {
    final sections = [
      {
        'title': 'Introduction and Getting Started',
        'lessons': 5,
        'duration': '2h 30m',
        'description': 'Course overview, setup, and basic concepts',
      },
      {
        'title': 'Core Fundamentals',
        'lessons': 8,
        'duration': '4h 15m',
        'description': 'Essential principles and foundational knowledge',
      },
      {
        'title': 'Practical Applications',
        'lessons': 12,
        'duration': '8h 45m',
        'description': 'Hands-on projects and real-world examples',
      },
      {
        'title': 'Advanced Topics',
        'lessons': 7,
        'duration': '5h 20m',
        'description': 'Complex concepts and advanced techniques',
      },
      {
        'title': 'Final Project',
        'lessons': 4,
        'duration': '3h 30m',
        'description': 'Capstone project bringing everything together',
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: sections.asMap().entries.map((entry) {
          final index = entry.key;
          final section = entry.value;
          return _buildSyllabusSection(section, index, viewModel);
        }).toList(),
      ),
    );
  }

  Widget _buildSyllabusSection(
    Map<String, dynamic> section,
    int index,
    LearningHubViewModel viewModel,
  ) {
    final isExpanded = index < viewModel.expandedSections.length
        ? viewModel.expandedSections[index]
        : false;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => viewModel.toggleSyllabusSection(index),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Color(0xFF3B82F6),
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section['title'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${section['lessons']} lessons • ${section['duration']}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: const Color(0xFF6B7280),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 1,
                    color: const Color(0xFFE2E8F0),
                    margin: const EdgeInsets.only(bottom: 16),
                  ),
                  Text(
                    section['description'],
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF374151),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Sample lessons
                  ...List.generate(
                    3,
                    (lessonIndex) => _buildLessonItem(
                      'Lesson ${lessonIndex + 1}',
                      '${8 + lessonIndex}:30',
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLessonItem(String title, String duration) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.play_circle_outline,
            color: Color(0xFF3B82F6),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
            ),
          ),
          Text(
            duration,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rating summary
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Column(
                  children: [
                    Text(
                      widget.course.rating.toString(),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          Icons.star,
                          color: index < widget.course.rating.floor()
                              ? Colors.amber
                              : const Color(0xFFE5E7EB),
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.course.reviewCount} reviews',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: Column(
                    children: [
                      _buildRatingBar(5, 0.7),
                      _buildRatingBar(4, 0.2),
                      _buildRatingBar(3, 0.05),
                      _buildRatingBar(2, 0.03),
                      _buildRatingBar(1, 0.02),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Individual reviews
          const Text(
            'Student Reviews',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          ..._buildSampleReviews(),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int stars, double percentage) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$stars',
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.star, color: Colors.amber, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(percentage * 100).toInt()}%',
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSampleReviews() {
    final reviews = [
      {
        'name': 'Sarah Johnson',
        'rating': 5,
        'date': '2 days ago',
        'review':
            'Excellent course! The instructor explains complex concepts in a very clear and engaging way. The hands-on projects really helped solidify my understanding.',
      },
      {
        'name': 'Mike Chen',
        'rating': 4,
        'date': '1 week ago',
        'review':
            'Great content and well-structured lessons. I would have liked more advanced examples, but overall very satisfied with the learning experience.',
      },
      {
        'name': 'Emma Davis',
        'rating': 5,
        'date': '2 weeks ago',
        'review':
            'This course exceeded my expectations. The practical applications and real-world examples made it easy to understand and apply the concepts.',
      },
    ];

    return reviews
        .map(
          (review) => Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFF3B82F6),
                      child: Text(
                        "${review['name']!}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${review['name']!}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                          ),
                          Row(
                            children: [
                              Row(
                                children: List.generate(
                                  5,
                                  (index) => Icon(
                                    Icons.star,
                                    color: index < (review['rating'] as int)
                                        ? Colors.amber
                                        : const Color(0xFFE5E7EB),
                                    size: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "${review['date']!}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "${review['review']!}",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF374151),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  Widget _buildBottomEnrollSection(LearningHubViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.course.pricing.type == PricingType.free
                          ? 'FREE'
                          : '\$${widget.course.pricing.amount}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF10B981),
                      ),
                    ),
                    if (widget.course.pricing.type == PricingType.free)
                      const Text(
                        'Limited time offer',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: ElevatedButton(
                  onPressed: () {
                    viewModel.toggleEnrollment();
                    final message = viewModel.isEnrolled
                        ? 'Welcome to the course! Check your email for access details.'
                        : 'You have unenrolled from the course.';

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message),
                        backgroundColor: viewModel.isEnrolled
                            ? const Color(0xFF10B981)
                            : const Color(0xFF6B7280),
                        duration: const Duration(seconds: 3),
                        action: SnackBarAction(
                          label: 'View',
                          textColor: Colors.white,
                          onPressed: () {
                            // Navigate to enrolled courses or dashboard
                          },
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: viewModel.isEnrolled
                        ? const Color(0xFF10B981)
                        : const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        viewModel.isEnrolled
                            ? Icons.check_circle
                            : Icons.play_arrow,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        viewModel.isEnrolled ? 'Enrolled!' : 'Enroll Now',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
