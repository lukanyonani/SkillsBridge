import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  int currentNavIndex = 4; // Profile tab is active
  double profileCompletion = 1.0;

  late AnimationController _progressAnimationController;
  bool showAddSkillModal = false;

  @override
  void initState() {
    super.initState();
    _progressAnimationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    // Start animation after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _progressAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _progressAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              //_buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeader(),
                      _buildProfileSection(),
                      _buildCompletionScore(),
                      _buildAchievementsSection(),
                      _buildDocumentsSection(),
                      SizedBox(height: 100), // Space for bottom nav
                    ],
                  ),
                ),
              ),
            ],
          ),
          //if (showAddSkillModal) _buildAddSkillModal(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
        ),
      ),
      child: SafeArea(
        child: Container(
          padding: EdgeInsets.fromLTRB(2, 20, 20, 80),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Back arrow
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context); // Go back
                },
              ),
              // Title
              Text(
                'My Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Transform.translate(
      offset: Offset(0, -50),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFDBEAFE), Colors.white],
                    ),
                    borderRadius: BorderRadius.circular(60),
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/profile.jpeg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Photo editor would open here')),
                      );
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Center(
                        child: Text('✏️', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Lukanyo Nani',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('📍', style: TextStyle(fontSize: 14)),
                SizedBox(width: 4),
                Text(
                  'Gqheberha, Eastern Cape',
                  style: TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionScore() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Profile Completion',
            style: TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
          ),
          SizedBox(height: 8),
          Text(
            '${(profileCompletion * 100).round()}%',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2563EB),
            ),
          ),
          SizedBox(height: 8),
          AnimatedBuilder(
            animation: _progressAnimationController,
            builder: (context, child) {
              return Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor:
                      profileCompletion * _progressAnimationController.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF10B981)],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection() {
    final achievements = [
      Achievement(
        icon: '🏆',
        title: 'First Job Match',
        date: 'Dec 2024',
        isNew: true,
      ),
      Achievement(icon: '🎓', title: 'Course Complete', date: 'Nov 2024'),
      Achievement(icon: '💼', title: '10 Applications', date: 'Dec 2024'),
      Achievement(icon: '🌟', title: 'Skills Master', date: 'Oct 2024'),
      Achievement(
        icon: '🚀',
        title: 'Job Ready',
        date: 'Locked',
        isLocked: true,
      ),
      Achievement(
        icon: '👑',
        title: 'Top Performer',
        date: 'Locked',
        isLocked: true,
      ),
      Achievement(
        icon: '🎯',
        title: 'Goal Crusher',
        date: 'Locked',
        isLocked: true,
      ),
      Achievement(
        icon: '💎',
        title: 'Premium User',
        date: 'Locked',
        isLocked: true,
      ),
    ];

    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Achievements',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'See All',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              return _buildAchievementCard(achievements[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return GestureDetector(
      onTap: () {
        if (achievement.isLocked) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Complete more activities to unlock this achievement!',
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Achievement: ${achievement.title}\nEarned: ${achievement.date}',
              ),
            ),
          );
        }
      },
      child: Stack(
        children: [
          Container(
            width: 200,
            //padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: achievement.isLocked
                  ? Color(0xFFF9FAFB).withOpacity(0.5)
                  : Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(achievement.icon, style: TextStyle(fontSize: 32)),
                SizedBox(height: 8),
                Text(
                  achievement.title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: achievement.isLocked
                        ? Color(0xFF9CA3AF)
                        : Color(0xFF374151),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  achievement.date,
                  style: TextStyle(
                    fontSize: 10,
                    color: achievement.isLocked
                        ? Color(0xFF9CA3AF)
                        : Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCareerProgressSection() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Career Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF9FAFB), Color(0xFFDBEAFE)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your Journey',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    Text(
                      '60%',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                AnimatedBuilder(
                  animation: _progressAnimationController,
                  builder: (context, child) {
                    return Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor:
                                0.6 * _progressAnimationController.value,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF2563EB),
                                    Color(0xFF10B981),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                          Positioned(
                            right:
                                MediaQuery.of(context).size.width *
                                0.4 *
                                (1 - _progressAnimationController.value),
                            top: -4,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Color(0xFF10B981),
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMilestone('12', 'Skills Gained'),
                    _buildMilestone('3', 'Courses Done'),
                    _buildMilestone('5', 'Applications'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestone(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Color(0xFF4B5563)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDocumentsSection() {
    final documents = [
      Document(
        icon: '📄',
        title: 'My CV',
        subtitle: 'Updated 2 days ago • PDF',
      ),
      Document(
        icon: '🎓',
        title: 'Higher Certificate',
        subtitle: 'Nelson Mandela University • 2022',
        backgroundColor: Color(0xFFFEF3C7),
      ),
      Document(
        icon: '📜',
        title: 'Python Certificate',
        subtitle: 'Python Institue • 2022',
        backgroundColor: Color(0xFFD1FAE5),
      ),
    ];

    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Documents',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'Manage',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Column(
            children: [
              ...documents.map((doc) => _buildDocumentCard(doc)).toList(),
              _buildUploadDocumentCard(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(Document document) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: document.backgroundColor ?? Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(document.icon, style: TextStyle(fontSize: 24)),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  document.subtitle,
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: Color(0xFF2563EB), size: 20),
        ],
      ),
    );
  }

  Widget _buildUploadDocumentCard() {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload functionality would open file picker'),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFFF9FAFB),
          border: Border.all(
            color: Color(0xFFD1D5DB),
            width: 2,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Text('📤', style: TextStyle(fontSize: 24)),
                SizedBox(height: 8),
                Text(
                  'Upload Document',
                  style: TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Data Models
class Skill {
  final String name;
  final int level; // 1-4

  Skill({required this.name, required this.level});
}

class Achievement {
  final String icon;
  final String title;
  final String date;
  final bool isLocked;
  final bool isNew;

  Achievement({
    required this.icon,
    required this.title,
    required this.date,
    this.isLocked = false,
    this.isNew = false,
  });
}

class Document {
  final String icon;
  final String title;
  final String subtitle;
  final Color? backgroundColor;

  Document({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.backgroundColor,
  });
}

class Stat {
  final String value;
  final String label;
  final String trend;

  Stat({required this.value, required this.label, required this.trend});
}

class BottomNavItem {
  final String icon;
  final String label;

  BottomNavItem({required this.icon, required this.label});
}
