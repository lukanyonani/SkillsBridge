import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skillsbridge/viewmodels/learning_screen_vm.dart';

class CourseDetailScreen extends StatelessWidget {
  const CourseDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LearningScreenViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          body: Column(
            children: [
              _buildHeroSection(context, viewModel),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildCourseInfo(viewModel),
                      _buildSyllabus(viewModel),
                      _buildRelatedCourses(viewModel),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildEnrollSection(context, viewModel),
        );
      },
    );
  }

  Widget _buildHeroSection(BuildContext context, dynamic viewModel) {
    final video = viewModel.selectedCourse;
    return Container(
      height: 240,
      decoration: const BoxDecoration(
        //image: DecorationImage(image: NetworkImage(video['image'])),
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
                  child: const Icon(Icons.arrow_back, color: Colors.white),
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
                child: const Icon(
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

  Widget _buildCourseInfo(LearningScreenViewModel viewModel) {
    final course = viewModel.selectedCourse;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            course['title'],
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'by ${course['instructors']}',
            style: const TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
          ),
          const SizedBox(height: 16),
          // Stats
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('⭐', 'Free'),
                _buildStat('👥', '${course['category']}'),
                _buildStat('⏱️', course['numberOfVideos']),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Description
          Text(
            course['courseDescription'],
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
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
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSyllabus(LearningScreenViewModel viewModel) {
    final modules = viewModel.syllabusModules;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Course Syllabus',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          ...modules.asMap().entries.map((entry) {
            final index = entry.key;
            final module = entry.value;
            return _buildSyllabusItem(module, index, viewModel);
          }),
        ],
      ),
    );
  }

  Widget _buildSyllabusItem(
    SyllabusModule module,
    int index,
    LearningScreenViewModel viewModel,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          GestureDetector(
            //onTap: () => viewModel.toggleSyllabusSection(index),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      module.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(Icons.play_arrow, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedCourses(LearningScreenViewModel viewModel) {
    final courses = viewModel.relatedCourses;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Related Courses',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          ...courses
              .map(
                (course) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: _buildRelatedCourseItem(
                    course['emoji'],
                    course['title'],
                    course['provider'],
                    course['rating'],
                    course['duration'],
                    course['price'],
                  ),
                ),
              )
              .toList(),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  provider,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '⭐ $rating',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                    Text(
                      ' • $duration',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                    Text(
                      ' • $price',
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
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildEnrollSection(
    BuildContext context,
    LearningScreenViewModel viewModel,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
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
                  viewModel.toggleEnrollment();
                  if (viewModel.isEnrolled) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Welcome to the course! Check your email for access details.',
                        ),
                        backgroundColor: Color(0xFF10B981),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: viewModel.isEnrolled
                      ? const Color(0xFF10B981)
                      : const Color(0xFF2563EB),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  viewModel.isEnrolled ? 'Enrolled! ✓' : 'Enroll Now',
                  style: const TextStyle(
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
