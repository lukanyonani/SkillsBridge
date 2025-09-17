import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:skillsbridge/viewmodels/jobs_screen_vm.dart';

class JobDetailPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> job;

  const JobDetailPage({super.key, required this.job});

  @override
  ConsumerState<JobDetailPage> createState() => _JobDetailPageState();
}

class _JobDetailPageState extends ConsumerState<JobDetailPage> {
  @override
  void initState() {
    super.initState();
    // No need to select job since we're not using modal anymore
  }

  Future<void> _launchJobUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('Could not open the job application link');
      }
    } catch (e) {
      _showErrorSnackBar('Invalid job application link');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final viewModel = ref.watch(jobsScreenViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(job, viewModel),
          SliverToBoxAdapter(child: _buildContent(job, viewModel)),
        ],
      ),
      bottomNavigationBar: _buildBottomActionBar(job, viewModel),
    );
  }

  Widget _buildSliverAppBar(Map<String, dynamic> job, JobsScreenViewModel vm) {
    final isSaved = vm.isJobSaved(job['id']);

    return SliverAppBar(
      expandedHeight: 280, // Increased height to accommodate content
      pinned: true,
      backgroundColor: const Color(0xFF2563EB),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo section
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: Center(
                      child: Text(
                        job['logo'] ?? '🏢',
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Job title - flexible text
                  Flexible(
                    child: Text(
                      job['title'] ?? 'Unknown Position',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Company name - flexible text
                  Flexible(
                    child: Text(
                      job['company'] ?? 'Unknown Company',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Quick stats - made more compact
                  _buildQuickStats(job),
                ],
              ),
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(
            isSaved ? Icons.bookmark : Icons.bookmark_border,
            color: Colors.white,
          ),
          onPressed: () {
            vm.toggleSaveJob(job['id']);
            _showSuccessSnackBar(
              isSaved ? 'Job removed from saved' : 'Job saved!',
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildQuickStats(Map<String, dynamic> job) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem('📍', job['location'] ?? 'Unknown'),
        _buildStatItem(
          job['type'] == 'Remote'
              ? '🌍'
              : job['type'] == 'Hybrid'
              ? '🏢'
              : '🏠',
          job['type'] ?? 'On-site',
        ),
        _buildStatItem('💰', job['salary'] ?? 'Negotiable'),
      ],
    );
  }

  Widget _buildStatItem(String icon, String text) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> job, JobsScreenViewModel vm) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMatchCard(job),
          const SizedBox(height: 24),
          _buildJobOverview(job),
          const SizedBox(height: 24),
          _buildJobDescription(vm),
          //const SizedBox(height: 24),
          //_buildSkillsSection(vm),
          // const SizedBox(height: 24),
          // _buildBenefitsSection(vm),
          // const SizedBox(height: 24),
          // _buildCompanyInfo(job),
          const SizedBox(height: 24),
          _buildSimilarJobs(vm),
          const SizedBox(height: 60), // Space for bottom action bar
        ],
      ),
    );
  }

  Widget _buildMatchCard(Map<String, dynamic> job) {
    final matchScore = job['matchScore'] ?? 75;
    final matchLevel = job['matchLevel'] ?? 'medium';

    Color cardColor;
    String matchText;
    IconData matchIcon;

    switch (matchLevel) {
      case 'high':
        cardColor = const Color(0xFF10B981);
        matchText = 'Excellent Match!';
        matchIcon = Icons.star;
        break;
      case 'medium':
        cardColor = const Color(0xFFF59E0B);
        matchText = 'Good Match';
        matchIcon = Icons.thumb_up;
        break;
      default:
        cardColor = const Color(0xFF6B7280);
        matchText = 'Potential Match';
        matchIcon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cardColor, cardColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Text(
                '$matchScore%',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(matchIcon, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      matchText,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Based on your profile and preferences',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobOverview(Map<String, dynamic> job) {
    return _buildSection(
      title: 'Job Overview',
      icon: Icons.work_outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Position', job['title'] ?? 'Not specified'),
          const SizedBox(height: 12),
          _buildInfoRow('Company', job['company'] ?? 'Not specified'),
          const SizedBox(height: 12),
          _buildInfoRow('Location', job['location'] ?? 'Not specified'),
          const SizedBox(height: 12),
          _buildInfoRow('Work Type', job['type'] ?? 'On-site'),
          const SizedBox(height: 12),
          _buildInfoRow('Employment Type', job['workType'] ?? 'Full-time'),
          const SizedBox(height: 12),
          _buildInfoRow('Salary Range', job['salary'] ?? 'Negotiable'),
          if (job['postedDate'] != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow('Posted', _formatDate(job['postedDate'])),
          ],
          if (job['isNew'] == true) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.new_releases, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'New Posting!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildJobDescription(JobsScreenViewModel vm) {
    final description = vm.getJobDescription(widget.job);

    return _buildSection(
      title: 'About This Role',
      icon: Icons.description_outlined,
      child: Text(
        description,
        style: const TextStyle(
          fontSize: 14,
          height: 1.6,
          color: Color(0xFF4B5563),
        ),
      ),
    );
  }

  Widget _buildSimilarJobs(JobsScreenViewModel vm) {
    final similarJobs = vm.getSimilarJobs();
    if (similarJobs.isEmpty) return const SizedBox.shrink();

    return _buildSection(
      title: 'Similar Jobs',
      icon: Icons.recommend_outlined,
      child: Column(
        children: similarJobs.map((job) {
          return GestureDetector(
            onTap: () {
              // Navigate to similar job if needed
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.work_outline,
                        color: Color(0xFF2563EB),
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${job['company']} • ${job['location']}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${job['match']}% Match',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(icon, size: 18, color: const Color(0xFF2563EB)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF374151),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionBar(
    Map<String, dynamic> job,
    JobsScreenViewModel vm,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, -4),
            blurRadius: 12,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _handleApplyNow(job),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.open_in_new, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Apply Now',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
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

  void _handleApplyNow(Map<String, dynamic> job) {
    final jobUrl = job['url'] as String?;

    if (jobUrl != null && jobUrl.isNotEmpty) {
      _launchJobUrl(jobUrl);
    } else {
      _showErrorSnackBar('No application link available for this job');
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date).inDays;

      if (difference == 0) {
        return 'Today';
      } else if (difference == 1) {
        return 'Yesterday';
      } else if (difference < 7) {
        return '$difference days ago';
      } else if (difference < 30) {
        final weeks = (difference / 7).floor();
        return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateStr;
    }
  }
}
