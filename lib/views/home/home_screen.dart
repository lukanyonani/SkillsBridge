import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillsbridge/constants/theme.dart';
import 'package:skillsbridge/models/course_models.dart';
import 'package:skillsbridge/viewmodels/bursary_screen_vm.dart';
import 'package:skillsbridge/viewmodels/home_screen_vm.dart';
import 'package:skillsbridge/viewmodels/jobs_screen_vm.dart';
import 'package:skillsbridge/viewmodels/learning_screen_vm.dart';
import 'package:skillsbridge/views/profile/profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late JobsScreenViewModel _jobsViewModel;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _jobsViewModel = JobsScreenViewModel();

    // Animation controllers for smooth transitions
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Initialize with delay for smooth animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeScreen();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _initializeScreen() async {
    if (!_isInitialized) {
      ref.read(homeScreenProvider.notifier).initialize();
      _fadeController.forward();
      _slideController.forward();
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeScreenProvider);
    final homeNotifier = ref.read(homeScreenProvider.notifier);
    final learningViewModel = ref.watch(learningHubViewModelProvider);

    return Scaffold(
      backgroundColor: AppTheme.surfaceWhite,
      body: RefreshIndicator(
        onRefresh: () => _handleRefresh(homeNotifier),
        color: const Color(0xFF2563EB),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeController,
                child: _buildHeader(homeState, homeNotifier),
              ),
            ),

            // Stats Cards
            SliverToBoxAdapter(
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _slideController,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                child: _buildStatsCards(homeState, homeNotifier),
              ),
            ),

            // Continue Learning
            SliverToBoxAdapter(
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 0.4),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _slideController,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                child: _buildContinueLearning(homeState, homeNotifier),
              ),
            ),

            // Popular Courses
            SliverToBoxAdapter(
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 0.5),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _slideController,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                child: _buildPopularCourses(learningViewModel),
              ),
            ),

            // Recommended Jobs
            SliverToBoxAdapter(
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 0.6),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _slideController,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                child: _buildRecommendedJobs(homeState, homeNotifier),
              ),
            ),

            // Upcoming Deadlines
            SliverToBoxAdapter(
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 0.7),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _slideController,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                child: _buildUpcomingDeadlines(homeState, homeNotifier),
              ),
            ),

            // Bottom spacing
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRefresh(HomeScreenNotifier homeNotifier) async {
    // Show loading animation
    _fadeController.reverse().then((_) {
      _fadeController.forward();
    });

    // Refresh all data
    await homeNotifier.refreshAllData();

    // Haptic feedback for better UX
    //HapticFeedback.lightImpact();
  }

  Widget _buildHeader(
    HomeScreenState homeState,
    HomeScreenNotifier homeNotifier,
  ) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Animated greeting that changes based on time
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        homeState.greeting,
                        key: ValueKey(homeState.greeting),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      '${homeState.userName}! 👋',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ready to continue your journey?',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _buildProfileAvatar(),
              const SizedBox(width: 32),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      ),
      child: AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 150),
        child: Stack(
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/profile.jpeg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Center(
                  child: Text('✏️', style: TextStyle(fontSize: 8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(
    HomeScreenState homeState,
    HomeScreenNotifier homeNotifier,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 28,
        children: [
          _buildStatCard(
            icon: '📚',
            value: homeState.userStats['coursesAvailable'].toString(),
            label: 'Courses Available',
            bgColor: const Color(0xFFDBEAFE),
            iconColor: const Color(0xFF2563EB),
            isLoading: homeState.isLoading,
            onTap: () => homeNotifier.onStatCardTapped('courses'),
          ),
          _buildStatCard(
            icon: '💼',
            value: homeState.userStats['jobsAvailable'].toString(),
            label: 'Jobs Available',
            bgColor: const Color(0xFFFEF3C7),
            iconColor: const Color(0xFFF59E0B),
            isLoading: homeState.isLoading,
            onTap: () => homeNotifier.onStatCardTapped('jobs'),
          ),
          _buildStatCard(
            icon: '💡',
            value: homeState.userStats['bursariesAvailable'].toString(),
            label: 'Bursaries Available',
            bgColor: const Color(0xFFD1FAE5),
            iconColor: const Color(0xFF10B981),
            isLoading: homeState.isLoading,
            onTap: () => homeNotifier.onStatCardTapped('bursaries'),
          ),
          _buildStatCard(
            icon: '📝',
            value: homeState.userStats['applications'].toString(),
            label: 'Achievements',
            bgColor: const Color(0xFFFEE2E2),
            iconColor: const Color(0xFFEF4444),
            isLoading: false, // This doesn't load from API
            onTap: () => homeNotifier.onStatCardTapped('applications'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String icon,
    required String value,
    required String label,
    required Color bgColor,
    required Color iconColor,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: isLoading
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                        ),
                      )
                    : Text(icon, style: const TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: isLoading
                  ? Container(
                      key: const ValueKey('loading'),
                      width: 40,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )
                  : Text(
                      value,
                      key: ValueKey(value),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueLearning(
    HomeScreenState homeState,
    HomeScreenNotifier homeNotifier,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Row(
            children: [
              Text(
                'Continue Learning',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: homeNotifier.onContinueCourseTapped,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFDBEAFE)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            homeState.currentCourse['icon'],
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              homeState.currentCourse['title'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${homeState.currentCourse['module']} • ${homeState.currentCourse['timeLeft']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: const Color(0xFF4B5563).withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      tween: Tween(
                        begin: 0,
                        end: homeState.currentCourse['progress'],
                      ),
                      builder: (context, value, child) {
                        return LinearProgressIndicator(
                          value: value,
                          minHeight: 8,
                          backgroundColor: Colors.white,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF2563EB),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${homeState.getProgressPercentage()} Complete',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF4B5563).withOpacity(0.8),
                        ),
                      ),
                      const Text(
                        'Resume →',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularCourses(LearningHubViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Popular Courses',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to courses page
                },
                child: const Text(
                  'See all →',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: viewModel.isLoading
                ? _buildCoursesLoadingSkeleton()
                : viewModel.errorMessage != null
                ? _buildCoursesError(viewModel)
                : _buildCoursesList(viewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesLoadingSkeleton() {
    return SizedBox(
      height: 235,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 200,
            margin: const EdgeInsets.only(right: 12),
            child: _buildCourseCardSkeleton(),
          );
        },
      ),
    );
  }

  Widget _buildCourseCardSkeleton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 140,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 80,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 40,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      width: 30,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesError(LearningHubViewModel viewModel) {
    return SizedBox(
      height: 235,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Failed to load courses',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                // Retry loading courses
                //ref.read(learningHubViewModelProvider.notifier).loadCourses();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursesList(LearningHubViewModel viewModel) {
    final courses = viewModel.popularCourses;

    if (courses.isEmpty) {
      return SizedBox(
        height: 235,
        child: const Center(
          child: Text(
            'No courses available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return SizedBox(
      height: 235,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: courses.length,
        itemBuilder: (context, index) {
          return Container(
            width: 200,
            margin: const EdgeInsets.only(right: 12),
            child: _buildCourseCard(courses[index], viewModel),
          );
        },
      ),
    );
  }

  Widget _buildCourseCard(Course course, LearningHubViewModel viewModel) {
    return GestureDetector(
      onTap: () {
        // Navigate to course detail
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFDBEAFE), Color(0xFF3B82F6)],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: const Center(
                child: Text('📚', style: TextStyle(fontSize: 48)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'SkillsBridge',
                    style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text('⭐', style: TextStyle(fontSize: 12)),
                          SizedBox(width: 4),
                          Text('4.5', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      Text(
                        'Free',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF10B981),
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

  Widget _buildRecommendedJobs(
    HomeScreenState homeState,
    HomeScreenNotifier homeNotifier,
  ) {
    return Container(
      padding: const EdgeInsets.only(left: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Job Oppertunities',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Row(
                  children: [
                    if (homeState.isLoading)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        homeNotifier.onSeeAllTapped('jobs');
                      },
                      child: const Text(
                        'View all →',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: homeState.recommendedJobs.isEmpty && homeState.isLoading
                ? _buildJobsLoadingSkeleton()
                : _buildJobsList(homeState, homeNotifier),
          ),
        ],
      ),
    );
  }

  Widget _buildJobsLoadingSkeleton() {
    return SizedBox(
      height: 210,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(right: 20),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 12),
            child: _buildJobCardSkeleton(),
          );
        },
      ),
    );
  }

  Widget _buildJobCardSkeleton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 150,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 100,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 80,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 60,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJobsList(
    HomeScreenState homeState,
    HomeScreenNotifier homeNotifier,
  ) {
    if (homeState.recommendedJobs.isEmpty && !homeState.isLoading) {
      return Container(
        height: 210,
        padding: const EdgeInsets.only(right: 20),
        child: const Center(
          child: Text(
            'No jobs available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return SizedBox(
      height: 210,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(right: 20),
        itemCount: homeState.recommendedJobs.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final job = homeState.recommendedJobs[index];
          return _buildJobCard(job, homeNotifier);
        },
      ),
    );
  }

  Widget _buildJobCard(
    Map<String, dynamic> job,
    HomeScreenNotifier homeNotifier,
  ) {
    return GestureDetector(
      onTap: () => homeNotifier.onJobCardTapped(job),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 280,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      job['companyLogo'],
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job['jobTitle'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job['companyName'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildJobTag(job['location']),
                _buildJobTag(job['salary']),
                _buildJobTag(job['workType']),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF34D399)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${job['matchPercentage']} Match',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, color: Color(0xFF4B5563)),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  Widget _buildUpcomingDeadlines(
    HomeScreenState homeState,
    HomeScreenNotifier homeNotifier,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Upcoming Bursary Deadlines',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  if (homeState.hasUrgentDeadlines()) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${homeState.getUrgentDeadlinesCount()}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              TextButton(
                onPressed: () => homeNotifier.onSeeAllTapped('deadlines'),
                child: const Text(
                  'View all →',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: homeState.upcomingDeadlines.isEmpty && homeState.isLoading
                ? _buildDeadlinesLoadingSkeleton()
                : _buildDeadlinesList(homeState, homeNotifier),
          ),
        ],
      ),
    );
  }

  Widget _buildDeadlinesLoadingSkeleton() {
    return Column(
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 200,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 120,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 100,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 80,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDeadlinesList(
    HomeScreenState homeState,
    HomeScreenNotifier homeNotifier,
  ) {
    if (homeState.upcomingDeadlines.isEmpty && !homeState.isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: const Center(
          child: Text(
            'No upcoming deadlines',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      children: homeState.upcomingDeadlines.asMap().entries.map((entry) {
        final index = entry.key;
        final deadline = entry.value;
        return AnimatedContainer(
          duration: Duration(milliseconds: 200 + (index * 50)),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.only(bottom: 12),
          child: _buildBursaryCard(deadline, homeNotifier),
        );
      }).toList(),
    );
  }

  Widget _buildBursaryCard(
    Map<String, dynamic> bursary,
    HomeScreenNotifier homeNotifier,
  ) {
    return GestureDetector(
      onTap: () => homeNotifier.onBursaryCardTapped(bursary),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: bursary['isUrgent']
                ? const Color(0xFFEF4444).withOpacity(0.3)
                : const Color(0xFFE5E7EB),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bursary['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    bursary['amount'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (bursary['isUrgent'])
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                        ),
                      Expanded(
                        child: Text(
                          bursary['deadline'],
                          style: TextStyle(
                            fontSize: 12,
                            color: bursary['isUrgent']
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF6B7280),
                            fontWeight: bursary['isUrgent']
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () => homeNotifier.onApplyNowTapped(bursary['title']),
              style: ElevatedButton.styleFrom(
                backgroundColor: bursary['isUrgent']
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                bursary['isUrgent'] ? 'Apply ASAP' : 'Apply Now',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
