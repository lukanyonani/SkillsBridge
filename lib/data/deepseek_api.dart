import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

// Configuration
class DeepSeekConfig {
  static const String baseUrl = 'https://api.deepseek.com';
  static const String chatCompletionsEndpoint = '/chat/completions';
  static const String defaultModel = 'deepseek-chat';
  static const String reasonerModel = 'deepseek-reasoner';
}

// API Models
class DeepSeekMessage {
  final String role;
  final String content;

  const DeepSeekMessage({required this.role, required this.content});

  Map<String, dynamic> toJson() => {'role': role, 'content': content};

  factory DeepSeekMessage.fromJson(Map<String, dynamic> json) =>
      DeepSeekMessage(
        role: json['role'] as String,
        content: json['content'] as String,
      );

  // Convenience constructors
  factory DeepSeekMessage.system(String content) =>
      DeepSeekMessage(role: 'system', content: content);

  factory DeepSeekMessage.user(String content) =>
      DeepSeekMessage(role: 'user', content: content);

  factory DeepSeekMessage.assistant(String content) =>
      DeepSeekMessage(role: 'assistant', content: content);
}

class DeepSeekRequest {
  final String model;
  final List<DeepSeekMessage> messages;
  final bool stream;
  final double? temperature;
  final int? maxTokens;
  final double? topP;
  final String? responseFormat;

  const DeepSeekRequest({
    required this.model,
    required this.messages,
    this.stream = false,
    this.temperature,
    this.maxTokens,
    this.topP,
    this.responseFormat,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'model': model,
      'messages': messages.map((m) => m.toJson()).toList(),
      'stream': stream,
    };

    if (temperature != null) json['temperature'] = temperature;
    if (maxTokens != null) json['max_tokens'] = maxTokens;
    if (topP != null) json['top_p'] = topP;
    if (responseFormat != null) {
      json['response_format'] = {'type': responseFormat};
    }

    return json;
  }
}

class DeepSeekChoice {
  final int index;
  final DeepSeekMessage message;
  final String? finishReason;

  const DeepSeekChoice({
    required this.index,
    required this.message,
    this.finishReason,
  });

  factory DeepSeekChoice.fromJson(Map<String, dynamic> json) => DeepSeekChoice(
    index: json['index'] as int,
    message: DeepSeekMessage.fromJson(json['message'] as Map<String, dynamic>),
    finishReason: json['finish_reason'] as String?,
  );
}

class DeepSeekUsage {
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;

  const DeepSeekUsage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  factory DeepSeekUsage.fromJson(Map<String, dynamic> json) => DeepSeekUsage(
    promptTokens: json['prompt_tokens'] as int,
    completionTokens: json['completion_tokens'] as int,
    totalTokens: json['total_tokens'] as int,
  );
}

class DeepSeekResponse {
  final String id;
  final String object;
  final int created;
  final String model;
  final List<DeepSeekChoice> choices;
  final DeepSeekUsage usage;

  const DeepSeekResponse({
    required this.id,
    required this.object,
    required this.created,
    required this.model,
    required this.choices,
    required this.usage,
  });

  factory DeepSeekResponse.fromJson(Map<String, dynamic> json) =>
      DeepSeekResponse(
        id: json['id'] as String,
        object: json['object'] as String,
        created: json['created'] as int,
        model: json['model'] as String,
        choices: (json['choices'] as List)
            .map(
              (choice) =>
                  DeepSeekChoice.fromJson(choice as Map<String, dynamic>),
            )
            .toList(),
        usage: DeepSeekUsage.fromJson(json['usage'] as Map<String, dynamic>),
      );

  String get content => choices.isNotEmpty ? choices.first.message.content : '';
}

// Streaming response models
class DeepSeekStreamChoice {
  final int index;
  final DeepSeekMessage? delta;
  final String? finishReason;

  const DeepSeekStreamChoice({
    required this.index,
    this.delta,
    this.finishReason,
  });

  factory DeepSeekStreamChoice.fromJson(Map<String, dynamic> json) =>
      DeepSeekStreamChoice(
        index: json['index'] as int,
        delta: json['delta'] != null
            ? DeepSeekMessage.fromJson(json['delta'] as Map<String, dynamic>)
            : null,
        finishReason: json['finish_reason'] as String?,
      );
}

class DeepSeekStreamResponse {
  final String id;
  final String object;
  final int created;
  final String model;
  final List<DeepSeekStreamChoice> choices;

  const DeepSeekStreamResponse({
    required this.id,
    required this.object,
    required this.created,
    required this.model,
    required this.choices,
  });

  factory DeepSeekStreamResponse.fromJson(Map<String, dynamic> json) =>
      DeepSeekStreamResponse(
        id: json['id'] as String,
        object: json['object'] as String,
        created: json['created'] as int,
        model: json['model'] as String,
        choices: (json['choices'] as List)
            .map(
              (choice) =>
                  DeepSeekStreamChoice.fromJson(choice as Map<String, dynamic>),
            )
            .toList(),
      );

  String? get deltaContent => choices.isNotEmpty && choices.first.delta != null
      ? choices.first.delta!.content
      : null;
}

// Exception classes
class DeepSeekApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;

  const DeepSeekApiException({
    required this.message,
    this.statusCode,
    this.errorCode,
  });

  @override
  String toString() => 'DeepSeekApiException: $message';
}

// API Service
class DeepSeekApiService {
  final String apiKey;
  final http.Client _client;

  DeepSeekApiService({required this.apiKey, http.Client? client})
    : _client = client ?? http.Client();

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $apiKey',
  };

  // Non-streaming chat completion
  Future<DeepSeekResponse> chatCompletion(DeepSeekRequest request) async {
    try {
      final response = await _client.post(
        Uri.parse(
          '${DeepSeekConfig.baseUrl}${DeepSeekConfig.chatCompletionsEndpoint}',
        ),
        headers: _headers,
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        return DeepSeekResponse.fromJson(jsonResponse);
      } else {
        final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
        final errorMessage = errorBody['error']?['message'] ?? 'Unknown error';
        final errorCode = errorBody['error']?['code'];

        throw DeepSeekApiException(
          message: errorMessage,
          statusCode: response.statusCode,
          errorCode: errorCode,
        );
      }
    } on SocketException {
      throw const DeepSeekApiException(
        message: 'No internet connection. Please check your network.',
      );
    } on TimeoutException {
      throw const DeepSeekApiException(
        message: 'Request timeout. Please try again.',
      );
    } catch (e) {
      if (e is DeepSeekApiException) rethrow;
      throw DeepSeekApiException(message: 'Failed to complete request: $e');
    }
  }

  // Streaming chat completion
  Stream<DeepSeekStreamResponse> chatCompletionStream(
    DeepSeekRequest request,
  ) async* {
    try {
      final streamRequest = DeepSeekRequest(
        model: request.model,
        messages: request.messages,
        stream: true,
        temperature: request.temperature,
        maxTokens: request.maxTokens,
        topP: request.topP,
        responseFormat: request.responseFormat,
      );

      final httpRequest = http.Request(
        'POST',
        Uri.parse(
          '${DeepSeekConfig.baseUrl}${DeepSeekConfig.chatCompletionsEndpoint}',
        ),
      );

      httpRequest.headers.addAll(_headers);
      httpRequest.body = jsonEncode(streamRequest.toJson());

      final response = await _client.send(httpRequest);

      if (response.statusCode != 200) {
        final errorBody = await response.stream.bytesToString();
        final errorJson = jsonDecode(errorBody) as Map<String, dynamic>;
        final errorMessage = errorJson['error']?['message'] ?? 'Unknown error';
        final errorCode = errorJson['error']?['code'];

        throw DeepSeekApiException(
          message: errorMessage,
          statusCode: response.statusCode,
          errorCode: errorCode,
        );
      }

      await for (final chunk
          in response.stream
              .transform(utf8.decoder)
              .transform(const LineSplitter())) {
        if (chunk.isEmpty) continue;

        if (chunk.startsWith('data: ')) {
          final data = chunk.substring(6);

          if (data == '[DONE]') {
            break;
          }

          try {
            final jsonData = jsonDecode(data) as Map<String, dynamic>;
            yield DeepSeekStreamResponse.fromJson(jsonData);
          } catch (e) {
            // Skip malformed chunks
            continue;
          }
        }
      }
    } on SocketException {
      throw const DeepSeekApiException(
        message: 'No internet connection. Please check your network.',
      );
    } catch (e) {
      if (e is DeepSeekApiException) rethrow;
      throw DeepSeekApiException(message: 'Failed to stream response: $e');
    }
  }

  // Convenience methods
  Future<String> sendMessage({
    required String message,
    String? systemPrompt,
    List<DeepSeekMessage>? conversationHistory,
    bool useReasoner = false,
    double? temperature = 0.7,
  }) async {
    final messages = <DeepSeekMessage>[];

    if (systemPrompt != null) {
      messages.add(DeepSeekMessage.system(systemPrompt));
    }

    if (conversationHistory != null) {
      messages.addAll(conversationHistory);
    }

    messages.add(DeepSeekMessage.user(message));

    final request = DeepSeekRequest(
      model: useReasoner
          ? DeepSeekConfig.reasonerModel
          : DeepSeekConfig.defaultModel,
      messages: messages,
      temperature: temperature,
    );

    final response = await chatCompletion(request);
    return response.content;
  }

  Stream<String> sendMessageStream({
    required String message,
    String? systemPrompt,
    List<DeepSeekMessage>? conversationHistory,
    bool useReasoner = false,
    double? temperature = 0.7,
  }) async* {
    final messages = <DeepSeekMessage>[];

    if (systemPrompt != null) {
      messages.add(DeepSeekMessage.system(systemPrompt));
    }

    if (conversationHistory != null) {
      messages.addAll(conversationHistory);
    }

    messages.add(DeepSeekMessage.user(message));

    final request = DeepSeekRequest(
      model: useReasoner
          ? DeepSeekConfig.reasonerModel
          : DeepSeekConfig.defaultModel,
      messages: messages,
      temperature: temperature,
    );

    await for (final chunk in chatCompletionStream(request)) {
      final content = chunk.deltaContent;
      if (content != null) {
        yield content;
      }
    }
  }

  void dispose() {
    _client.close();
  }
}

// Riverpod Providers
final deepSeekApiKeyProvider = StateProvider<String?>((ref) => null);

final deepSeekApiServiceProvider = Provider<DeepSeekApiService?>((ref) {
  final apiKey = ref.watch(deepSeekApiKeyProvider);

  if (apiKey == null || apiKey.isEmpty) {
    return null;
  }

  final service = DeepSeekApiService(apiKey: apiKey);

  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

// State for API responses
final deepSeekResponseProvider = StateProvider<String?>((ref) => null);
final deepSeekLoadingProvider = StateProvider<bool>((ref) => false);
final deepSeekErrorProvider = StateProvider<String?>((ref) => null);
