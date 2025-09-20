import 'package:flutter/material.dart';
import 'package:skillsbridge/constants/theme.dart';
import 'package:skillsbridge/views/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class GettingStartedScreen extends StatefulWidget {
  const GettingStartedScreen({super.key});

  @override
  State<GettingStartedScreen> createState() => _GettingStartedScreenState();
}

class _GettingStartedScreenState extends State<GettingStartedScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _progressController;
  late AnimationController _buttonController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _buttonScaleAnimation;

  // Form data
  final Map<String, dynamic> _formData = {};

  // Question steps
  final List<QuestionStep> _steps = [
    QuestionStep(
      title: "Let's get to know you",
      subtitle: "Basic Profile Information",
      questions: [
        Question(
          id: 'education',
          text: "What's your highest level of education?",
          type: QuestionType.singleChoice,
          options: [
            'High School Certificate',
            'Matric/Grade 12',
            'Certificate/Diploma',
            'Bachelor\'s Degree',
            'Honors/Postgraduate Diploma',
            'Master\'s Degree',
            'Doctoral Degree',
            'Other',
          ],
          required: true,
        ),
        Question(
          id: 'employment_status',
          text: "What's your current employment status?",
          type: QuestionType.singleChoice,
          options: [
            'Student',
            'Unemployed - seeking work',
            'Employed full-time',
            'Employed part-time',
            'Self-employed/Freelancer',
            'Recent graduate',
          ],
          required: true,
        ),
        Question(
          id: 'province',
          text: "Which province are you in?",
          type: QuestionType.singleChoice,
          options: [
            'Eastern Cape',
            'Free State',
            'Gauteng',
            'KwaZulu-Natal',
            'Limpopo',
            'Mpumalanga',
            'Northern Cape',
            'North West',
            'Western Cape',
          ],
          required: true,
        ),
      ],
    ),
    QuestionStep(
      title: "Career Focus",
      subtitle: "Tell us about your interests",
      questions: [
        Question(
          id: 'work_interests',
          text: "What type of work interests you most? (Select up to 3)",
          type: QuestionType.multipleChoice,
          options: [
            'Technology/IT',
            'Healthcare',
            'Education/Training',
            'Finance/Banking',
            'Engineering',
            'Marketing/Sales',
            'Administration',
            'Construction/Trades',
            'Hospitality/Tourism',
            'Manufacturing',
            'Agriculture',
            'Creative/Media',
            'Social Services',
            'Other',
          ],
          maxSelections: 3,
          required: true,
        ),
        Question(
          id: 'experience_level',
          text: "What's your experience level in your field of interest?",
          type: QuestionType.singleChoice,
          options: [
            'Complete beginner',
            'Some knowledge/coursework',
            '1-2 years experience',
            '3-5 years experience',
            '5+ years experience',
          ],
          required: true,
        ),
      ],
    ),
    QuestionStep(
      title: "Skills Assessment",
      subtitle: "Help us understand your abilities",
      questions: [
        Question(
          id: 'computer_skills',
          text: "Rate your computer skills:",
          type: QuestionType.singleChoice,
          options: [
            'Basic (email, web browsing)',
            'Intermediate (Microsoft Office, online research)',
            'Advanced (databases, programming basics)',
            'Expert (coding, system administration)',
          ],
          required: false,
        ),
        Question(
          id: 'software_tools',
          text: "Which software/tools have you used? (Check all that apply)",
          type: QuestionType.multipleChoice,
          options: [
            'Microsoft Office Suite',
            'Google Workspace',
            'Basic programming (Python, JavaScript, etc.)',
            'Design software (Photoshop, Canva)',
            'Accounting software (Excel, QuickBooks)',
            'Social media management',
            'Customer service platforms',
            'None of the above',
          ],
          required: false,
        ),
        Question(
          id: 'languages',
          text: "What languages do you speak fluently?",
          type: QuestionType.multipleChoice,
          options: [
            'English',
            'Afrikaans',
            'isiZulu',
            'isiXhosa',
            'Sesotho',
            'Setswana',
            'Sesotho sa Leboa (Northern Sotho)',
            'Tshivenda',
            'Xitsonga',
            'Siswati',
            'IsiNdebele',
            'Other (specify)',
          ],
          required: false,
        ),
      ],
    ),
    QuestionStep(
      title: "Career Goals",
      subtitle: "What are you looking to achieve?",
      questions: [
        Question(
          id: 'career_goal',
          text: "What's your primary career goal right now?",
          type: QuestionType.singleChoice,
          options: [
            'Find my first job',
            'Change career fields',
            'Advance in current field',
            'Learn new skills',
            'Start my own business',
            'Return to work after a break',
          ],
          required: true,
        ),
        Question(
          id: 'remote_work',
          text: "Are you interested in remote work?",
          type: QuestionType.singleChoice,
          options: [
            'Yes, prefer remote only',
            'Yes, open to remote',
            'Prefer hybrid (some remote, some office)',
            'Prefer in-person work only',
          ],
          required: true,
        ),
        Question(
          id: 'start_timeline',
          text: "How soon are you looking to start working?",
          type: QuestionType.singleChoice,
          options: [
            'Immediately',
            'Within 1 month',
            'Within 3 months',
            'Within 6 months',
            'Just exploring options',
          ],
          required: true,
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() {
    _fadeController.forward();
    _slideController.forward();
    _progressController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _progressController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  void _nextStep() async {
    if (_currentStep < _steps.length - 1) {
      await _buttonController.forward();
      _buttonController.reverse();

      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      await _completeQuestionnaire();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _completeQuestionnaire() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Save data to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_profile', jsonEncode(_formData));
      await prefs.setBool('questionnaire_completed', true);

      // Navigate to main screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const MainNavigationScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0, 1),
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
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving profile: $e'),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
    }
  }

  void _skipQuestionnaire() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainNavigationScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  bool _canProceed() {
    final currentStep = _steps[_currentStep];
    for (final question in currentStep.questions) {
      if (question.required) {
        final answer = _formData[question.id];
        if (answer == null ||
            (answer is List && answer.isEmpty) ||
            (answer is String && answer.isEmpty)) {
          return false;
        }
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.backgroundLight,
              AppTheme.veryLightBlue,
              Colors.white,
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentStep = index;
                    });
                  },
                  itemCount: _steps.length,
                  itemBuilder: (context, index) {
                    return _buildStep(_steps[index]);
                  },
                ),
              ),
              _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentStep > 0)
                GestureDetector(
                  onTap: _previousStep,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradientDecoration,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                )
              else
                const SizedBox(width: 44),

              Column(
                children: [
                  Text(
                    'Getting Started',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.gray900,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Let\'s personalize your experience',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.gray600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              GestureDetector(
                onTap: _skipQuestionnaire,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.gray100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.gray200),
                  ),
                  child: Text(
                    'Skip',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.gray600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: AppTheme.gray200,
            borderRadius: BorderRadius.circular(4),
          ),
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (_currentStep + 1) / _steps.length,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradientDecoration,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step ${_currentStep + 1} of ${_steps.length}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.gray600,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${((_currentStep + 1) / _steps.length * 100).round()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep(QuestionStep step) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepHeader(step),
              const SizedBox(height: 32),
              ...step.questions.map((question) => _buildQuestion(question)),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepHeader(QuestionStep step) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryBlue.withOpacity(0.1),
            AppTheme.secondaryBlue.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradientDecoration,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getStepIcon(_currentStep),
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  step.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.gray900,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            step.subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.gray600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStepIcon(int step) {
    switch (step) {
      case 0:
        return Icons.person_outline;
      case 1:
        return Icons.work_outline;
      case 2:
        return Icons.psychology_outlined;
      case 3:
        return Icons.flag_outlined;
      default:
        return Icons.help_outline;
    }
  }

  Widget _buildQuestion(Question question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gray200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  question.text,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.gray900,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
              if (question.required)
                Container(
                  margin: const EdgeInsets.only(left: 8, top: 2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.dangerRed,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Required',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          _buildQuestionInput(question),
        ],
      ),
    );
  }

  Widget _buildQuestionInput(Question question) {
    switch (question.type) {
      case QuestionType.singleChoice:
        return _buildSingleChoiceInput(question);
      case QuestionType.multipleChoice:
        return _buildMultipleChoiceInput(question);
    }
  }

  Widget _buildSingleChoiceInput(Question question) {
    final currentValue = _formData[question.id] as String?;

    return Column(
      children: question.options.map((option) {
        final isSelected = currentValue == option;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _formData[question.id] = option;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? AppTheme.primaryGradientDecoration
                    : null,
                color: isSelected ? null : AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppTheme.primaryBlue : AppTheme.gray200,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? Colors.white : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? Colors.white : AppTheme.gray400,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            size: 12,
                            color: AppTheme.primaryBlue,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      option,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isSelected ? Colors.white : AppTheme.gray800,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMultipleChoiceInput(Question question) {
    final currentValues =
        (_formData[question.id] as List<dynamic>?) ?? <String>[];

    return Column(
      children: question.options.map((option) {
        final isSelected = currentValues.contains(option);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () {
              setState(() {
                List<String> values = List<String>.from(currentValues);
                if (isSelected) {
                  values.remove(option);
                } else {
                  if (question.maxSelections != null &&
                      values.length >= question.maxSelections!) {
                    // Remove the first selected item if max reached
                    values.removeAt(0);
                  }
                  values.add(option);
                }
                _formData[question.id] = values;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? AppTheme.primaryGradientDecoration
                    : null,
                color: isSelected ? null : AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppTheme.primaryBlue : AppTheme.gray200,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? Colors.white : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? Colors.white : AppTheme.gray400,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            size: 12,
                            color: AppTheme.primaryBlue,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      option,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isSelected ? Colors.white : AppTheme.gray800,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (question.maxSelections != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withOpacity(0.2)
                            : AppTheme.gray100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${currentValues.length}/${question.maxSelections}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isSelected ? Colors.white : AppTheme.gray600,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          if (_currentStep < _steps.length - 1)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _skipQuestionnaire,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: AppTheme.gray300, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: AppTheme.gray50,
                    ),
                    child: Text(
                      'Skip for now',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.gray600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ScaleTransition(
                    scale: _buttonScaleAnimation,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: _canProceed()
                            ? AppTheme.primaryGradientDecoration
                            : null,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: _canProceed()
                            ? [
                                BoxShadow(
                                  color: AppTheme.primaryBlue.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: ElevatedButton(
                        onPressed: _canProceed() ? _nextStep : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: _canProceed()
                              ? Colors.transparent
                              : AppTheme.gray300,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Continue',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            ScaleTransition(
              scale: _buttonScaleAnimation,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: _canProceed() && !_isLoading
                      ? AppTheme.primaryGradientDecoration
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _canProceed() && !_isLoading
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryBlue.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: ElevatedButton(
                  onPressed: _canProceed() && !_isLoading ? _nextStep : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: _canProceed() && !_isLoading
                        ? Colors.transparent
                        : AppTheme.gray300,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Complete Profile',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Data models
class QuestionStep {
  final String title;
  final String subtitle;
  final List<Question> questions;

  QuestionStep({
    required this.title,
    required this.subtitle,
    required this.questions,
  });
}

class Question {
  final String id;
  final String text;
  final QuestionType type;
  final List<String> options;
  final bool required;
  final int? maxSelections;

  Question({
    required this.id,
    required this.text,
    required this.type,
    required this.options,
    this.required = false,
    this.maxSelections,
  });
}

enum QuestionType { singleChoice, multipleChoice }
