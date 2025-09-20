import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:skillsbridge/models/bursary_models.dart';
import 'package:skillsbridge/viewmodels/bursary/bursary_screen_vm.dart';

class BursaryDetailPage extends ConsumerStatefulWidget {
  final Bursary bursary;

  const BursaryDetailPage({super.key, required this.bursary});

  @override
  ConsumerState<BursaryDetailPage> createState() => _BursaryDetailPageState();
}

class _BursaryDetailPageState extends ConsumerState<BursaryDetailPage> {
  Bursary? detailedBursary;
  bool isLoadingDetails = false;

  @override
  void initState() {
    super.initState();
    _loadBursaryDetails();
  }

  Future<void> _loadBursaryDetails() async {
    setState(() {
      isLoadingDetails = true;
    });

    try {
      final details = await ref
          .read(bursaryFinderProvider.notifier)
          .getBursaryDetails(widget.bursary.id);

      if (mounted) {
        setState(() {
          detailedBursary = details;
          isLoadingDetails = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingDetails = false;
        });
      }
    }
  }

  Bursary get currentBursary => detailedBursary ?? widget.bursary;

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('Could not open the application link');
      }
    } catch (e) {
      _showErrorSnackBar('Invalid application link');
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
    final state = ref.watch(bursaryFinderProvider);
    final notifier = ref.read(bursaryFinderProvider.notifier);
    final isSaved = state.isBursarySaved(currentBursary.id);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(isSaved, notifier),
          SliverToBoxAdapter(
            child: isLoadingDetails ? _buildLoadingState() : _buildContent(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActionBar(notifier),
    );
  }

  Widget _buildSliverAppBar(bool isSaved, BursaryFinderNotifier notifier) {
    return SliverAppBar(
      expandedHeight: 200,
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
          padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currentBursary.provider.name,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  currentBursary.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.3,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'R${currentBursary.coverage.amount ?? 'Not specified'}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
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
            notifier.toggleSaveBursary(currentBursary.id);
            _showSuccessSnackBar(
              isSaved ? 'Bursary removed from saved' : 'Bursary saved!',
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(color: Color(0xFF2563EB)),
            SizedBox(height: 16),
            Text(
              'Loading bursary details...',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverviewSection(),
          const SizedBox(height: 24),
          _buildCoverageSection(),
          const SizedBox(height: 24),
          _buildEligibilitySection(),
          const SizedBox(height: 24),
          _buildApplicationSection(),
          const SizedBox(height: 24),
          _buildRequiredDocumentsSection(),
          const SizedBox(height: 40), // Space for bottom action bar
        ],
      ),
    );
  }

  Widget _buildOverviewSection() {
    return _buildSection(
      title: 'Bursary Overview',
      icon: Icons.info_outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            'Study Level',
            currentBursary.studyLevel.isNotEmpty
                ? currentBursary.studyLevel
                : 'Not specified',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Academic Year',
            currentBursary.academicYear.isNotEmpty
                ? currentBursary.academicYear
                : 'Not specified',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Fields of Study',
            currentBursary.fields.isNotEmpty
                ? currentBursary.fields.join(', ')
                : 'Multiple fields',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Number Available',
            currentBursary.numberOfBursaries?.toString() ?? 'Not specified',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Application Deadline',
            currentBursary.deadline.displayText.isNotEmpty
                ? currentBursary.deadline.displayText
                : 'Check application details',
          ),
          if (currentBursary.deadline.isUrgent) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning, size: 16, color: Color(0xFFEF4444)),
                  SizedBox(width: 4),
                  Text(
                    'Urgent - Closing Soon!',
                    style: TextStyle(
                      color: Color(0xFFEF4444),
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

  Widget _buildCoverageSection() {
    return _buildSection(
      title: 'What\'s Covered',
      icon: Icons.account_balance_wallet_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            'Coverage Type',
            currentBursary.coverage.type.isNotEmpty
                ? '${currentBursary.coverage.type.toUpperCase()} Coverage'
                : 'Check details',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Amount',
            'R${currentBursary.coverage.amount ?? 'Not specified'}',
          ),
          if (currentBursary.coverage.covers.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Coverage Includes:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 8),
            ...currentBursary.coverage.covers.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(color: Color(0xFF2563EB)),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4B5563),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            const Text(
              'Please check application details for specific coverage information.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEligibilitySection() {
    return _buildSection(
      title: 'Eligibility Requirements',
      icon: Icons.checklist_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (currentBursary.eligibility.citizenship?.isNotEmpty == true)
            _buildInfoRow(
              'Citizenship',
              currentBursary.eligibility.citizenship ?? '',
            ),
          if (currentBursary.eligibility.maxAge != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              'Maximum Age',
              '${currentBursary.eligibility.maxAge} years',
            ),
          ],
          if (currentBursary
                  .eligibility
                  .academicRequirements
                  ?.minimumQualification
                  ?.isNotEmpty ==
              true) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              'Academic Requirements',
              currentBursary
                      .eligibility
                      .academicRequirements
                      ?.minimumQualification ??
                  '',
            ),
          ],
          if (currentBursary.eligibility.institutionType?.isNotEmpty ==
              true) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              'Institution Type',
              currentBursary.eligibility.institutionType!,
            ),
          ],
          if (currentBursary.eligibility.qualifications.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Additional Requirements:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 8),
            ...currentBursary.eligibility.qualifications.map(
              (qual) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(color: Color(0xFF2563EB)),
                    ),
                    Expanded(
                      child: Text(
                        qual,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4B5563),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (currentBursary.eligibility.qualifications.isEmpty &&
              currentBursary.eligibility.citizenship!.isEmpty) ...[
            const Text(
              'Please check application details for specific eligibility requirements.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildApplicationSection() {
    return _buildSection(
      title: 'How to Apply',
      icon: Icons.assignment_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (currentBursary.applicationProcess.method.isNotEmpty)
            _buildInfoRow(
              'Application Method',
              currentBursary.applicationProcess.method,
            ),
          if (currentBursary.applicationProcess.referenceNumber?.isNotEmpty ==
              true) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              'Reference Number',
              currentBursary.applicationProcess.referenceNumber!,
            ),
          ],
          if (currentBursary.applicationProcess.steps.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Application Steps:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 8),
            ...currentBursary.applicationProcess.steps.asMap().entries.map((
              entry,
            ) {
              int index = entry.key;
              String step = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        step,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4B5563),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          if (currentBursary.applicationProcess.applicationUrl?.isNotEmpty ==
              true) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () =>
                  _launchUrl(currentBursary.applicationProcess.applicationUrl!),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF5FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF2563EB).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.link, color: Color(0xFF2563EB), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Direct Application Link',
                        style: const TextStyle(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(
                      Icons.open_in_new,
                      color: Color(0xFF2563EB),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRequiredDocumentsSection() {
    if (currentBursary.requiredDocuments.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildSection(
      title: 'Required Documents',
      icon: Icons.description_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: currentBursary.requiredDocuments
            .map(
              (doc) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.document_scanner_outlined,
                      size: 16,
                      color: Color(0xFF2563EB),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        doc,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4B5563),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
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
        borderRadius: BorderRadius.circular(12),
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
                Icon(icon, size: 20, color: const Color(0xFF2563EB)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
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

  Widget _buildBottomActionBar(BursaryFinderNotifier notifier) {
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
                onPressed: () => _handleApplyNow(),
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

  void _handleApplyNow() {
    String? applicationUrl;

    // Try to find the best application URL
    if (currentBursary.applicationProcess.applicationUrl?.isNotEmpty == true) {
      applicationUrl = currentBursary.applicationProcess.applicationUrl;
    } else if (currentBursary.scraped.sourceUrl.isNotEmpty) {
      applicationUrl = currentBursary.scraped.sourceUrl;
    } else if (currentBursary.provider.website?.isNotEmpty == true) {
      applicationUrl = currentBursary.provider.website;
    }

    if (applicationUrl != null) {
      _launchUrl(applicationUrl);
    } else {
      _showErrorSnackBar('No application link available for this bursary');
    }
  }
}
