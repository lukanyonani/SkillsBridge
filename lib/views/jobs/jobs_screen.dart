import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skillsbridge/viewmodels/jobs_screen_vm.dart';
import 'package:skillsbridge/views/jobs/job_application_screen.dart';

class JobPortalScreen extends StatefulWidget {
  const JobPortalScreen({super.key});

  @override
  State<JobPortalScreen> createState() => _JobPortalScreenState();
}

class _JobPortalScreenState extends State<JobPortalScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late JobsScreenViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // Initialize scroll controller for pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Handle scroll for pagination
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      // Load more when user scrolls near the bottom
      final viewModel = context.read<JobsScreenViewModel>();
      if (viewModel.hasMorePages && !viewModel.isLoadingMore) {
        viewModel.loadMoreJobs();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => JobsScreenViewModel(),
      child: Consumer<JobsScreenViewModel>(
        builder: (context, viewModel, child) {
          _viewModel = viewModel;
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
          Expanded(child: _buildJobListBody(viewModel)),
        ],
      ),
    );
  }

  Widget _buildJobListBody(JobsScreenViewModel viewModel) {
    // Show error state
    if (viewModel.hasError && !viewModel.hasJobs) {
      return _buildErrorState(viewModel);
    }

    // Show loading state for initial load
    if (viewModel.isLoading && !viewModel.hasJobs) {
      return _buildLoadingState();
    }

    // Show empty state
    if (!viewModel.isLoading && !viewModel.hasJobs) {
      return _buildEmptyState(viewModel);
    }

    // Show job list with pull-to-refresh
    return RefreshIndicator(
      onRefresh: () async {
        await viewModel.refreshJobs();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: viewModel.jobs.length + (viewModel.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Show loading indicator at the bottom when loading more
          if (index == viewModel.jobs.length) {
            return _buildLoadMoreIndicator();
          }

          return _buildJobCard(viewModel.jobs[index], viewModel);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
          ),
          SizedBox(height: 16),
          Text(
            'Finding great opportunities for you...',
            style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(JobsScreenViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Center(
                child: Text('⚠️', style: TextStyle(fontSize: 32)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.errorMessage ?? 'Unable to load jobs right now',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () => viewModel.testApiConnection(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF2563EB)),
                  ),
                  child: const Text(
                    'Test Connection',
                    style: TextStyle(color: Color(0xFF2563EB)),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => viewModel.refreshJobs(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(JobsScreenViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Center(
                child: Text('🔍', style: TextStyle(fontSize: 32)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No jobs found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your search or filters to find more opportunities',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                viewModel.updateSearchQuery('');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear Search'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
              ),
            ),
            SizedBox(width: 8),
            Text(
              'Loading more jobs...',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
          ],
        ),
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
              GestureDetector(
                onTap: () => _showSavedJobs(viewModel),
                child: Stack(
                  children: [
                    _buildIconButton('💾'),
                    if (viewModel.savedJobsCount > 0)
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
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _showDebugInfo(viewModel),
                child: _buildIconButton('⚙️'),
              ),
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
              decoration: InputDecoration(
                hintText: 'Job title, keywords, or company',
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(11),
                  child: Text('🔍', style: TextStyle(fontSize: 20)),
                ),
                suffixIcon: viewModel.isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF2563EB),
                            ),
                          ),
                        ),
                      )
                    : _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          viewModel.updateSearchQuery('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: viewModel.locationQuery,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  viewModel.updateLocationQuery(newValue);
                }
              },
              icon: const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF6B7280),
                ),
              ),
              items: viewModel.availableLocations.map<DropdownMenuItem<String>>(
                (String location) {
                  return DropdownMenuItem<String>(
                    value: location,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('📍', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Text(location, style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                  );
                },
              ).toList(),
            ),
          ),
        ),
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
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
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
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${viewModel.jobsCount} Jobs Found',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                if (viewModel.hasMorePages)
                  Text(
                    'Page ${viewModel.currentPage} of ${viewModel.totalPages}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
              ],
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
                mainAxisSize: MainAxisSize.min,
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
    final isNew = job['isNew'] == true;

    return GestureDetector(
      onTap: () => viewModel.selectJob(job),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isNew
                ? const Color(0xFF10B981).withOpacity(0.3)
                : const Color(0xFFE5E7EB),
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
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
                          color: job['logoColor'] ?? const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            job['logo'] ?? '🏢',
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
                              job['title'] ?? 'Unknown Position',
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
                              job['company'] ?? 'Unknown Company',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
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
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _buildJobMetaItem('📍', job['location'] ?? 'Unknown'),
                      _buildJobMetaItem('💰', job['salary'] ?? 'Negotiable'),
                      _buildJobMetaItem(
                        job['type'] == 'Remote' ? '🌍' : '🏠',
                        job['type'] ?? 'On-site',
                      ),
                      _buildJobMetaItem('⏰', job['workType'] ?? 'Full-time'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            ...(job['tags'] as List<String>? ?? [])
                                .take(3)
                                .map(
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
                            if (isNew)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'New',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: viewModel.getMatchGradient(
                              job['matchLevel'] ?? 'medium',
                            ),
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${job['matchScore'] ?? 75}% Match',
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
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      size: 16,
                      color: isSaved ? Colors.white : const Color(0xFF6B7280),
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
        Flexible(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Job Detail View (keeping existing implementation)
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
                  const SizedBox(height: 18),
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
                        job['logo'] ?? '🏢',
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    job['title'] ?? 'Unknown Position',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    job['company'] ?? 'Unknown Company',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    children: [
                      _buildDetailMetaItem('📍', job['location'] ?? 'Unknown'),
                      _buildDetailMetaItem(
                        '💰',
                        (job['salary'] ?? 'Negotiable').split(' - ')[0],
                      ),
                      _buildDetailMetaItem('🏠', job['type'] ?? 'On-site'),
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 14, color: Colors.white)),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 14, color: Colors.white)),
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
              child: Icon(
                status == 'met'
                    ? Icons.check
                    : status == 'partial'
                    ? Icons.warning
                    : Icons.circle_outlined,
                size: 12,
                color: status == 'unmet'
                    ? const Color(0xFF6B7280)
                    : Colors.white,
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
              // Could navigate to similar job
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
                  Expanded(
                    child: Column(
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
                  child: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: isSaved ? Colors.white : const Color(0xFF2563EB),
                    size: 20,
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

  // Additional Features
  void _showSortOptions(JobsScreenViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sort Jobs',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              ...viewModel.sortOptions.map((option) {
                return ListTile(
                  title: Text(option),
                  leading: Radio<String>(
                    value: option,
                    groupValue: viewModel.sortOption,
                    onChanged: (value) {
                      if (value != null) {
                        viewModel.updateSortOption(value);
                        Navigator.pop(context);
                      }
                    },
                  ),
                  onTap: () {
                    viewModel.updateSortOption(option);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showSavedJobs(JobsScreenViewModel viewModel) {
    final savedJobs = viewModel.getSavedJobs();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Saved Jobs (${savedJobs.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (savedJobs.isEmpty)
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('📁', style: TextStyle(fontSize: 48)),
                        SizedBox(height: 16),
                        Text(
                          'No saved jobs yet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Save jobs you\'re interested in to view them here',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: savedJobs.length,
                    itemBuilder: (context, index) {
                      return _buildJobCard(savedJobs[index], viewModel);
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showDebugInfo(JobsScreenViewModel viewModel) {
    final debugInfo = viewModel.getDebugInfo();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Debug Info'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: debugInfo.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('${entry.key}: ${entry.value}'),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              viewModel.testApiConnection();
            },
            child: const Text('Test API'),
          ),
        ],
      ),
    );
  }

  void _applyForJob(JobsScreenViewModel viewModel) {
    final job = viewModel.selectedJob!;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => JobApplicationWebView(job: job)),
    );
  }

  // void _applyForJob(JobsScreenViewModel viewModel) {
  //   final job = viewModel.selectedJob!;

  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Apply for Job'),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text('Position: ${job['title']}'),
  //           Text('Company: ${job['company']}'),
  //           const SizedBox(height: 16),
  //           const Text(
  //             'This would normally open the application process or redirect to the company\'s website.',
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Cancel'),
  //         ),
  //         ElevatedButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //             ScaffoldMessenger.of(context).showSnackBar(
  //               SnackBar(
  //                 content: Text(
  //                   'Applied for ${job['title']} at ${job['company']}',
  //                 ),
  //                 backgroundColor: const Color(0xFF10B981),
  //                 action: SnackBarAction(
  //                   label: 'View',
  //                   textColor: Colors.white,
  //                   onPressed: () {},
  //                 ),
  //               ),
  //             );
  //           },
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: const Color(0xFF2563EB),
  //             foregroundColor: Colors.white,
  //           ),
  //           child: const Text('Apply'),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
