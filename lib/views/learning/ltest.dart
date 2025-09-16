import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillsbridge/models/course_models.dart';
import 'package:skillsbridge/viewmodels/learning_screen_vm.dart';
// Import the new course detail screen
import 'course_detail_screen.dart'; // Add this import

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
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Color(0xFF6B7280),
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                viewModel.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => viewModel.refreshData(),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopHeader(),
            _buildHeader(viewModel),
            Expanded(
              child: RefreshIndicator(
                onRefresh: viewModel.refreshData,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildFeaturedCourse(viewModel),
                      const SizedBox(height: 10),
                      _buildCategoryTabs(viewModel),
                      _buildAllCourses(viewModel),
                      if (viewModel.hasMorePages)
                        _buildLoadMoreButton(viewModel),
                      const SizedBox(height: 100), // Space for bottom nav
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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
          // Add debug/mock mode toggle
          Consumer(
            builder: (context, ref, child) {
              final viewModel = ref.watch(learningHubViewModelProvider);
              return IconButton(
                onPressed: () => viewModel.toggleMockMode(),
                icon: Icon(
                  viewModel.isUsingMockData ? Icons.bug_report : Icons.cloud,
                  color: Colors.white,
                ),
                tooltip: viewModel.isUsingMockData
                    ? 'Using Mock Data'
                    : 'Using Live API',
              );
            },
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
        onTap: () => _navigateToCourseDetail(course, viewModel),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
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
                'by ${course.instructor}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildFeaturedStat('⭐', course.rating.toString()),
                  const SizedBox(width: 16),
                  _buildFeaturedStat(
                    '📚',
                    "${course.category}" ?? 'Programming',
                  ),
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

  Widget _buildAllCourses(LearningHubViewModel viewModel) {
    final courses = viewModel.filteredCourses;

    if (courses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            const Icon(Icons.search_off, size: 64, color: Color(0xFF9CA3AF)),
            const SizedBox(height: 16),
            const Text(
              'No courses found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your search or filters',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.clearFilters(),
              child: const Text('Clear Filters'),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'All Courses (${courses.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (viewModel.activeFilters.length > 1 ||
                  viewModel.searchQuery.isNotEmpty)
                TextButton(
                  onPressed: () => viewModel.clearFilters(),
                  child: const Text(
                    'Clear filters',
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
          ...courses.map((course) => _buildCourseListItem(course, viewModel)),
        ],
      ),
    );
  }

  Widget _buildCourseListItem(Course course, LearningHubViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToCourseDetail(course, viewModel),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF3B82F6).withOpacity(0.1),
                        const Color(0xFF8B5CF6).withOpacity(0.1),
                      ],
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
                          color: Color(0xFF111827),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        course.instructor,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.amber.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            course.rating.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF4B5563),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            ' • ${course.level}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF4B5563),
                            ),
                          ),
                          if (course.pricing.type == PricingType.free)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'FREE',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
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
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadMoreButton(LearningHubViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: viewModel.isLoading ? null : viewModel.loadMoreCourses,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: viewModel.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Load More Courses',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  // Updated navigation method
  void _navigateToCourseDetail(Course course, LearningHubViewModel viewModel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailScreen(course: course),
      ),
    );
  }
}
