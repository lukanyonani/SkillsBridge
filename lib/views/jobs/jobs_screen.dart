import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skillsbridge/viewmodels/jobs_screen_vm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class JobPortalScreen extends StatefulWidget {
  const JobPortalScreen({super.key});

  @override
  State<JobPortalScreen> createState() => _JobPortalScreenState();
}

class _JobPortalScreenState extends State<JobPortalScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => JobsScreenViewModel(),
      child: Consumer<JobsScreenViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: const Color(0xFFF9FAFB),
            body: viewModel.showDetail
                ? _buildJobDetail(viewModel)
                : _buildJobList(viewModel),
          );
        },
      ),
    );
  }

  Widget _buildJobList(JobsScreenViewModel viewModel) {
    return SafeArea(
      child: Column(
        children: [
          _buildTopHeader(viewModel),
          _buildHeader(viewModel),
          _buildResultsBar(viewModel),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.jobs.length,
              itemBuilder: (context, index) =>
                  _buildJobCard(viewModel.jobs[index], viewModel),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeader(JobsScreenViewModel viewModel) {
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
              'Jobs Portal',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          Row(
            children: [
              Stack(
                children: [
                  _buildIconButton('💾'),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${viewModel.savedJobsCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(JobsScreenViewModel viewModel) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 12),
          _buildSearchSection(viewModel),
          const SizedBox(height: 12),
          _buildFilterPills(viewModel),
        ],
      ),
    );
  }

  Widget _buildIconButton(String icon) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Center(child: Text(icon, style: const TextStyle(fontSize: 22))),
    );
  }

  Widget _buildSearchSection(JobsScreenViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: viewModel.updateSearchQuery,
              decoration: const InputDecoration(
                hintText: 'Job title, keywords, or company',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(11),
                  child: Text('🔍', style: TextStyle(fontSize: 20)),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Expanded(
        //   child: Container(
        //     decoration: BoxDecoration(
        //       border: Border.all(color: const Color(0xFFE5E7EB)),
        //       borderRadius: BorderRadius.circular(12),
        //     ),
        //     child: DropdownButtonFormField<String>(
        //       value: viewModel.locationQuery,
        //       onChanged: (String? newValue) {
        //         if (newValue != null) {
        //           viewModel.updateLocationQuery(newValue);
        //         }
        //       },
        //       decoration: const InputDecoration(
        //         prefixIcon: Padding(
        //           padding: EdgeInsets.all(12),
        //           child: Text('📍', style: TextStyle(fontSize: 20)),
        //         ),
        //         border: InputBorder.none,
        //         contentPadding: EdgeInsets.symmetric(
        //           vertical: 14,
        //           horizontal: 12,
        //         ),
        //       ),
        //       items: viewModel.availableLocations.map<DropdownMenuItem<String>>(
        //         (String location) {
        //           return DropdownMenuItem<String>(
        //             value: location,
        //             child: Text(location, style: const TextStyle(fontSize: 14)),
        //           );
        //         },
        //       ).toList(),
        //       dropdownColor: Colors.white,
        //       icon: const Icon(
        //         Icons.keyboard_arrow_down,
        //         color: Color(0xFF6B7280),
        //       ),
        //       style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget _buildFilterPills(JobsScreenViewModel viewModel) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: viewModel.filterOptions.length,
        itemBuilder: (context, index) {
          final filter = viewModel.filterOptions[index];
          final isActive = viewModel.isFilterActive(filter);

          return Padding(
            padding: EdgeInsets.only(right: 8, left: index == 0 ? 0 : 0),
            child: GestureDetector(
              onTap: () => viewModel.toggleFilter(filter),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF2563EB) : Colors.white,
                  border: Border.all(
                    color: isActive
                        ? const Color(0xFF2563EB)
                        : const Color(0xFFD1D5DB),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    fontSize: 13,
                    color: isActive ? Colors.white : const Color(0xFF111827),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultsBar(JobsScreenViewModel viewModel) {
    return Container(
      color: const Color(0xFFF3F4F6),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${viewModel.jobsCount} Jobs Found',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          GestureDetector(
            onTap: () => _showSortOptions(viewModel),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    'Sort: ${viewModel.sortOption}',
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(width: 4),
                  const Text('▼', style: TextStyle(fontSize: 10)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(
    Map<String, dynamic> job,
    JobsScreenViewModel viewModel,
  ) {
    final isSaved = viewModel.isJobSaved(job['id']);

    return GestureDetector(
      onTap: () => viewModel.selectJob(job),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: job['logoColor'],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            job['logo'],
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
                              job['title'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              job['company'],
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _buildJobMetaItem('📍', job['location']),
                      _buildJobMetaItem('💰', job['salary']),
                      _buildJobMetaItem(
                        job['type'] == 'Remote' ? '🌍' : '🏠',
                        job['type'],
                      ),
                      _buildJobMetaItem('⏰', job['workType']),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Wrap(
                        spacing: 6,
                        children: [
                          ...(job['tags'] as List<String>).map(
                            (tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                tag,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF374151),
                                ),
                              ),
                            ),
                          ),
                          if (job['isNew'])
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'New',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: viewModel.getMatchGradient(
                              job['matchLevel'],
                            ),
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${job['matchScore']}% Match',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () => viewModel.toggleSaveJob(job['id']),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSaved ? const Color(0xFF2563EB) : Colors.white,
                    border: Border.all(
                      color: isSaved
                          ? const Color(0xFF2563EB)
                          : const Color(0xFFE5E7EB),
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      '💾',
                      style: TextStyle(
                        fontSize: 16,
                        color: isSaved ? Colors.white : null,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobMetaItem(String icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 13)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
        ),
      ],
    );
  }

  Widget _buildJobDetail(JobsScreenViewModel viewModel) {
    if (viewModel.selectedJob == null) return Container();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildDetailHeader(viewModel),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildMatchAnalysis(viewModel),
                  _buildDetailBody(viewModel),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildApplySection(viewModel),
    );
  }

  Widget _buildDetailHeader(JobsScreenViewModel viewModel) {
    final job = viewModel.selectedJob!;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        job['logo'],
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    job['title'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    job['company'],
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDetailMetaItem('📍', job['location']),
                      const SizedBox(width: 16),
                      _buildDetailMetaItem('💰', job['salary'].split(' - ')[0]),
                      const SizedBox(width: 16),
                      _buildDetailMetaItem('🏠', job['type']),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 10,
              left: 20,
              child: GestureDetector(
                onTap: viewModel.goBackToJobList,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailMetaItem(String icon, String text) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 14, color: Colors.white)),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 14, color: Colors.white)),
      ],
    );
  }

  Widget _buildMatchAnalysis(JobsScreenViewModel viewModel) {
    final job = viewModel.selectedJob!;
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Match Score',
                    style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${job['matchScore']}%',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  const Text('🎯', style: TextStyle(fontSize: 24)),
                  const SizedBox(height: 4),
                  Text(
                    'Great Match!',
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF10B981),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildMatchFactor('💼', 'Experience Level', 0.9),
          const SizedBox(height: 12),
          _buildMatchFactor('🎓', 'Education Match', 1.0),
          const SizedBox(height: 12),
          _buildMatchFactor('💡', 'Skills Match', 0.75),
          const SizedBox(height: 12),
          _buildMatchFactor('📍', 'Location Fit', 0.8),
        ],
      ),
    );
  }

  Widget _buildMatchFactor(String icon, String name, double value) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFDBEAFE),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(icon, style: const TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFE5E7EB),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailBody(JobsScreenViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailSection('About the Role', viewModel.getJobDescription()),
          const SizedBox(height: 24),
          _buildRequirementsSection(viewModel),
          const SizedBox(height: 24),
          _buildSkillsSection(viewModel),
          const SizedBox(height: 24),
          _buildDetailSection('What We Offer', viewModel.getJobBenefits()),
          const SizedBox(height: 24),
          _buildSimilarJobs(viewModel),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            height: 1.6,
            color: Color(0xFF4B5563),
          ),
        ),
      ],
    );
  }

  Widget _buildRequirementsSection(JobsScreenViewModel viewModel) {
    final requirements = viewModel.getJobRequirements();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Requirements',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),
        ...requirements.map(
          (req) => _buildRequirementItem(req['text']!, req['status']!),
        ),
      ],
    );
  }

  Widget _buildRequirementItem(String text, String status) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: status == 'met'
                  ? const Color(0xFF10B981)
                  : status == 'partial'
                  ? const Color(0xFFF59E0B)
                  : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                status == 'met'
                    ? '✓'
                    : status == 'partial'
                    ? '!'
                    : '○',
                style: TextStyle(
                  fontSize: 12,
                  color: status == 'unmet'
                      ? const Color(0xFF6B7280)
                      : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection(JobsScreenViewModel viewModel) {
    final skills = viewModel.getSkillsRequired();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Skills Required',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: skills.map((skill) {
            final hasSkill = skill['hasSkill'] as bool;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: hasSkill
                    ? const Color(0xFF10B981)
                    : const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                skill['name'] as String,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: hasSkill ? Colors.white : const Color(0xFF2563EB),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSimilarJobs(JobsScreenViewModel viewModel) {
    final similarJobs = viewModel.getSimilarJobs();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Similar Jobs',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),
        ...similarJobs.map(
          (job) => GestureDetector(
            onTap: () {
              // Navigate to similar job
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job['title'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${job['company']} • ${job['location']} • ${job['salary']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${job['match']}%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildApplySection(JobsScreenViewModel viewModel) {
    final isSaved = viewModel.isJobSaved(viewModel.selectedJob?['id']);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: const Color(0xFFE5E7EB).withOpacity(0.5)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 12,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            GestureDetector(
              onTap: () =>
                  viewModel.toggleSaveJob(viewModel.selectedJob!['id']),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSaved ? const Color(0xFF2563EB) : Colors.white,
                  border: Border.all(color: const Color(0xFF2563EB), width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '💾',
                    style: TextStyle(
                      fontSize: 20,
                      color: isSaved ? Colors.white : null,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _applyForJob(viewModel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Apply Now',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortOptions(JobsScreenViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: viewModel.sortOptions.map((option) {
              return ListTile(
                title: Text(option),
                trailing: viewModel.sortOption == option
                    ? const Icon(Icons.check, color: Color(0xFF2563EB))
                    : null,
                onTap: () {
                  viewModel.updateSortOption(option);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _applyForJob(JobsScreenViewModel viewModel) {
    final job = viewModel.selectedJob!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Applied for ${job['title']} at ${job['company']}'),
        backgroundColor: const Color(0xFF10B981),
        action: SnackBarAction(
          label: 'View Status',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
}
