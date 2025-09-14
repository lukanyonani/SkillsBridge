import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillsbridge/models/course_models.dart';
import 'package:skillsbridge/viewmodels/learning_screen_vm.dart';

class LearningTesterHubScreen extends ConsumerStatefulWidget {
  const LearningTesterHubScreen({super.key});

  @override
  ConsumerState<LearningTesterHubScreen> createState() =>
      _LearningHubScreenState();
}

class _LearningHubScreenState extends ConsumerState<LearningTesterHubScreen> {
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(learningHubViewModelProvider);

    if (viewModel.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (viewModel.errorMessage != null) {
      return Scaffold(body: Center(child: Text(viewModel.errorMessage!)));
    }

    return Scaffold(
      body: Column(
        children: [
          //_buildCategoryTabs(viewModel),
          Expanded(
            child: RefreshIndicator(
              onRefresh: viewModel.refreshData,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildTopHeader(),
                    _buildHeader(viewModel),
                    _buildFeaturedCourse(viewModel),
                    _buildPopularCourses(viewModel),
                    const SizedBox(height: 10),
                    _buildCategoryTabs(viewModel),
                    _buildAllCourses(viewModel),
                    const SizedBox(height: 100), // Space for bottom nav
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Flexible(
            child: Text(
              'Learning Hub',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(LearningHubViewModel viewModel) {
    final filterOptions = ['All Levels', 'Undergraduate', 'Graduate'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header top
          // Search bar
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: searchController,
              onChanged: viewModel.updateSearchQuery,
              decoration: const InputDecoration(
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
          const SizedBox(height: 12),

          // Filter pills
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filterOptions.length,
              itemBuilder: (context, index) {
                final filter = filterOptions[index];
                final isActive = viewModel.isFilterActive(filter);
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isActive,
                    onSelected: (selected) => viewModel.toggleFilter(filter),
                    backgroundColor: const Color(0xFFF3F4F6),
                    selectedColor: const Color(0xFF2563EB),
                    labelStyle: TextStyle(
                      color: isActive ? Colors.white : const Color(0xFF6B7280),
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

  Widget _buildCategoryTabs(LearningHubViewModel viewModel) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsetsGeometry.only(
              left: 20,
              bottom: 16,
              top: 20,
              right: 36,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'All Courses',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Filter',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF2563EB),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: viewModel.categories.length,
              itemBuilder: (context, index) {
                final isSelected = viewModel.selectedCategoryIndex == index;
                return GestureDetector(
                  onTap: () => viewModel.selectCategory(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected
                              ? const Color(0xFF2563EB)
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Text(
                      viewModel.categories[index],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? const Color(0xFF2563EB)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(height: 1, color: const Color(0xFFE5E7EB)),
        ],
      ),
    );
  }

  Widget _buildFeaturedCourse(LearningHubViewModel viewModel) {
    final course = viewModel.featuredCourse;
    if (course == null) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.all(20),
      child: GestureDetector(
        onTap: () => _navigateToCourseDetail(viewModel),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '🔥 FEATURED TODAY',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                course.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'by SkillsBridge',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildFeaturedStat('⭐', 'Free'),
                  const SizedBox(width: 16),
                  _buildFeaturedStat('⏱️', 'Programming'),
                  const SizedBox(width: 16),
                  _buildFeaturedStat('⏱️', '30 Videos'),
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
        Text(icon, style: const TextStyle(fontSize: 13)),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 13)),
      ],
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
      onTap: () => _navigateToCourseDetail(viewModel),
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

  Widget _buildAllCourses(LearningHubViewModel viewModel) {
    final courses = viewModel.filteredCourses;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     const Text(
          //       'All Courses',
          //       style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          //     ),
          //     Text(
          //       'Filter →',
          //       style: TextStyle(
          //         fontSize: 14,
          //         color: const Color(0xFF2563EB),
          //         fontWeight: FontWeight.w500,
          //       ),
          //     ),
          //   ],
          // ),
          //const SizedBox(height: 16),
          ...courses.map((course) => _buildCourseListItem(course, viewModel)),
        ],
      ),
    );
  }

  Widget _buildCourseListItem(Course course, LearningHubViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: GestureDetector(
        onTap: () => _navigateToCourseDetail(viewModel),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF3F4F6), Color(0xFFE5E7EB)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('📚', style: TextStyle(fontSize: 32)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'SkillsBridge',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text(
                        '⭐ Free',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                      Text(
                        ' • ${course.level}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                      const Text(
                        ' • 30 hours',
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
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF2563EB),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCourseDetail(LearningHubViewModel viewModel) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => ChangeNotifierProvider.value(
    //       value: viewModel,
    //       child: const CourseDetailScreen(),
    //     ),
    //   ),
    // );
  }
}
