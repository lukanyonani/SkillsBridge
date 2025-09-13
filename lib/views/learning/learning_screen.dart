import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skillsbridge/viewmodels/learning_screen_vm.dart';
import 'package:skillsbridge/views/learning/course_detail_screen.dart';

class LearningHubScreen extends StatefulWidget {
  const LearningHubScreen({super.key});

  @override
  _LearningHubScreenState createState() => _LearningHubScreenState();
}

class _LearningHubScreenState extends State<LearningHubScreen> {
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LearningScreenViewModel(),
      child: Consumer<LearningScreenViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  _buildHeader(viewModel),
                  _buildCategoryTabs(viewModel),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildFeaturedCourse(viewModel),
                          _buildPopularCourses(viewModel),
                          _buildAllCourses(viewModel),
                          const SizedBox(height: 100), // Space for bottom nav
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(LearningScreenViewModel viewModel) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header top
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
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
                  const SizedBox(width: 12),
                  _buildIconButton('⚙️'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

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
              itemCount: viewModel.filterOptions.length,
              itemBuilder: (context, index) {
                final filter = viewModel.filterOptions[index];
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

  Widget _buildIconButton(String emoji) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
    );
  }

  Widget _buildCategoryTabs(LearningScreenViewModel viewModel) {
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

  Widget _buildFeaturedCourse(LearningScreenViewModel viewModel) {
    final course = viewModel.featuredCourse;
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
                course['title'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'by ${course['provider']}',
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

  Widget _buildPopularCourses(LearningScreenViewModel viewModel) {
    final courses = viewModel.filteredPopularCourses;

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

  Widget _buildCourseCard(
    CourseCard course,
    LearningScreenViewModel viewModel,
  ) {
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
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      course.gradient ??
                      [const Color(0xFFDBEAFE), const Color(0xFF3B82F6)],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Text(course.emoji, style: const TextStyle(fontSize: 48)),
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
                  Text(
                    course.provider,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('⭐', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text(
                            course.rating.toString(),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      Text(
                        course.price,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: course.price == 'Free'
                              ? const Color(0xFF10B981)
                              : const Color(0xFF6B7280),
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

  Widget _buildAllCourses(LearningScreenViewModel viewModel) {
    final courses = viewModel.filteredAllCourses;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'All Courses',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Text(
                'Filter →',
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF2563EB),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...courses
              .map((course) => _buildCourseListItem(course, viewModel))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildCourseListItem(
    ListCourse course,
    LearningScreenViewModel viewModel,
  ) {
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
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      course.gradient ??
                      [const Color(0xFFF3F4F6), const Color(0xFFE5E7EB)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(course.emoji, style: const TextStyle(fontSize: 32)),
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
                  Text(
                    course.provider,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '⭐ Free',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                      Text(
                        ' • ${course.category}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                      Text(
                        ' • ${course.duration}',
                        style: const TextStyle(
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

  void _navigateToCourseDetail(LearningScreenViewModel viewModel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: viewModel,
          child: const CourseDetailScreen(),
        ),
      ),
    );
  }
}
