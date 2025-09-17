import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:skillsbridge/data/deepseek_api.dart'; // Import the DeepSeek API service

// Enhanced State class with API integration
class CounsellorScreenState {
  final List<ChatMessage> messages;
  final bool isRecording;
  final bool isTyping;
  final bool isConnected;
  final double progressValue;
  final String? error;
  final String? currentStreamingMessage;

  const CounsellorScreenState({
    required this.messages,
    required this.isRecording,
    required this.isTyping,
    required this.isConnected,
    required this.progressValue,
    this.error,
    this.currentStreamingMessage,
  });

  CounsellorScreenState copyWith({
    List<ChatMessage>? messages,
    bool? isRecording,
    bool? isTyping,
    bool? isConnected,
    double? progressValue,
    String? error,
    String? currentStreamingMessage,
  }) {
    return CounsellorScreenState(
      messages: messages ?? this.messages,
      isRecording: isRecording ?? this.isRecording,
      isTyping: isTyping ?? this.isTyping,
      isConnected: isConnected ?? this.isConnected,
      progressValue: progressValue ?? this.progressValue,
      error: error ?? this.error,
      currentStreamingMessage:
          currentStreamingMessage ?? this.currentStreamingMessage,
    );
  }

  // Clear error
  CounsellorScreenState clearError() {
    return copyWith(error: null);
  }
}

// Enhanced ViewModel with DeepSeek API integration
class CounsellorScreenViewModel extends StateNotifier<CounsellorScreenState> {
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final Ref ref;

  Timer? _responseTimer;
  Timer? _voiceTimer;
  StreamSubscription? _streamSubscription;

  // System prompt for the career counselor
  static const String systemPrompt = '''
You are an expert Career Counselor AI assistant. Your role is to help users:
- Discover their skills and strengths
- Explore career paths that match their goals
- Provide guidance on professional development
- Offer personalized career advice

Guidelines:
- Be supportive, encouraging, and professional
- Ask relevant follow-up questions to understand the user better
- Provide specific, actionable advice
- Keep responses concise but helpful
- Use emojis sparingly and appropriately
- Focus on practical career guidance

Current conversation context: This is a career counseling session where you're helping the user with their professional development.
''';

  CounsellorScreenViewModel(this.ref) : super(_initialState()) {
    _initializeChat();
    _checkApiConnection();
  }

  static CounsellorScreenState _initialState() {
    return const CounsellorScreenState(
      messages: [],
      isRecording: false,
      isTyping: false,
      isConnected: false,
      progressValue: 0.1,
    );
  }

  void _checkApiConnection() {
    final apiService = ref.read(deepSeekApiServiceProvider);
    state = state.copyWith(isConnected: apiService != null);
  }

  void _initializeChat() {
    final initialMessage = ChatMessage(
      text:
          "Hey there! 😊 I'm your AI Career Coach here at SkillsBridge. I'm here to help you navigate South Africa's job market and find your path from learning to earning! 🚀\n\nWhether you're fresh out of school, looking to upskill, or ready to switch careers - I've got your back. Let's chat about where you're at right now and where you want to go! 💪\n\nWhat best describes your current situation?",
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      quickReplies: [
        "🎓 Just finished school",
        "💼 Looking for my first job",
        "📚 Want to learn new skills",
        "🔄 Ready for career change",
        "💰 Need funding for studies",
        "🏢 Have job, want better",
      ],
    );

    state = state.copyWith(messages: [initialMessage]);
  }

  // Set API key
  void setApiKey(String apiKey) {
    ref.read(deepSeekApiKeyProvider.notifier).state = apiKey;
    _checkApiConnection();

    if (apiKey.isNotEmpty) {
      _addSystemMessage("✅ Connected to DeepSeek API successfully!");
    }
  }

  void _addSystemMessage(String message) {
    final systemMessage = ChatMessage(
      text: message,
      isUser: false,
      timestamp: DateTime.now(),
      isSystemMessage: true,
    );

    state = state.copyWith(messages: [...state.messages, systemMessage]);
    _scrollToBottom();
  }

  void sendMessage() {
    final text = textController.text.trim();
    if (text.isNotEmpty) {
      final newMessage = ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, newMessage],
        error: null,
      );

      textController.clear();
      _scrollToBottom();
      _getAIResponse(text);
    }
  }

  void _getAIResponse(String userMessage) async {
    final apiService = ref.read(deepSeekApiServiceProvider);

    if (apiService == null) {
      state = state.copyWith(error: "Please set your DeepSeek API key first");
      return;
    }

    state = state.copyWith(isTyping: true, error: null);

    try {
      // Convert chat history to DeepSeek messages
      final conversationHistory = _buildConversationHistory();

      // Use streaming for real-time response
      final responseStream = apiService.sendMessageStream(
        message: userMessage,
        systemPrompt: systemPrompt,
        conversationHistory: conversationHistory,
        temperature: 0.7,
        useReasoner: false, // Use reasoner for complex queries if needed
      );

      String fullResponse = '';
      ChatMessage? currentMessage;

      _streamSubscription = responseStream.listen(
        (chunk) {
          fullResponse += chunk;

          if (currentMessage == null) {
            // Create new message for the first chunk
            currentMessage = ChatMessage(
              text: fullResponse,
              isUser: false,
              timestamp: DateTime.now(),
            );

            state = state.copyWith(
              isTyping: false,
              messages: [...state.messages, currentMessage!],
            );
          } else {
            // Update existing message
            final updatedMessages = state.messages.map((msg) {
              if (msg == currentMessage) {
                return ChatMessage(
                  text: fullResponse,
                  isUser: false,
                  timestamp: msg.timestamp,
                );
              }
              return msg;
            }).toList();

            state = state.copyWith(messages: updatedMessages);
          }

          _scrollToBottom();
        },
        onDone: () {
          state = state.copyWith(isTyping: false);
          _updateProgress();
        },
        onError: (error) {
          state = state.copyWith(isTyping: false, error: _formatError(error));

          // Add error message to chat
          final errorMessage = ChatMessage(
            text: "Sorry, I encountered an error: ${_formatError(error)}",
            isUser: false,
            timestamp: DateTime.now(),
            isSystemMessage: true,
          );

          state = state.copyWith(messages: [...state.messages, errorMessage]);
        },
      );
    } catch (error) {
      state = state.copyWith(isTyping: false, error: _formatError(error));

      // Fallback to simulated response if API fails
      _simulateAIResponse();
    }
  }

  List<DeepSeekMessage> _buildConversationHistory() {
    // Convert recent chat messages to DeepSeek format (limit to last 10 exchanges)
    final recentMessages = state.messages
        .where((msg) => !msg.isSystemMessage)
        //.takeLast(20) // Take last 20 messages (10 exchanges)
        .toList();

    return recentMessages.map((msg) {
      return DeepSeekMessage(
        role: msg.isUser ? 'user' : 'assistant',
        content: msg.text,
      );
    }).toList();
  }

  String _formatError(dynamic error) {
    if (error is DeepSeekApiException) {
      return error.message;
    }
    return error.toString();
  }

  void _simulateAIResponse() {
    state = state.copyWith(isTyping: true);

    _responseTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        final aiMessage = ChatMessage(
          text: _getRandomAIResponse(),
          isUser: false,
          timestamp: DateTime.now(),
        );

        state = state.copyWith(
          isTyping: false,
          messages: [...state.messages, aiMessage],
        );

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
    return responses[DateTime.now().millisecondsSinceEpoch % responses.length];
  }

  void _updateProgress() {
    if (state.progressValue < 1.0) {
      double newProgress = state.progressValue + 0.05;
      if (newProgress > 1.0) newProgress = 1.0;
      state = state.copyWith(progressValue: newProgress);
    }
  }

  void handleQuickReply(String reply) {
    final message = ChatMessage(
      text: reply,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(messages: [...state.messages, message]);

    _scrollToBottom();
    _getAIResponse(reply);
  }

  void handleSkillRating(String rating) {
    final message = ChatMessage(
      text: rating,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(messages: [...state.messages, message]);

    _scrollToBottom();
    _getAIResponse(rating);
  }

  void toggleVoiceRecording() {
    state = state.copyWith(isRecording: !state.isRecording);

    if (state.isRecording) {
      _voiceTimer = Timer(const Duration(seconds: 3), () {
        if (state.isRecording && mounted) {
          final voiceMessage = ChatMessage(
            text:
                "(Voice message transcribed) I'm looking for entry-level positions",
            isUser: true,
            timestamp: DateTime.now(),
          );

          state = state.copyWith(
            isRecording: false,
            messages: [...state.messages, voiceMessage],
          );

          _scrollToBottom();
          _getAIResponse(voiceMessage.text);
        }
      });
    } else {
      _voiceTimer?.cancel();
    }
  }

  void clearError() {
    state = state.clearError();
  }

  void retryLastMessage() {
    if (state.messages.isNotEmpty) {
      final lastUserMessage = state.messages.lastWhere(
        (msg) => msg.isUser,
        orElse: () => state.messages.last,
      );

      if (lastUserMessage.isUser) {
        _getAIResponse(lastUserMessage.text);
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void exportConversation() {
    // Implementation for exporting conversation
    final conversationText = state.messages
        .where((msg) => !msg.isSystemMessage)
        .map((msg) => '${msg.isUser ? "User" : "AI"}: ${msg.text}')
        .join('\n\n');

    // You can implement file saving logic here
    print('Exported conversation:\n$conversationText');
  }

  @override
  bool get mounted => true;

  @override
  void dispose() {
    _responseTimer?.cancel();
    _voiceTimer?.cancel();
    _streamSubscription?.cancel();
    textController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}

// Enhanced Chat Message model
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? quickReplies;
  final bool hasSkillRating;
  final List<ResourceCard>? resources;
  final bool isSystemMessage;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.quickReplies,
    this.hasSkillRating = false,
    this.resources,
    this.isSystemMessage = false,
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

// Enhanced Provider for the ViewModel
final counsellorScreenViewModelProvider =
    StateNotifierProvider<CounsellorScreenViewModel, CounsellorScreenState>(
      (ref) => CounsellorScreenViewModel(ref),
    );

// Additional providers for API key management
final apiKeyInputProvider = StateProvider<String>((ref) => '');

// Provider to check if API is ready
final isApiReadyProvider = Provider<bool>((ref) {
  final apiService = ref.watch(deepSeekApiServiceProvider);
  return apiService != null;
});

extension ListExtensions<T> on List<T> {
  List<T> takeLast(int count) {
    if (count >= length) return this;
    return sublist(length - count);
  }
}
