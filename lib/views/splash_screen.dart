import 'package:flutter/material.dart';
import 'package:skillsbridge/views/onboarding/onboarding.dart';
import 'dart:async';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _backgroundController;
  late AnimationController _textController;
  late AnimationController _slideController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    // Fade animation for logo
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    // Scale animation for logo entrance
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Subtle rotation animation
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 8000),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    // Pulse animation for breathing effect
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Background particle animation
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 15000),
      vsync: this,
    );
    _backgroundAnimation = CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.linear,
    );

    // Text animation
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _textFadeAnimation = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeInOut,
    );

    // Slide animation for text
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );
  }

  void _startAnimationSequence() async {
    // Start background animation immediately
    _backgroundController.repeat();

    // Delay then start logo animations
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();
    _scaleController.forward();

    // Start subtle rotation
    await Future.delayed(const Duration(milliseconds: 800));
    _rotationController.repeat();

    // Start pulsing effect
    await Future.delayed(const Duration(milliseconds: 500));
    _pulseController.repeat(reverse: true);

    // Start text animations
    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();
    _slideController.forward();

    // Navigate after total duration
    Timer(const Duration(seconds: 3), () {
      _navigateToOnboarding();
    });
  }

  void _navigateToOnboarding() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const OnboardingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
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
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    _backgroundController.dispose();
    _textController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2563EB), Color(0xFF3B82F6), Color(0xFF1D4ED8)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated background
            _buildAnimatedBackground(),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated logo
                  _buildAnimatedLogo(),

                  const SizedBox(height: 40),

                  // Animated text
                  _buildAnimatedText(),

                  const SizedBox(height: 20),

                  // Loading indicator
                  _buildLoadingIndicator(),
                ],
              ),
            ),

            // Floating particles
            //_buildFloatingParticles(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: SplashBackgroundPainter(_backgroundAnimation.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _fadeAnimation,
        _scaleAnimation,
        _rotationAnimation,
        _pulseAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value * _pulseAnimation.value,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(36),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedText() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _textFadeAnimation,
        child: Column(
          children: [
            const Text(
              'SkillsBridge',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'From Learning to Earning',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.9),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return FadeTransition(
      opacity: _textFadeAnimation,
      child: Container(
        margin: const EdgeInsets.only(top: 20),
        child: SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.white.withOpacity(0.8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Stack(
          children: List.generate(8, (index) {
            final animation = (_backgroundAnimation.value + index * 0.2) % 1.0;
            final x =
                (MediaQuery.of(context).size.width / 8) * index +
                50 * math.sin(animation * 2 * math.pi);
            final y =
                (MediaQuery.of(context).size.height / 4) * (index % 2) +
                30 * math.cos(animation * 2 * math.pi);

            return Positioned(
              left: x,
              top: y,
              child: Transform.rotate(
                angle: animation * 2 * math.pi,
                child: Container(
                  width: 20 + (index % 3 * 10),
                  height: 20 + (index % 3 * 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      index % 2 == 0 ? 0 : 10,
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
}

// Custom Painter for Background Effects
class SplashBackgroundPainter extends CustomPainter {
  final double animationValue;

  SplashBackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    final Paint strokePaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Create ripple effects
    for (int i = 0; i < 3; i++) {
      final double radius = (animationValue + i * 0.3) * size.width;
      final center = Offset(size.width * 0.5, size.height * 0.5);

      if (radius < size.width) {
        canvas.drawCircle(center, radius, strokePaint);
      }
    }

    // Create floating orbs
    for (int i = 0; i < 12; i++) {
      final double x =
          (size.width / 12) * i +
          60 * math.sin(animationValue * 2 * math.pi + i * 0.5);
      final double y =
          (size.height / 6) * (i % 3) +
          40 * math.cos(animationValue * 2 * math.pi + i * 0.3);

      final double radius = 8 + 4 * math.sin(animationValue * 2 * math.pi + i);

      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Create flowing waves
    final Path wavePath = Path();
    for (int wave = 0; wave < 2; wave++) {
      // final double waveY = size.height * (0.3 + wave * 0.4);
      // wavePath.moveTo(0, waveY);

      // for (double x = 0; x <= size.width; x += 20) {
      //   final double y =
      //       waveY +
      //       20 * math.sin((x / 60 + animationValue * 2) * math.pi + wave);
      //   wavePath.lineTo(x, y);
      // }
    }

    canvas.drawPath(wavePath, strokePaint);
  }

  @override
  bool shouldRepaint(SplashBackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
