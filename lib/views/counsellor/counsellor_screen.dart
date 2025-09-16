import 'package:flutter/material.dart';
import 'dart:async';

class AICouncelorScreen extends StatefulWidget {
  const AICouncelorScreen({super.key});

  @override
  _AICouncelorScreenState createState() => _AICouncelorScreenState();
}

class _AICouncelorScreenState extends State<AICouncelorScreen>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isRecording = false;
  bool _isTyping = false;
  double _progressValue = 0.6;
  final int _currentStep = 3;
  final int _totalSteps = 5;
  late AnimationController _typingAnimationController;

  @override
  void initState() {
    super.initState();
    _typingAnimationController = AnimationController(
      duration: Duration(milliseconds: 1400),
      vsync: this,
    )..repeat();
    _initializeChat();
  }

  @override
  void dispose() {
    _typingAnimationController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeChat() {
    // Add initial messages
    _messages.addAll([
      ChatMessage(
        text:
            "Hello! I'm your AI Career Counselor. I'm here to help you discover your skills, explore career paths, and find opportunities that match your goals. 🎯\n\nLet's start by getting to know you better. This assessment will take about 10 minutes.",
        isUser: false,
        timestamp: DateTime.now().subtract(Duration(minutes: 5)),
      ),
      ChatMessage(
        text:
            "Hi! I'm ready to start. I recently graduated and looking for opportunities in tech.",
        isUser: true,
        timestamp: DateTime.now().subtract(Duration(minutes: 4)),
      ),
      ChatMessage(
        text:
            "Great! It's wonderful that you're interested in tech. There are many exciting opportunities in this field.\n\nFirst, what's your highest level of education?",
        isUser: false,
        timestamp: DateTime.now().subtract(Duration(minutes: 4)),
        quickReplies: [
          "High School",
          "Certificate/Diploma",
          "Bachelor's Degree",
          "Postgraduate",
        ],
      ),
      ChatMessage(
        text: "Bachelor's Degree",
        isUser: true,
        timestamp: DateTime.now().subtract(Duration(minutes: 3)),
      ),
      ChatMessage(
        text:
            "Excellent! A Bachelor's degree provides a strong foundation. Now, let's assess your technical skills.\n\nHow would you rate your programming skills?",
        isUser: false,
        timestamp: DateTime.now().subtract(Duration(minutes: 3)),
        hasSkillRating: true,
      ),
      ChatMessage(
        text: "Intermediate",
        isUser: true,
        timestamp: DateTime.now().subtract(Duration(minutes: 2)),
      ),
      ChatMessage(
        text:
            "Good! Intermediate programming skills open many doors. Based on your profile, I found some resources that might help you advance:",
        isUser: false,
        timestamp: DateTime.now().subtract(Duration(minutes: 2)),
        resources: [
          ResourceCard(
            icon: "📚",
            title: "Python for Data Science",
            description: "Free course • 40 hours • Certificate included",
          ),
          ResourceCard(
            icon: "💼",
            title: "Junior Developer Positions",
            description: "8 matching jobs in your area",
          ),
        ],
      ),
    ]);
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _messages.add(
          ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
        );
      });
      _textController.clear();
      _scrollToBottom();
      _simulateAIResponse();
    }
  }

  void _simulateAIResponse() {
    setState(() {
      _isTyping = true;
    });

    Timer(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(
            ChatMessage(
              text: _getRandomAIResponse(),
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });
        _scrollToBottom();
        _updateProgress();
      }
    });
  }

  String _getRandomAIResponse() {
    final responses = [
      "That's interesting! Can you tell me more about your experience in that area?",
      "Based on what you've shared, I can see you have valuable skills. What type of role interests you most?",
      "Great! Let me analyze this information and provide some personalized recommendations for you.",
      "I understand. Many people in your situation have successfully transitioned into tech careers. What motivates you most about this field?",
    ];
    return responses[(DateTime.now().millisecondsSinceEpoch %
        responses.length)];
  }

  void _updateProgress() {
    if (_progressValue < 1.0) {
      setState(() {
        _progressValue += 0.05;
        if (_progressValue > 1.0) _progressValue = 1.0;
      });
    }
  }

  void _handleQuickReply(String reply) {
    setState(() {
      _messages.add(
        ChatMessage(text: reply, isUser: true, timestamp: DateTime.now()),
      );
    });
    _scrollToBottom();
    _simulateAIResponse();
  }

  void _handleSkillRating(String rating) {
    setState(() {
      _messages.add(
        ChatMessage(text: rating, isUser: true, timestamp: DateTime.now()),
      );
    });
    _scrollToBottom();
    _simulateAIResponse();
  }

  void _toggleVoiceRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });

    if (_isRecording) {
      // Simulate voice recording
      Timer(Duration(seconds: 3), () {
        if (_isRecording && mounted) {
          setState(() {
            _isRecording = false;
            _messages.add(
              ChatMessage(
                text:
                    "(Voice message transcribed) I'm looking for entry-level positions",
                isUser: true,
                timestamp: DateTime.now(),
              ),
            );
          });
          _scrollToBottom();
          _simulateAIResponse();
        }
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF0F9FF), Color(0xFFE0F2FE)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildMessagesList()),
              if (_isTyping) _buildTypingIndicator(),
              _buildInputArea(),
            ],
          ),
        ),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.arrow_back, color: Colors.white, size: 24),
            ),
          ),
          SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(child: Text("🤖", style: TextStyle(fontSize: 20))),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Career Counselor",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      "Online - Ready to help",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildHeaderButton("📥", "Export Conversation"),
          SizedBox(width: 12),
          _buildHeaderButton("⋮", "More Options"),
        ],
      ),
    );
  }

  Widget _buildHeaderButton(String icon, String tooltip) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(tooltip)));
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(child: Text(icon, style: TextStyle(fontSize: 16))),
      ),
    );
  }

  Widget _buildMessagesList() {
    return Container(
      color: Colors.white,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(20),
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          return _buildMessageItem(_messages[index]);
        },
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage message) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) _buildAvatar(false),
          if (!message.isUser) SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? Color(0xFF2563EB)
                        : Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(16).copyWith(
                      bottomLeft: Radius.circular(message.isUser ? 16 : 4),
                      bottomRight: Radius.circular(message.isUser ? 4 : 16),
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: message.isUser ? Colors.white : Color(0xFF1F2937),
                    ),
                  ),
                ),
                if (message.quickReplies != null)
                  _buildQuickReplies(message.quickReplies!),
                if (message.hasSkillRating) _buildSkillRating(),
                if (message.resources != null)
                  _buildResourceCards(message.resources!),
                SizedBox(height: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    fontSize: 11,
                    color: message.isUser
                        ? Colors.white.withOpacity(0.7)
                        : Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          if (message.isUser) SizedBox(width: 8),
          if (message.isUser) _buildAvatar(true),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isUser) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isUser ? Color(0xFFE5E7EB) : Color(0xFFDBEAFE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(isUser ? "👤" : "🤖", style: TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildQuickReplies(List<String> replies) {
    return Container(
      margin: EdgeInsets.only(top: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: replies
            .map((reply) => _buildQuickReplyButton(reply))
            .toList(),
      ),
    );
  }

  Widget _buildQuickReplyButton(String text) {
    return GestureDetector(
      onTap: () => _handleQuickReply(text),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Color(0xFF2563EB)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF2563EB),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSkillRating() {
    final levels = [
      {"level": "Beginner", "desc": "Just starting"},
      {"level": "Intermediate", "desc": "Some experience"},
      {"level": "Advanced", "desc": "Very confident"},
      {"level": "Expert", "desc": "Professional level"},
    ];

    return Container(
      margin: EdgeInsets.only(top: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Select Your Skill Level",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.5,
            ),
            itemCount: levels.length,
            itemBuilder: (context, index) {
              final level = levels[index];
              return GestureDetector(
                onTap: () => _handleSkillRating(level["level"]!),
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFF9FAFB),
                    border: Border.all(color: Colors.transparent, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        level["level"]!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        level["desc"]!,
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCards(List<ResourceCard> resources) {
    return Column(
      children: resources
          .map((resource) => _buildResourceCard(resource))
          .toList(),
    );
  }

  Widget _buildResourceCard(ResourceCard resource) {
    return Container(
      margin: EdgeInsets.only(top: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(resource.icon, style: TextStyle(fontSize: 20)),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resource.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  resource.description,
                  style: TextStyle(fontSize: 11, color: Color(0xFF4B5563)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          _buildAvatar(false),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(
                16,
              ).copyWith(bottomLeft: Radius.circular(4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                SizedBox(width: 4),
                _buildTypingDot(200),
                SizedBox(width: 4),
                _buildTypingDot(400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int delay) {
    return AnimatedBuilder(
      animation: _typingAnimationController,
      builder: (context, child) {
        final animationValue =
            (_typingAnimationController.value * 1400 - delay) / 1400;
        final progress = (animationValue % 1.0).clamp(0.0, 1.0);
        final offset = progress < 0.5 ? progress * 2 : (1 - progress) * 2;

        return Transform.translate(
          offset: Offset(0, -offset * 10),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Color(0xFF9CA3AF),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFF9FAFB),
                border: Border.all(color: Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: "Type your message...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          SizedBox(width: 8),
          GestureDetector(
            onTap: _toggleVoiceRecording,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _isRecording ? Color(0xFFEF4444) : Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  _isRecording ? "⏹" : "🎤",
                  style: TextStyle(
                    fontSize: 20,
                    color: _isRecording ? Colors.white : Color(0xFF4B5563),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour;
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
}

// Data Models
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? quickReplies;
  final bool hasSkillRating;
  final List<ResourceCard>? resources;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.quickReplies,
    this.hasSkillRating = false,
    this.resources,
  });
}

class ResourceCard {
  final String icon;
  final String title;
  final String description;

  ResourceCard({
    required this.icon,
    required this.title,
    required this.description,
  });
}
