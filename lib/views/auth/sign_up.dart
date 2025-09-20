import 'package:flutter/material.dart';
import 'package:skillsbridge/views/auth/login.dart';
import 'package:skillsbridge/views/onboarding/getting_started_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = false;
  bool _isLoading = false;

  // Animation Controllers
  late AnimationController _headerController;
  late AnimationController _formController;
  late AnimationController _socialController;
  late AnimationController _buttonController;
  late AnimationController _fieldController;

  // Animations
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _formSlideAnimation;
  late Animation<double> _formFadeAnimation;
  late Animation<Offset> _socialSlideAnimation;
  late Animation<double> _socialFadeAnimation;
  late Animation<double> _buttonScaleAnimation;
  late Animation<double> _fieldFadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    // Header animations
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _headerSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _headerController,
            curve: Curves.easeOutCubic,
          ),
        );
    _headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeInOut),
    );

    // Form animations
    _formController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _formSlideAnimation =
        Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero).animate(
          CurvedAnimation(parent: _formController, curve: Curves.easeOutCubic),
        );
    _formFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _formController, curve: Curves.easeInOut),
    );

    // Social section animations
    _socialController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _socialSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _socialController,
            curve: Curves.easeOutCubic,
          ),
        );
    _socialFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _socialController, curve: Curves.easeInOut),
    );

    // Button scale animation
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );

    // Field animation controller
    _fieldController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fieldFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fieldController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() {
    _headerController.forward();

    Future.delayed(const Duration(milliseconds: 200), () {
      _formController.forward();
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      _socialController.forward();
    });

    _fieldController.forward();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _headerController.dispose();
    _formController.dispose();
    _socialController.dispose();
    _buttonController.dispose();
    _fieldController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    });
  }

  void _toggleTermsAgreement(bool? value) {
    setState(() {
      _agreeToTerms = value ?? false;
    });
  }

  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate() && _agreeToTerms) {
      // Button press animation
      await _buttonController.forward();
      await _buttonController.reverse();

      setState(() {
        _isLoading = true;
      });

      // Simulate signup process
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });

      // Navigate to questionnaire for new users
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const GettingStartedScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
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
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    } else if (!_agreeToTerms) {
      // Shake animation for terms checkbox
      _buttonController.forward().then((_) => _buttonController.reverse());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms of Service'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF374151)),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildAnimatedHeader(),
                const SizedBox(height: 40),
                _buildAnimatedSignUpForm(),
                const SizedBox(height: 32),
                _buildAnimatedSocialSignUp(),
                const SizedBox(height: 32),
                _buildAnimatedLoginPrompt(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    return SlideTransition(
      position: _headerSlideAnimation,
      child: FadeTransition(
        opacity: _headerFadeAnimation,
        child: _buildHeader(),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Text(
          'Create Account',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Join SkillsBridge and start your career journey',
          style: TextStyle(fontSize: 16, color: Color(0xFF6B7280), height: 1.4),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAnimatedSignUpForm() {
    return SlideTransition(
      position: _formSlideAnimation,
      child: FadeTransition(
        opacity: _formFadeAnimation,
        child: _buildSignUpForm(),
      ),
    );
  }

  Widget _buildSignUpForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildStaggeredRow(
            children: [
              Expanded(child: _buildFirstNameField()),
              const SizedBox(width: 16),
              Expanded(child: _buildLastNameField()),
            ],
            delay: 0,
          ),
          const SizedBox(height: 20),
          _buildStaggeredField(_buildEmailField(), 1),
          const SizedBox(height: 20),
          _buildStaggeredField(_buildPasswordField(), 2),
          const SizedBox(height: 20),
          _buildStaggeredField(_buildConfirmPasswordField(), 3),
          const SizedBox(height: 16),
          _buildStaggeredField(_buildTermsAgreement(), 4),
          const SizedBox(height: 32),
          _buildStaggeredField(_buildSignUpButton(), 5),
        ],
      ),
    );
  }

  Widget _buildStaggeredRow({
    required List<Widget> children,
    required int delay,
  }) {
    return AnimatedBuilder(
      animation: _fieldFadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(30 * (1 - _fieldFadeAnimation.value), 0),
          child: Opacity(
            opacity: _fieldFadeAnimation.value,
            child: Row(children: children),
          ),
        );
      },
    );
  }

  Widget _buildStaggeredField(Widget field, int index) {
    return AnimatedBuilder(
      animation: _fieldFadeAnimation,
      builder: (context, child) {
        final adjustedAnimation = Interval(
          (index * 0.1).clamp(0.0, 1.0),
          1.0,
          curve: Curves.easeOutCubic,
        ).transform(_fieldFadeAnimation.value);

        return Transform.translate(
          offset: Offset(50 * (1 - adjustedAnimation), 0),
          child: Opacity(opacity: adjustedAnimation, child: field),
        );
      },
    );
  }

  Widget _buildFirstNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'First Name',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        _buildAnimatedTextField(
          controller: _firstNameController,
          hintText: 'First name',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLastNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Last Name',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        _buildAnimatedTextField(
          controller: _lastNameController,
          hintText: 'Last name',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        _buildAnimatedTextField(
          controller: _emailController,
          hintText: 'Enter your email',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(
            Icons.email_outlined,
            color: Color(0xFF9CA3AF),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        _buildAnimatedTextField(
          controller: _passwordController,
          hintText: 'Create a password',
          obscureText: !_isPasswordVisible,
          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF9CA3AF)),
          suffixIcon: IconButton(
            onPressed: _togglePasswordVisibility,
            icon: Icon(
              _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
              color: const Color(0xFF9CA3AF),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a password';
            }
            if (value.length < 8) {
              return 'Password must be at least 8 characters';
            }
            if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
              return 'Password must contain uppercase, lowercase, and number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Confirm Password',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        _buildAnimatedTextField(
          controller: _confirmPasswordController,
          hintText: 'Confirm your password',
          obscureText: !_isConfirmPasswordVisible,
          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF9CA3AF)),
          suffixIcon: IconButton(
            onPressed: _toggleConfirmPasswordVisibility,
            icon: Icon(
              _isConfirmPasswordVisible
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: const Color(0xFF9CA3AF),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm your password';
            }
            if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? prefixIcon,
    Widget? suffixIcon,
    required String? Function(String?) validator,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscureText,
              decoration: InputDecoration(
                hintText: hintText,
                prefixIcon: prefixIcon,
                suffixIcon: suffixIcon,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF2563EB),
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFEF4444)),
                ),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              validator: validator,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTermsAgreement() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.9 + (0.1 * value),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 20,
                height: 20,
                child: Transform.scale(
                  scale: _agreeToTerms ? 1.1 : 1.0,
                  child: Checkbox(
                    value: _agreeToTerms,
                    onChanged: _toggleTermsAgreement,
                    activeColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      height: 1.4,
                    ),
                    children: [
                      TextSpan(text: 'I agree to the '),
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSignUpButton() {
    return ScaleTransition(
      scale: _buttonScaleAnimation,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleSignUp,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            elevation: _isLoading ? 0 : 4,
            shadowColor: const Color(0xFF2563EB).withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            disabledBackgroundColor: const Color(0xFF9CA3AF),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Create Account',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSocialSignUp() {
    return SlideTransition(
      position: _socialSlideAnimation,
      child: FadeTransition(
        opacity: _socialFadeAnimation,
        child: _buildSocialSignUp(),
      ),
    );
  }

  Widget _buildSocialSignUp() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(height: 1, color: const Color(0xFFE5E7EB)),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Or sign up with',
                style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
            ),
            Expanded(
              child: Container(height: 1, color: const Color(0xFFE5E7EB)),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _buildAnimatedSocialButton(
                'Google',
                Icons.g_mobiledata,
                () {},
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildAnimatedSocialButton('Apple', Icons.apple, () {}),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnimatedSocialButton(
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 56,
            child: OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, color: const Color(0xFF374151), size: 20),
              label: Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.white,
                elevation: 2,
                shadowColor: Colors.black.withOpacity(0.1),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedLoginPrompt() {
    return SlideTransition(
      position: _socialSlideAnimation,
      child: FadeTransition(
        opacity: _socialFadeAnimation,
        child: _buildLoginPrompt(),
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Already have an account? ",
                  style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
