import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillsbridge/constants/theme.dart';
import 'package:skillsbridge/models/course_models.dart';
import 'package:skillsbridge/viewmodels/bursary_screen_vm.dart';
import 'package:skillsbridge/viewmodels/home_screen_vm.dart'; // Import the home provider
import 'package:skillsbridge/viewmodels/jobs_screen_vm.dart'; // Import the jobs provider
import 'package:skillsbridge/viewmodels/learning_screen_vm.dart';
import 'package:skillsbridge/views/profile/profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late JobsScreenViewModel _jobsViewModel;

  @override
  void initState() {
    super.initState();
    _jobsViewModel = JobsScreenViewModel();
    // Initialize the home screen notifier when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeScreenProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeScreenProvider);
    final homeNotifier = ref.read(homeScreenProvider.notifier);

    final viewModel = ref.watch(learningHubViewModelProvider);

    if (viewModel.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (viewModel.errorMessage != null) {
      return Scaffold(body: Center(child: Text(viewModel.errorMessage!)));
    }

    return Scaffold(
      backgroundColor: AppTheme.surfaceWhite,
      body: RefreshIndicator(
        onRefresh: homeNotifier.refreshAllData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(homeState, homeNotifier),
              _buildStatsCards(homeState, homeNotifier),
              const SizedBox(height: 1),
              _buildContinueLearning(homeState, homeNotifier),
              _buildPopularCourses(viewModel),
              const SizedBox(height: 10),
              _buildRecommendedJobs(homeState, homeNotifier),
              _buildUpcomingDeadlines(homeState, homeNotifier),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
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
                    Text(
                      homeState.greeting,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      '${homeState.userName}! 👋',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ready to continue your journey?',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
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
              const SizedBox(width: 32),
            ],
          ),
        ],
      ),
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
            children: [
              _buildStatCard(
                icon: '📚',
                value: homeState.userStats['coursesAvailable'].toString(),
                label: 'Courses Available',
                bgColor: const Color(0xFFDBEAFE),
                iconColor: const Color(0xFF2563EB),
                onTap: () => homeNotifier.onStatCardTapped('skillsAssessed'),
              ),
              _buildStatCard(
                icon: '💼',
                value: homeState.userStats['jobsAvailable'].toString(),
                label: 'Jobs Available',
                bgColor: const Color(0xFFFEF3C7),
                iconColor: const Color(0xFFF59E0B),
                onTap: () => homeNotifier.onStatCardTapped('jobMatches'),
              ),
              _buildStatCard(
                icon: '💡',
                value: homeState.userStats['bursariesAvailable'].toString(),
                label: 'Bursaries Available',
                bgColor: const Color(0xFFD1FAE5),
                iconColor: const Color(0xFF10B981),
                onTap: () => homeNotifier.onStatCardTapped('activeCourses'),
              ),
              _buildStatCard(
                icon: '📝',
                value: homeState.userStats['applications'].toString(),
                label: 'Achievements',
                bgColor: const Color(0xFFFEE2E2),
                iconColor: const Color(0xFFEF4444),
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
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                child: Text(icon, style: const TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            child: Container(
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
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${homeState.currentCourse['module']} • ${homeState.currentCourse['timeLeft']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: const Color(0xFF4B5563).withOpacity(0.8),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
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
    final courses = viewModel.popularCourses;

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
              Text(
                'See all →',
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF2563EB),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
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
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(Course course, LearningHubViewModel viewModel) {
    return GestureDetector(
      //onTap: () => _navigateToCourseDetail(viewModel),
      child: Container(
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
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFDBEAFE), Color(0xFF3B82F6)],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
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
                  'Recommended Jobs',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                TextButton(
                  onPressed: () => homeNotifier.onSeeAllTapped('jobs'),
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
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(
    Map<String, dynamic> job,
    HomeScreenNotifier homeNotifier,
  ) {
    return GestureDetector(
      onTap: () => homeNotifier.onJobCardTapped(job),
      child: Container(
        width: 280,
        height: 280,
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
              ],
            ),
            const SizedBox(height: 6),
            _buildJobTag(job['workType']),
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
            const SizedBox(height: 12),
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
              const Text(
                'Upcoming Bursary Deadlines',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
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
          Column(
            children: homeState.upcomingDeadlines.map((deadline) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildBursaryCard(deadline, homeNotifier),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBursaryCard(
    Map<String, dynamic> bursary,
    HomeScreenNotifier homeNotifier,
  ) {
    return GestureDetector(
      onTap: () => homeNotifier.onBursaryCardTapped(bursary),
      child: Container(
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
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    bursary['amount'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF10B981),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Text(
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
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () => homeNotifier.onApplyNowTapped(bursary['title']),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Apply Now',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
