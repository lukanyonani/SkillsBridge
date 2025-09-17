import 'package:flutter/material.dart';
import 'package:skillsbridge/views/auth/login.dart';
import 'package:skillsbridge/views/main_screen.dart';
import 'package:skillsbridge/constants/theme.dart';
import 'dart:math' as math;

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Animation controllers
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _floatingController;
  late AnimationController _particleController;
  late AnimationController _buttonController;
  late AnimationController _backgroundController;
  late AnimationController _colorController;

  // Animations
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _buttonScaleAnimation;
  late Animation<double> _colorAnimation;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: "Welcome to SkillsBridge",
      subtitle: "Your Gateway to Career Success",
      description:
          "Bridge the gap between your potential and your dream career. Access thousands of job opportunities, educational resources, and funding options all in one place.",
      image: "🚀",
      gradient: [AppTheme.primaryBlue, AppTheme.secondaryBlue],
      accentColors: [AppTheme.lightBlue, AppTheme.veryLightBlue],
      particleColor: AppTheme.primaryBlue,
    ),
    OnboardingPage(
      title: "Discover & Learn",
      subtitle: "Unlock Your Potential",
      description:
          "Access free courses, get AI-powered career guidance, and develop the skills that employers are actively seeking in today's job market.",
      image: "📚",
      gradient: [AppTheme.successGreen, AppTheme.lightGreen],
      accentColors: [AppTheme.veryLightGreen, Color(0xFFECFDF5)],
      particleColor: AppTheme.successGreen,
    ),
    OnboardingPage(
      title: "Find Opportunities",
      subtitle: "Your Future Starts Here",
      description:
          "Get matched with relevant jobs, discover bursary opportunities, and receive personalized recommendations based on your skills and goals.",
      image: "💼",
      gradient: [AppTheme.purple, Color(0xFFA78BFA)],
      accentColors: [Color(0xFFF3E8FF), Color(0xFFFAF5FF)],
      particleColor: AppTheme.purple,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    // Slide animation for content
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    // Fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Scale animation for hero image
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Floating animation for hero
    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );
    _floatingAnimation = Tween<double>(begin: -15.0, end: 15.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    // Particle animation
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 8000),
      vsync: this,
    );
    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_particleController);

    // Button animation
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );

    // Background animation
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 12000),
      vsync: this,
    );

    // Color transition animation
    _colorController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _colorAnimation = CurvedAnimation(
      parent: _colorController,
      curve: Curves.easeInOutCubic,
    );
  }

  void _startAnimations() {
    _slideController.forward();
    _fadeController.forward();
    _scaleController.forward();
    _floatingController.repeat(reverse: true);
    _particleController.repeat();
    _backgroundController.repeat();
    _colorController.forward();
  }

  void _resetAnimationsForPage() {
    _slideController.reset();
    _fadeController.reset();
    _scaleController.reset();
    _colorController.reset();

    Future.delayed(const Duration(milliseconds: 100), () {
      _slideController.forward();
      _fadeController.forward();
      _scaleController.forward();
      _colorController.forward();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _floatingController.dispose();
    _particleController.dispose();
    _buttonController.dispose();
    _backgroundController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
    _resetAnimationsForPage();
  }

  void _nextPage() async {
    await _buttonController.forward();
    _buttonController.reverse();

    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _completeOnboarding() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOutCubic,
                  ),
                ),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  void _skipOnboarding() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainNavigationScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic),
            ),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _pages[_currentPage].accentColors,
          ),
        ),
        child: Stack(
          children: [
            _buildColorfulParticles(),
            SafeArea(
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
          ],
        ),
      ),
    );
  }

  Widget _buildColorfulParticles() {
    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        return Stack(
          children: List.generate(12, (index) {
            final animation = (_particleAnimation.value + index * 0.1) % 1.0;
            final colors = _pages[_currentPage].gradient;
            final accentColors = _pages[_currentPage].accentColors;

            return Positioned(
              left:
                  (MediaQuery.of(context).size.width / 12) * index +
                  40 * math.sin(animation * 2 * math.pi + index),
              top:
                  (MediaQuery.of(context).size.height / 6) * (index % 3) +
                  30 * math.cos(animation * 2 * math.pi + index * 0.7),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                child: Transform.rotate(
                  angle: animation * 2 * math.pi,
                  child: Container(
                    width: 15 + (index % 4 * 8),
                    height: 15 + (index % 4 * 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colors[index % 2].withValues(alpha: 0.3),
                          accentColors[index % 2].withValues(alpha: 0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(
                        index % 3 == 0 ? 0 : (index % 3 == 1 ? 8 : 20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colors[index % 2].withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: Offset(
                            2 * math.sin(animation * 2 * math.pi),
                            2 * math.cos(animation * 2 * math.pi),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  // Widget _buildRippleEffects() {
  //   return AnimatedBuilder(
  //     animation: _rippleAnimation,
  //     builder: (context, child) {
  //       return CustomPaint(
  //         painter: RipplePainter(
  //           _rippleAnimation.value,
  //           _pages[_currentPage].particleColor,
  //         ),
  //         size: Size.infinite,
  //       );
  //     },
  //   );
  // }

  Widget _buildTopBar() {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
          .animate(
            CurvedAnimation(
              parent: _fadeController,
              curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
            ),
          ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentPage > 0)
                AnimatedScale(
                  scale: 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: GestureDetector(
                    onTap: _previousPage,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.9),
                            Colors.white.withValues(alpha: 0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: _pages[_currentPage].particleColor
                                .withValues(alpha: 0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: _pages[_currentPage].particleColor,
                        size: 22,
                      ),
                    ),
                  ),
                )
              else
                const SizedBox(width: 44),
              _buildAnimatedPageIndicator(),
              GestureDetector(
                onTap: _skipOnboarding,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 14,
                      color: _pages[_currentPage].particleColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedPageIndicator() {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            _pages.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 36 : 10,
              height: 10,
              decoration: BoxDecoration(
                gradient: _currentPage == index
                    ? LinearGradient(colors: _pages[_currentPage].gradient)
                    : null,
                color: _currentPage != index
                    ? Colors.white.withValues(alpha: 0.4)
                    : null,
                borderRadius: BorderRadius.circular(5),
                boxShadow: _currentPage == index
                    ? [
                        BoxShadow(
                          color: _pages[_currentPage].particleColor.withValues(
                            alpha: 0.4,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight:
              MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              MediaQuery.of(context).padding.bottom -
              200, // Account for top bar and bottom section
        ),
        child: Column(
          children: [
            const SizedBox(height: 40),
            _buildAnimatedHeroSection(page),
            const SizedBox(height: 40), // Reduced from 60
            _buildAnimatedContentSection(page),
            const SizedBox(height: 40), // Added spacing instead of Spacer
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedHeroSection(OnboardingPage page) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleAnimation,
        _floatingAnimation,
        _colorAnimation,
      ]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatingAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.width * 0.7,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: page.gradient,
                ),
                borderRadius: BorderRadius.circular(150),
                boxShadow: [
                  BoxShadow(
                    color: page.gradient[0].withValues(alpha: 0.4),
                    blurRadius: 50,
                    offset: const Offset(0, 25),
                  ),
                  BoxShadow(
                    color: page.gradient[1].withValues(alpha: 0.3),
                    blurRadius: 80,
                    offset: const Offset(0, 40),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.1),
                    blurRadius: 30,
                    offset: const Offset(0, -15),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Animated background rings
                  ...List.generate(4, (index) {
                    return AnimatedBuilder(
                      animation: _particleAnimation,
                      builder: (context, child) {
                        final animationValue =
                            (_particleAnimation.value + index * 0.25) % 1.0;
                        return Positioned.fill(
                          child: Transform.scale(
                            scale: 0.6 + (animationValue * 0.4),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(
                                    alpha: 0.15 * (1 - animationValue),
                                  ),
                                  width: 3,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),

                  // Main emoji with enhanced animation
                  AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 0.7 + (_scaleAnimation.value * 0.3),
                        child: Transform.rotate(
                          angle: math.sin(_floatingAnimation.value / 5) * 0.1,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              page.image,
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.25,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedContentSection(OnboardingPage page) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _fadeController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        page.title,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: page.particleColor,
                          height: 1.2,
                          shadows: [
                            Shadow(
                              color: page.particleColor.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            AnimatedBuilder(
              animation: _fadeController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 30 * (1 - _fadeAnimation.value)),
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.9),
                            Colors.white.withValues(alpha: 0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: page.particleColor.withValues(alpha: 0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Text(
                        page.subtitle,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: page.particleColor,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            AnimatedBuilder(
              animation: _fadeController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 40 * (1 - _fadeAnimation.value)),
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        page.description,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.gray700,
                          height: 1.6,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
          .animate(
            CurvedAnimation(
              parent: _fadeController,
              curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
            ),
          ),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: _fadeController,
          curve: const Interval(0.7, 1.0, curve: Curves.easeInOut),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  if (_currentPage < _pages.length - 1) ...[
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: OutlinedButton(
                          onPressed: _skipOnboarding,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            side: BorderSide(
                              color: _pages[_currentPage].particleColor
                                  .withValues(alpha: 0.3),
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.9,
                            ),
                          ),
                          child: Text(
                            'Skip for now',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _pages[_currentPage].particleColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    child: ScaleTransition(
                      scale: _buttonScaleAnimation,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            elevation: 12,
                            shadowColor: _pages[_currentPage].particleColor
                                .withValues(alpha: 0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            backgroundColor: _pages[_currentPage].particleColor,
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _currentPage == _pages.length - 1
                                          ? 'Get Started'
                                          : 'Continue',
                                      key: ValueKey(
                                        _currentPage == _pages.length - 1,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Enhanced Custom Painter for Background Effects
class EnhancedBackgroundPainter extends CustomPainter {
  final double animationValue;
  final Color primaryColor;
  final List<Color> accentColors;

  EnhancedBackgroundPainter(
    this.animationValue,
    this.primaryColor,
    this.accentColors,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;

    final Paint strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Create flowing gradient waves
    for (int wave = 0; wave < 3; wave++) {
      final Path wavePath = Path();
      final double waveY = size.height * (0.2 + wave * 0.3);

      wavePath.moveTo(0, waveY);

      for (double x = 0; x <= size.width; x += 15) {
        final double y =
            waveY +
            25 * math.sin((x / 40 + animationValue * 1.5 + wave) * math.pi);
        wavePath.lineTo(x, y);
      }

      paint.color = accentColors[wave % accentColors.length].withValues(
        alpha: 0.1,
      );
      strokePaint.color = primaryColor.withValues(alpha: 0.1);

      canvas.drawPath(wavePath, strokePaint);
    }

    // Create floating gradient orbs
    for (int i = 0; i < 8; i++) {
      final double x =
          (size.width / 8) * i +
          50 * math.sin(animationValue * 2 * math.pi + i * 0.7);
      final double y =
          (size.height / 4) * (i % 2) +
          30 * math.cos(animationValue * 2 * math.pi + i * 0.5);

      final double radius = 15 + 8 * math.sin(animationValue * 2 * math.pi + i);

      paint.shader = RadialGradient(
        colors: [
          primaryColor.withValues(alpha: 0.2),
          accentColors[i % accentColors.length].withValues(alpha: 0.1),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(x, y), radius: radius * 2));

      canvas.drawCircle(Offset(x, y), radius * 2, paint);
    }
  }

  @override
  bool shouldRepaint(EnhancedBackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.primaryColor != primaryColor;
  }
}

// Ripple Effect Painter
class RipplePainter extends CustomPainter {
  final double animationValue;
  final Color color;

  RipplePainter(this.animationValue, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final center = Offset(size.width * 0.5, size.height * 0.4);

    // Create multiple ripples
    for (int i = 0; i < 3; i++) {
      final double progress = (animationValue + i * 0.3) % 1.0;
      final double radius = progress * size.width * 0.8;
      final double opacity = (1 - progress) * 0.3;

      paint.color = color.withValues(alpha: opacity);

      if (radius > 0 && opacity > 0) {
        canvas.drawCircle(center, radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(RipplePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final String image;
  final List<Color> gradient;
  final List<Color> accentColors;
  final Color particleColor;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.image,
    required this.gradient,
    required this.accentColors,
    required this.particleColor,
  });
}
