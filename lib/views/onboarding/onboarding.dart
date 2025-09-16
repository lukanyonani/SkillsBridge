import 'package:flutter/material.dart';
import 'package:skillsbridge/views/main_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: "Welcome to SkillsBridge",
      subtitle: "Your Gateway to Career Success",
      description:
          "Bridge the gap between your potential and your dream career. Access thousands of job opportunities, educational resources, and funding options all in one place.",
      image: "🚀",
      gradient: [Color(0xFF2563EB), Color(0xFF3B82F6)],
    ),
    OnboardingPage(
      title: "Discover & Learn",
      subtitle: "Unlock Your Potential",
      description:
          "Access free courses, get AI-powered career guidance, and develop the skills that employers are actively seeking in today's job market.",
      image: "📚",
      gradient: [Color(0xFF10B981), Color(0xFF34D399)],
    ),
    OnboardingPage(
      title: "Find Opportunities",
      subtitle: "Your Future Starts Here",
      description:
          "Get matched with relevant jobs, discover bursary opportunities, and receive personalized recommendations based on your skills and goals.",
      image: "💼",
      gradient: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeOnboarding() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
    );
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            GestureDetector(
              onTap: _previousPage,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFF6B7280),
                  size: 20,
                ),
              ),
            )
          else
            const SizedBox(width: 40),
          _buildPageIndicator(),
          GestureDetector(
            onTap: _skipOnboarding,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Skip',
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        _pages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? const Color(0xFF2563EB)
                : const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 40),
          _buildHeroSection(page),
          const SizedBox(height: 60),
          _buildContentSection(page),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildHeroSection(OnboardingPage page) {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: page.gradient,
        ),
        borderRadius: BorderRadius.circular(140),
        boxShadow: [
          BoxShadow(
            color: page.gradient[0].withOpacity(0.3),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Center(
        child: Text(page.image, style: const TextStyle(fontSize: 120)),
      ),
    );
  }

  Widget _buildContentSection(OnboardingPage page) {
    return Column(
      children: [
        Text(
          page.title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          page.subtitle,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: page.gradient[0],
            height: 1.3,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Text(
          page.description,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF6B7280),
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          //if (_currentPage == _pages.length - 1) _buildGetStartedSection(),
          const SizedBox(height: 16),
          Row(
            children: [
              if (_currentPage < _pages.length - 1) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: _skipOnboarding,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Skip for now',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F7AFF),
                    foregroundColor: Color(0xFF2D5CFF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1
                        ? 'Get Started'
                        : 'Continue',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget _buildGetStartedSection() {
  //   return Container(
  //     width: double.infinity,
  //     padding: const EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       gradient: const LinearGradient(
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //         colors: [Color(0xFFF0F9FF), Color(0xFFE0F2FE)],
  //       ),
  //       borderRadius: BorderRadius.circular(16),
  //       border: Border.all(color: const Color(0xFFDBEAFE)),
  //     ),
  //     child: Column(
  //       children: [
  //         // Row(
  //         //   mainAxisAlignment: MainAxisAlignment.center,
  //         //   children: [
  //         //     _buildFeatureIcon('🎯', 'Personalized'),
  //         //     const SizedBox(width: 20),
  //         //     _buildFeatureIcon('🔒', 'Secure'),
  //         //     const SizedBox(width: 20),
  //         //     _buildFeatureIcon('⚡', 'Fast'),
  //         //   ],
  //         // ),
  //         // const SizedBox(height: 12),
  //         // const Text(
  //         //   'Join thousands of learners already transforming their careers',
  //         //   style: TextStyle(
  //         //     fontSize: 14,
  //         //     color: Color(0xFF4B5563),
  //         //     fontWeight: FontWeight.w500,
  //         //   ),
  //         //   textAlign: TextAlign.center,
  //         // ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildFeatureIcon(String emoji, String label) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final String image;
  final List<Color> gradient;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.image,
    required this.gradient,
  });
}
