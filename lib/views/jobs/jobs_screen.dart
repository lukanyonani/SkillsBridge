import 'package:flutter/material.dart';

class JobPortalScreen extends StatefulWidget {
  const JobPortalScreen({super.key});

  @override
  State<JobPortalScreen> createState() => _JobPortalScreenState();
}

class _JobPortalScreenState extends State<JobPortalScreen> {
  int _savedJobsCount = 3;
  String _searchQuery = '';
  String _locationQuery = 'Cape Town';
  String _sortOption = 'Relevance';
  int _jobsCount = 123;

  final Set<String> _activeFilters = {'All Jobs'};
  final Set<int> _savedJobs = {2}; // Third job is saved by default
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  bool _showDetail = false;
  Map<String, dynamic>? _selectedJob;

  @override
  void initState() {
    super.initState();
    _locationController.text = _locationQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _jobs = [
    {
      'id': 0,
      'title': 'Junior Software Developer',
      'company': 'TechCorp South Africa',
      'logo': '🏢',
      'logoColor': const Color(0xFFF3F4F6),
      'location': 'Cape Town, WC',
      'salary': 'R15,000 - R20,000',
      'type': 'Hybrid',
      'workType': 'Full-time',
      'tags': ['JavaScript', 'React'],
      'isNew': true,
      'matchScore': 85,
      'matchLevel': 'high',
    },
    {
      'id': 1,
      'title': 'IT Support Specialist',
      'company': 'First National Bank',
      'logo': '🏦',
      'logoColor': const Color(0xFFFEF3C7),
      'location': 'Johannesburg, GP',
      'salary': 'R12,000 - R18,000',
      'type': 'On-site',
      'workType': 'Full-time',
      'tags': ['Help Desk', 'Windows'],
      'isNew': false,
      'matchScore': 78,
      'matchLevel': 'high',
    },
    {
      'id': 2,
      'title': 'Digital Marketing Intern',
      'company': 'Takealot.com',
      'logo': '📱',
      'logoColor': const Color(0xFFD1FAE5),
      'location': 'Cape Town, WC',
      'salary': 'R8,000 - R10,000',
      'type': 'Hybrid',
      'workType': 'Internship',
      'tags': ['Social Media', 'SEO'],
      'isNew': false,
      'matchScore': 72,
      'matchLevel': 'medium',
    },
    {
      'id': 3,
      'title': 'Data Analyst',
      'company': 'Discovery Limited',
      'logo': '📊',
      'logoColor': const Color(0xFFFEE2E2),
      'location': 'Sandton, GP',
      'salary': 'R25,000 - R35,000',
      'type': 'On-site',
      'workType': 'Full-time',
      'tags': ['SQL', 'Python', 'Excel'],
      'isNew': false,
      'matchScore': 68,
      'matchLevel': 'medium',
    },
    {
      'id': 4,
      'title': 'Full Stack Developer',
      'company': 'Afrihost',
      'logo': '💻',
      'logoColor': const Color(0xFFE0E7FF),
      'location': 'Remote',
      'salary': 'R30,000 - R45,000',
      'type': 'Remote',
      'workType': 'Full-time',
      'tags': ['Node.js', 'React', 'MongoDB'],
      'isNew': false,
      'matchScore': 62,
      'matchLevel': 'low',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: _showDetail ? _buildJobDetail() : _buildJobList(),
      //bottomNavigationBar: !_showDetail ? _buildBottomNavigation() : null,
    );
  }

  Widget _buildJobList() {
    return SafeArea(
      child: Column(
        children: [
          _buildTopHeader(),
          _buildHeader(),
          _buildResultsBar(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _jobs.length,
              itemBuilder: (context, index) => _buildJobCard(_jobs[index]),
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
          colors: [Color(0xFF2563EB), Color(0xFF3B82F6)], // Changed to blue
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
                        '$_savedJobsCount',
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

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 12),
          _buildSearchSection(),
          const SizedBox(height: 12),
          _buildFilterPills(),
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

  Widget _buildSearchSection() {
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
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _updateJobsCount();
                });
              },
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
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _locationController,
              onChanged: (value) {
                setState(() {
                  _locationQuery = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Location',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('📍', style: TextStyle(fontSize: 20)),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterPills() {
    final filters = [
      'All Jobs',
      'Remote',
      'Entry Level',
      'Full-time',
      'Internship',
      'R10k-20k',
      'Tech',
      'This Week',
    ];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isActive = _activeFilters.contains(filter);

          return Padding(
            padding: EdgeInsets.only(right: 8, left: index == 0 ? 0 : 0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (filter == 'All Jobs') {
                    _activeFilters.clear();
                    _activeFilters.add('All Jobs');
                  } else {
                    _activeFilters.remove('All Jobs');
                    if (isActive) {
                      _activeFilters.remove(filter);
                      if (_activeFilters.isEmpty) {
                        _activeFilters.add('All Jobs');
                      }
                    } else {
                      _activeFilters.add(filter);
                    }
                  }
                  _updateJobsCount();
                });
              },
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

  Widget _buildResultsBar() {
    return Container(
      color: const Color(0xFFF3F4F6),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$_jobsCount Jobs Found',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          GestureDetector(
            onTap: _showSortOptions,
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
                    'Sort: $_sortOption',
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

  Widget _buildJobCard(Map<String, dynamic> job) {
    final isSaved = _savedJobs.contains(job['id']);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedJob = job;
          _showDetail = true;
        });
      },
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
                            colors: _getMatchGradient(job['matchLevel']),
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
                onTap: () {
                  setState(() {
                    if (isSaved) {
                      _savedJobs.remove(job['id']);
                      _savedJobsCount--;
                    } else {
                      _savedJobs.add(job['id']);
                      _savedJobsCount++;
                    }
                  });
                },
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

  List<Color> _getMatchGradient(String level) {
    switch (level) {
      case 'high':
        return [const Color(0xFF10B981), const Color(0xFF34D399)];
      case 'medium':
        return [const Color(0xFFF59E0B), const Color(0xFFFBBF24)];
      case 'low':
        return [const Color(0xFF9CA3AF), const Color(0xFF6B7280)];
      default:
        return [const Color(0xFF10B981), const Color(0xFF34D399)];
    }
  }

  Widget _buildJobDetail() {
    if (_selectedJob == null) return Container();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildDetailHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildMatchAnalysis(),
                  _buildDetailBody(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildApplySection(),
    );
  }

  Widget _buildDetailHeader() {
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
                        _selectedJob!['logo'],
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _selectedJob!['title'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedJob!['company'],
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDetailMetaItem('📍', _selectedJob!['location']),
                      const SizedBox(width: 16),
                      _buildDetailMetaItem(
                        '💰',
                        _selectedJob!['salary'].split(' - ')[0],
                      ),
                      const SizedBox(width: 16),
                      _buildDetailMetaItem('🏠', _selectedJob!['type']),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 10,
              left: 20,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showDetail = false;
                    _selectedJob = null;
                  });
                },
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

  Widget _buildMatchAnalysis() {
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
                    '${_selectedJob!['matchScore']}%',
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

  Widget _buildDetailBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailSection(
            'About the Role',
            'We\'re looking for a passionate Junior Software Developer to join our growing team in Cape Town. This is an excellent opportunity for a recent graduate or someone with 0-2 years of experience to kick-start their career in tech.\n\nYou\'ll work alongside senior developers on exciting projects for South African and international clients, using modern technologies and best practices. We offer mentorship, continuous learning opportunities, and a clear path for career growth.\n\nOur hybrid work model allows for flexibility while maintaining team collaboration. You\'ll spend 2-3 days in our modern Cape Town office and the rest working from home.',
          ),
          const SizedBox(height: 24),
          _buildRequirementsSection(),
          const SizedBox(height: 24),
          _buildSkillsSection(),
          const SizedBox(height: 24),
          _buildDetailSection(
            'What We Offer',
            '• Competitive salary: R15,000 - R20,000 per month\n• Medical aid contribution\n• Annual performance bonus\n• Flexible hybrid working arrangement\n• Professional development budget\n• Mentorship from senior developers\n• Modern office in Cape Town CBD\n• Team building events and hackathons\n• Clear career progression path',
          ),
          const SizedBox(height: 24),
          _buildSimilarJobs(),
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

  Widget _buildRequirementsSection() {
    final requirements = [
      {
        'text': 'Bachelor\'s degree in Computer Science, IT, or related field',
        'status': 'met',
      },
      {
        'text':
            'Basic knowledge of JavaScript and modern frameworks (React/Vue/Angular)',
        'status': 'met',
      },
      {
        'text': 'Understanding of HTML, CSS, and responsive design',
        'status': 'met',
      },
      {'text': 'Experience with Git version control', 'status': 'partial'},
      {
        'text': 'Strong problem-solving skills and attention to detail',
        'status': 'met',
      },
      {
        'text': 'Knowledge of SQL and database concepts (training provided)',
        'status': 'unmet',
      },
      {'text': 'Excellent communication skills in English', 'status': 'met'},
      {
        'text': 'South African citizenship or valid work permit',
        'status': 'met',
      },
    ];

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
          (req) => _buildRequirementItem(
            req['text'] as String,
            req['status'] as String,
          ),
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

  Widget _buildSkillsSection() {
    final skills = [
      {'name': 'JavaScript', 'hasSkill': true},
      {'name': 'HTML/CSS', 'hasSkill': true},
      {'name': 'React', 'hasSkill': true},
      {'name': 'Git', 'hasSkill': false},
      {'name': 'SQL', 'hasSkill': false},
      {'name': 'Problem Solving', 'hasSkill': true},
      {'name': 'Team Work', 'hasSkill': true},
      {'name': 'Agile', 'hasSkill': false},
    ];

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

  Widget _buildSimilarJobs() {
    final similarJobs = [
      {
        'title': 'Frontend Developer',
        'company': 'Digital Agency',
        'location': 'Cape Town',
        'salary': 'R18k-25k',
        'match': 82,
      },
      {
        'title': 'Junior Web Developer',
        'company': 'StartupSA',
        'location': 'Remote',
        'salary': 'R14k-18k',
        'match': 79,
      },
      {
        'title': 'Graduate Developer Programme',
        'company': 'Standard Bank',
        'location': 'Johannesburg',
        'salary': 'R20k-25k',
        'match': 75,
      },
    ];

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

  Widget _buildApplySection() {
    final isSaved = _savedJobs.contains(_selectedJob?['id']);

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
              onTap: () {
                setState(() {
                  if (isSaved) {
                    _savedJobs.remove(_selectedJob!['id']);
                    _savedJobsCount--;
                  } else {
                    _savedJobs.add(_selectedJob!['id']);
                    _savedJobsCount++;
                  }
                });
              },
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
                onPressed: _applyForJob,
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

  void _updateJobsCount() {
    setState(() {
      if (_searchQuery.isNotEmpty) {
        _jobsCount = 10 + (_searchQuery.length * 5);
      } else {
        _jobsCount = 123 - (_activeFilters.length * 15);
      }
      _jobsCount = _jobsCount.clamp(10, 200);
    });
  }

  void _showSortOptions() {
    final options = ['Relevance', 'Date Posted', 'Salary', 'Match Score'];
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((option) {
              return ListTile(
                title: Text(option),
                trailing: _sortOption == option
                    ? const Icon(Icons.check, color: Color(0xFF2563EB))
                    : null,
                onTap: () {
                  setState(() {
                    _sortOption = option;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _applyForJob() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Applied for ${_selectedJob!['title']} at ${_selectedJob!['company']}',
        ),
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
