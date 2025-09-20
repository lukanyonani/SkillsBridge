import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillsbridge/constants/theme.dart';
import 'package:skillsbridge/models/course_models.dart';
import 'package:skillsbridge/viewmodels/home/home_screen_vm.dart';
import 'package:skillsbridge/viewmodels/learning/learning_screen_vm.dart';
import 'package:skillsbridge/views/jobs/jobs_detail_screen.dart';
import 'package:skillsbridge/views/profile/profile_screen.dart';
import 'package:skillsbridge/views/learning/course_detail_screen.dart';
import 'dart:math' as math;

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _backgroundController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _backgroundAnimation;

  bool _isInitialized = false;
  late ScrollController _scrollController;
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeScreen();
    });
  }

  void _initializeAnimations() {
    // Fade animation for main content - faster
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    // Slide animation for content - faster
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    // Pulse animation for interactive elements - faster
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Background animation - faster
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 15000),
      vsync: this,
    );
    _backgroundAnimation = CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.linear,
    );
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _backgroundController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeScreen() async {
    if (!_isInitialized) {
      ref.read(homeScreenProvider.notifier).initialize();

      // Start animations - faster initialization
      _fadeController.forward();
      await Future.delayed(const Duration(milliseconds: 100));
      _slideController.forward();

      // Start continuous animations
      _pulseController.repeat(reverse: true);
      _backgroundController.repeat();

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
      body: Stack(
        children: [
          // Animated background
          _buildAnimatedBackground(),

          // Main content
          RefreshIndicator(
            onRefresh: () => _handleRefresh(homeNotifier),
            color: const Color(0xFF2563EB),
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              cacheExtent: 1000, // Cache more content for smoother scrolling
              slivers: [
                // Header with parallax effect
                SliverToBoxAdapter(
                  child: _buildParallaxHeader(homeState, homeNotifier),
                ),

                // Stats Cards (simplified - no animations)
                SliverToBoxAdapter(
                  child: _buildStatsCards(homeState, homeNotifier),
                ),

                // Continue Learning (simplified)
                SliverToBoxAdapter(
                  child: _buildContinueLearning(homeState, homeNotifier),
                ),

                // Popular Courses (simplified)
                SliverToBoxAdapter(
                  child: _buildPopularCourses(learningViewModel),
                ),

                // Recommended Jobs (simplified)
                SliverToBoxAdapter(
                  child: _buildRecommendedJobs(homeState, homeNotifier),
                ),

                // Upcoming Deadlines (simplified)
                SliverToBoxAdapter(
                  child: _buildUpcomingDeadlines(homeState, homeNotifier),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: FloatingParticlesPainter(_backgroundAnimation.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildParallaxHeader(
    HomeScreenState homeState,
    HomeScreenNotifier homeNotifier,
  ) {
    final parallaxOffset = _scrollOffset * 0.5;

    return Transform.translate(
      offset: Offset(0, -parallaxOffset),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          height: 200 + parallaxOffset.clamp(0, 50),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF2563EB).withValues(alpha: 0.9),
                const Color(0xFF3B82F6).withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Floating geometric shapes
              ..._buildFloatingShapes(),

              // Main header content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: SlideTransition(
                              position:
                                  Tween<Offset>(
                                    begin: const Offset(-1, 0),
                                    end: Offset.zero,
                                  ).animate(
                                    CurvedAnimation(
                                      parent: _slideController,
                                      curve: const Interval(
                                        0.0,
                                        0.5,
                                        curve: Curves.easeOut,
                                      ),
                                    ),
                                  ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AnimatedBuilder(
                                    animation: _fadeController,
                                    builder: (context, child) {
                                      return Transform.translate(
                                        offset: Offset(
                                          0,
                                          20 * (1 - _fadeAnimation.value),
                                        ),
                                        child: Opacity(
                                          opacity: _fadeAnimation.value,
                                          child: Text(
                                            homeState.greeting,
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  AnimatedBuilder(
                                    animation: _fadeController,
                                    builder: (context, child) {
                                      return Transform.translate(
                                        offset: Offset(
                                          0,
                                          30 * (1 - _fadeAnimation.value),
                                        ),
                                        child: Opacity(
                                          opacity: _fadeAnimation.value,
                                          child: Text(
                                            '${homeState.userName}! 👋',
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 4),
                                  AnimatedBuilder(
                                    animation: _fadeController,
                                    builder: (context, child) {
                                      return Transform.translate(
                                        offset: Offset(
                                          0,
                                          40 * (1 - _fadeAnimation.value),
                                        ),
                                        child: Opacity(
                                          opacity: _fadeAnimation.value,
                                          child: Text(
                                            'Ready to continue your journey?',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white.withValues(
                                                alpha: 0.9,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SlideTransition(
                            position:
                                Tween<Offset>(
                                  begin: const Offset(1, 0),
                                  end: Offset.zero,
                                ).animate(
                                  CurvedAnimation(
                                    parent: _slideController,
                                    curve: const Interval(
                                      0.3,
                                      0.8,
                                      curve: Curves.easeOut,
                                    ),
                                  ),
                                ),
                            child: _buildAnimatedProfileAvatar(),
                          ),
                        ],
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

  List<Widget> _buildFloatingShapes() {
    return List.generate(6, (index) {
      return AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          final animation = (_backgroundAnimation.value + index * 0.2) % 1.0;
          final x =
              50.0 + (index * 60.0) + (math.sin(animation * 2 * math.pi) * 30);
          final y =
              80.0 +
              (index % 2 * 40.0) +
              (math.cos(animation * 2 * math.pi) * 20);

          return Positioned(
            left: x,
            top: y,
            child: Transform.rotate(
              angle: animation * 2 * math.pi,
              child: Container(
                width: 20 + (index % 3 * 10),
                height: 20 + (index % 3 * 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(index % 2 == 0 ? 0 : 10),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildAnimatedProfileAvatar() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: GestureDetector(
            onTap: () {
              _pulseController.forward().then(
                (_) => _pulseController.reverse(),
              );
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            child: Stack(
              children: [
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
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
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale:
                            1.0 +
                            (math.sin(_pulseController.value * 2 * math.pi) *
                                0.1),
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
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsCards(
    HomeScreenState homeState,
    HomeScreenNotifier homeNotifier,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 28,
            childAspectRatio: constraints.maxWidth > 400 ? 1.2 : 1.0,
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
                label: 'Job Opportunities',
                bgColor: const Color(0xFFFEF3C7),
                iconColor: const Color(0xFFF59E0B),
                isLoading: homeState.isLoading,
                onTap: () => homeNotifier.onStatCardTapped('jobs'),
              ),
              _buildStatCard(
                icon: '💰',
                value: homeState.userStats['bursariesAvailable'].toString(),
                label: 'Bursary Opportunities',
                bgColor: const Color(0xFFD1FAE5),
                iconColor: const Color(0xFF10B981),
                isLoading: homeState.isLoading,
                onTap: () => homeNotifier.onStatCardTapped('bursaries'),
              ),
              _buildStatCard(
                icon: '🏆',
                value: homeState.userStats['applications'].toString(),
                label: 'Achievements',
                bgColor: const Color(0xFFFEE2E2),
                iconColor: const Color(0xFFEF4444),
                isLoading: false,
                onTap: () => homeNotifier.onStatCardTapped('applications'),
              ),
            ],
          );
        },
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
      child: Container(
        constraints: const BoxConstraints(minHeight: 120, maxHeight: 150),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
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
            Flexible(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isLoading
                    ? _buildSkeletonBox(width: 40, height: 20)
                    : Text(
                        value,
                        key: ValueKey(value),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Skeleton loading helper
  Widget _buildSkeletonBox({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildSkeletonText({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // Simplified sections without complex animations
  Widget _buildContinueLearning(
    HomeScreenState homeState,
    HomeScreenNotifier homeNotifier,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Continue Learning',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: homeState.isLoading
                ? null
                : () => homeNotifier.onContinueCourseTapped(context),
            child: Container(
              constraints: const BoxConstraints(minHeight: 120, maxHeight: 200),
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
              child: homeState.isLoading
                  ? _buildContinueLearningSkeleton()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
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
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${homeState.currentCourse['module']} • ${homeState.currentCourse['timeLeft']}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: const Color(
                                        0xFF4B5563,
                                      ).withValues(alpha: 0.8),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: homeState.currentCourse['progress'],
                            minHeight: 8,
                            backgroundColor: Colors.white,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF2563EB),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                '${homeState.getProgressPercentage()} Complete',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: const Color(
                                    0xFF4B5563,
                                  ).withValues(alpha: 0.8),
                                ),
                                overflow: TextOverflow.ellipsis,
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

  Widget _buildContinueLearningSkeleton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _buildSkeletonBox(width: 48, height: 48),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSkeletonText(width: double.infinity, height: 16),
                  const SizedBox(height: 8),
                  _buildSkeletonText(width: 120, height: 12),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildSkeletonText(width: double.infinity, height: 8),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSkeletonText(width: 80, height: 12),
            _buildSkeletonText(width: 60, height: 12),
          ],
        ),
      ],
    );
  }

  Widget _buildPopularCourses(LearningHubViewModel viewModel) {
    final homeNotifier = ref.read(homeScreenProvider.notifier);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 0, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  debugPrint('🎯 Courses View All button tapped');
                  homeNotifier.onSeeAllTapped(context, 'courses');
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
          const SizedBox(height: 16),
          SizedBox(
            height: 235,
            child: viewModel.isLoading
                ? _buildPopularCoursesSkeleton()
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: viewModel.popularCourses.length,
                    itemBuilder: (context, index) {
                      final course = viewModel.popularCourses[index];
                      return Container(
                        width: 200,
                        margin: const EdgeInsets.only(right: 12),
                        //child: _buildCourseCard(course),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularCoursesSkeleton() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          width: 200,
          margin: const EdgeInsets.only(right: 12),
          child: _buildCourseCardSkeleton(),
        );
      },
    );
  }

  Widget _buildCourseCard(Course course) {
    return GestureDetector(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => CourseDetailScreen(course: course),
        //   ),
        // );
      },
      child: Container(
        constraints: const BoxConstraints(minHeight: 200, maxHeight: 235),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        course.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'SkillsBridge',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCardSkeleton() {
    return Container(
      constraints: const BoxConstraints(minHeight: 200, maxHeight: 235),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSkeletonText(width: double.infinity, height: 16),
                  const SizedBox(height: 8),
                  _buildSkeletonText(width: 80, height: 12),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSkeletonText(width: 40, height: 12),
                      _buildSkeletonText(width: 30, height: 12),
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
                  'Job Opportunities',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    debugPrint('🎯 Jobs View All button tapped');
                    homeNotifier.onSeeAllTapped(context, 'jobs');
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
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 210,
            child: homeState.isLoading
                ? _buildRecommendedJobsSkeleton()
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(right: 20),
                    itemCount: homeState.recommendedJobs.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final job = homeState.recommendedJobs[index];
                      return _buildJobCard(job, homeNotifier, context);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedJobsSkeleton() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(right: 20),
      itemCount: 3,
      separatorBuilder: (context, index) => const SizedBox(width: 12),
      itemBuilder: (context, index) {
        return _buildJobCardSkeleton();
      },
    );
  }

  Widget _buildJobCard(
    Map<String, dynamic> job,
    HomeScreenNotifier homeNotifier,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () => _navigateToJobDetail(job, context),
      child: Container(
        width: 280,
        constraints: const BoxConstraints(minHeight: 180, maxHeight: 210),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
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
            Flexible(
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _buildJobTag(job['location']),
                  _buildJobTag(job['salary']),
                  _buildJobTag(job['workType']),
                ],
              ),
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
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobCardSkeleton() {
    return Container(
      width: 280,
      constraints: const BoxConstraints(minHeight: 180, maxHeight: 210),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _buildSkeletonBox(width: 40, height: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSkeletonText(width: double.infinity, height: 16),
                    const SizedBox(height: 8),
                    _buildSkeletonText(width: 120, height: 12),
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
              _buildSkeletonText(width: 60, height: 24),
              _buildSkeletonText(width: 50, height: 24),
              _buildSkeletonText(width: 40, height: 24),
            ],
          ),
          const SizedBox(height: 12),
          _buildSkeletonText(width: 80, height: 28),
        ],
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Upcoming Bursary Deadlines',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
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
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  debugPrint('🎯 Bursaries View All button tapped');
                  homeNotifier.onSeeAllTapped(context, 'deadlines');
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
          const SizedBox(height: 16),
          homeState.isLoading
              ? _buildUpcomingDeadlinesSkeleton()
              : Column(
                  children: homeState.upcomingDeadlines.map((deadline) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: _buildBursaryCard(deadline, homeNotifier, context),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildUpcomingDeadlinesSkeleton() {
    return Column(
      children: List.generate(2, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: _buildBursaryCardSkeleton(),
        );
      }),
    );
  }

  Widget _buildBursaryCard(
    Map<String, dynamic> bursary,
    HomeScreenNotifier homeNotifier,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () => homeNotifier.onBursaryCardTapped(context, bursary),
      child: Container(
        constraints: const BoxConstraints(minHeight: 100, maxHeight: 140),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: bursary['isUrgent']
                ? const Color(0xFFEF4444).withValues(alpha: 0.3)
                : const Color(0xFFE5E7EB),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
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
                    'R ${bursary['amount']}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF10B981),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () =>
                  homeNotifier.onBursaryCardTapped(context, bursary),
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
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBursaryCardSkeleton() {
    return Container(
      constraints: const BoxConstraints(minHeight: 100, maxHeight: 140),
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
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSkeletonText(width: double.infinity, height: 16),
                const SizedBox(height: 8),
                _buildSkeletonText(width: 100, height: 14),
                const SizedBox(height: 8),
                _buildSkeletonText(width: 120, height: 12),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _buildSkeletonText(width: 80, height: 36),
        ],
      ),
    );
  }

  // Helper methods
  Future<void> _handleRefresh(HomeScreenNotifier homeNotifier) async {
    await homeNotifier.refreshAllData();
  }

  void _navigateToJobDetail(Map<String, dynamic> job, BuildContext context) {
    // Convert home screen job format to match jobs screen format exactly
    final jobDetail = {
      'id': (job['jobTitle'] ?? 'Unknown').hashCode, // Use int, not String
      'title': job['jobTitle'] ?? 'Unknown Position',
      'company': job['companyName'] ?? 'Unknown Company',
      'location': (job['location'] ?? 'Unknown').toString().replaceAll(
        '📍 ',
        '',
      ),
      'salary': (job['salary'] ?? 'Negotiable').toString().replaceAll(
        '💰 ',
        '',
      ),
      'type': (job['workType'] ?? 'On-site')
          .toString()
          .replaceAll('🌍 ', '')
          .replaceAll('🏠 ', '')
          .replaceAll('🏢 ', ''),
      'logo': job['companyLogo'] ?? '🏢',
      'logoColor': const Color(0xFFF3F4F6),
      'url': 'https://example.com/apply',
      'description':
          'This is a great opportunity to work with a leading company in the industry. You will be responsible for various tasks and will have the chance to grow your career.',
      'matchScore':
          int.tryParse(
            (job['matchPercentage'] ?? '75%').toString().replaceAll('%', ''),
          ) ??
          75,
      'matchLevel': 'medium',
      'workType': 'Full-time',
      'tags': ['Technology', 'Development', 'Career'],
      'postedDate': DateTime.now()
          .subtract(const Duration(days: 2))
          .toIso8601String(),
      'isNew': true,
      'site': 'SkillsBridge',
    };

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => JobDetailPage(job: jobDetail)),
    );
  }

  Widget _buildJobTag(String text) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 80, minHeight: 24),
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
        textAlign: TextAlign.center,
      ),
    );
  }
}

// Custom Painter for floating particles background
class FloatingParticlesPainter extends CustomPainter {
  final double animationValue;

  FloatingParticlesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFF2563EB).withValues(alpha: 0.02)
      ..style = PaintingStyle.fill;

    final Paint strokePaint = Paint()
      ..color = const Color(0xFF3B82F6).withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Create floating particles
    for (int i = 0; i < 20; i++) {
      final double x =
          (size.width / 20) * i +
          30 * math.sin(animationValue * 2 * math.pi + i * 0.5);
      final double y =
          (size.height / 10) * (i % 5) +
          20 * math.cos(animationValue * 2 * math.pi + i * 0.3);

      final double radius =
          2 + 3 * math.sin(animationValue * 2 * math.pi + i * 0.7);

      canvas.drawCircle(Offset(x, y), radius, paint);
      canvas.drawCircle(Offset(x, y), radius + 8, strokePaint);
    }

    // Create flowing connections
    final Path path = Path();
    for (int i = 0; i < 4; i++) {
      final double startX = size.width * 0.1;
      final double startY = size.height * (0.15 + i * 0.25);

      path.moveTo(startX, startY);

      for (double x = startX; x < size.width * 0.9; x += 30) {
        final double y =
            startY +
            40 * math.sin((x / 60 + animationValue * 1.5) * math.pi + i);
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(FloatingParticlesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
