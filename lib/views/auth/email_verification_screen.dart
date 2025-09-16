import 'package:flutter/material.dart';
import 'dart:async';
import 'package:skillsbridge/views/auth/success_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({super.key, required this.email});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  late Timer _timer;
  int _resendCooldown = 0;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _startResendCooldown();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startResendCooldown() {
    setState(() {
      _resendCooldown = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCooldown > 0) {
          _resendCooldown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  Future<void> _handleResendEmail() async {
    if (_resendCooldown == 0) {
      // Simulate resending email
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification email sent!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      _startResendCooldown();
    }
  }

  Future<void> _handleVerifyManually() async {
    setState(() {
      _isVerifying = true;
    });

    // Simulate verification process
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isVerifying = false;
    });

    // Navigate to success screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const SuccessScreen(
          title: 'Email Verified!',
          message:
              'Your email has been successfully verified. Welcome to SkillsBridge!',
          buttonText: 'Continue to App',
        ),
      ),
    );
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
                const SizedBox(height: 40),
                _buildHeader(),
                const SizedBox(height: 48),
                _buildEmailInfo(),
                const SizedBox(height: 32),
                _buildInstructions(),
                const SizedBox(height: 32),
                _buildActionButtons(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
            ),
            borderRadius: BorderRadius.circular(40),
          ),
          child: const Icon(
            Icons.mark_email_read,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Check Your Email',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'We sent a verification link to your email address.',
          style: TextStyle(fontSize: 16, color: Color(0xFF6B7280), height: 1.4),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmailInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Column(
        children: [
          const Icon(Icons.email, color: Color(0xFF2563EB), size: 24),
          const SizedBox(height: 8),
          Text(
            widget.email,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Column(
      children: [
        const Text(
          'Please check your email and click the verification link to activate your account.',
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280), height: 1.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: Color(0xFFF59E0B),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Didn\'t receive the email? Check your spam folder.',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF92400E),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isVerifying ? null : _handleVerifyManually,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: const Color(0xFF9CA3AF),
            ),
            child: _isVerifying
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'I\'ve Verified My Email',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: _resendCooldown == 0 ? _handleResendEmail : null,
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: _resendCooldown == 0
                    ? const Color(0xFF2563EB)
                    : const Color(0xFFE5E7EB),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Colors.white,
            ),
            child: Text(
              _resendCooldown > 0
                  ? 'Resend Email ($_resendCooldown s)'
                  : 'Resend Email',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _resendCooldown == 0
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF9CA3AF),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
