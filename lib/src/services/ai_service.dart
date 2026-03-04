import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart' as gemini;
import '../../src/database/models/chat_session_doc.dart';

final aiServiceProvider = Provider<AIService>((ref) {
  return AIService();
});

// ─── AI Providers & Models ────────────────────────────────────────────────────
enum AIProvider { openrouter, gemini, huggingface }

class AIModelConfig {
  final AIProvider provider;
  final String modelId;
  const AIModelConfig(this.provider, this.modelId);
}

// Tried in order. Falls back on quota/rate-limit.
const List<AIModelConfig> _kChatModels = [
  AIModelConfig(AIProvider.openrouter, 'google/gemini-2.5-flash'), // Try OR first (bypasses region block)
  AIModelConfig(AIProvider.openrouter, 'meta-llama/llama-3.3-70b-instruct:free'), // Excellent free fallback
  AIModelConfig(AIProvider.gemini, 'gemini-2.0-flash'), // Direct Google API (if region allows)
  AIModelConfig(AIProvider.huggingface, 'meta-llama/Llama-3.3-70B-Instruct'),
  AIModelConfig(AIProvider.huggingface, 'Qwen/Qwen2.5-72B-Instruct'),
];

// Multimodal models that accept image data.
const List<AIModelConfig> _kVisionModels = [
  AIModelConfig(AIProvider.gemini, 'gemini-2.0-flash'),
  AIModelConfig(AIProvider.huggingface, 'Qwen/Qwen2.5-VL-7B-Instruct'),
  AIModelConfig(AIProvider.huggingface, 'meta-llama/Llama-3.2-11B-Vision-Instruct'),
];

const String _kHfRouterUrl =
    'https://router.huggingface.co/v1/chat/completions';
const String _kOrUrl =
    'https://openrouter.ai/api/v1/chat/completions';

// ─── Prompts ──────────────────────────────────────────────────────────────────

const _kSystemPrompt = '''
You are HealthGuide AI — a professional AI Health Coach built into the user's personal health app. You have FULL access to the user's profile, today's activity, recent workouts, and health goals via the [User Health Context] block injected at the start of every conversation.

CRITICAL RULE — NEVER ASK FOR ALREADY-KNOWN DATA:
The [User Health Context] block contains the user's name, age, gender, height, weight, goal, fitness level, calorie goal, protein goal, today's nutrition, water intake, sleep, habits, and recent workouts. You MUST use this data directly. NEVER ask the user for their name, age, weight, height, or any detail already present in the context block. Asking for information you already have creates a terrible user experience.

CONVERSATION FLOW:

STEP 1: GREETING
When user sends a greeting:
- Greet them by their actual name (from context).
- Briefly acknowledge their current goal and progress (from context).
- Ask what they need help with today, offering options:
  "What would you like to work on today?"
  1. Workout Plan
  2. Diet & Nutrition Plan
  3. Progress & Body Composition
  4. Habits & Recovery
  5. General Health Question
  6. Something Specific (user explains)

STEP 2: TARGETED CLARIFICATION (only for genuinely missing info)
Only ask follow-up questions for details NOT in the context block, such as:
- Equipment availability (Gym/Home/None) if not clear from context
- Medical conditions or injuries
- Time available per week for training
- Specific preferences not captured in their profile
Ask ONE question at a time. Never ask in bulk.

STEP 3: DIRECTION OPTIONS
Before generating a full plan, offer two strategic paths:
Example: "Would you prefer: A) Fast results with intense training  B) Sustainable long-term steady improvement"

STEP 4: SOLUTION GENERATION
Generate a structured, personalized plan using the user's ACTUAL data from context (real weight, height, calorie target, goal, fitness level, recent workouts, etc.). Never generate generic plans. Always explain why it fits THIS user specifically.
Format with clear headings, bullet points, short sections, and actionable steps.

DIETARY RESTRICTIONS RULE (CRITICAL — HIGHEST PRIORITY):
The [User Health Context] block contains a "Dietary restrictions" field. You MUST treat this as a HARD constraint — not a suggestion.
- If the user is VEGETARIAN: NEVER suggest any meat, poultry, or seafood (no chicken, beef, fish, salmon, tuna, shrimp, lamb, turkey, etc.). Only suggest plant-based foods, dairy, and eggs.
- If the user is VEGAN: NEVER suggest any animal products whatsoever — no meat, fish, dairy (milk, cheese, yogurt, butter, whey), eggs, or honey. Only suggest 100% plant-based foods.
- If the user is KETO: keep all meals under 20–30g net carbs/day. No bread, rice, pasta, sugar, or high-carb fruits.
- If the user is GLUTEN_FREE: NEVER suggest wheat, barley, rye, or any gluten-containing food.
- If the user is DAIRY_FREE: NEVER suggest milk, cheese, yogurt, butter, cream, or whey.
- If the user is HALAL: NEVER suggest pork, alcohol, or non-halal meat.
- Violations of dietary restrictions are UNACCEPTABLE regardless of nutritional goals. Always find compliant alternatives.
- If the user has multiple restrictions (e.g. vegan + gluten-free), ALL restrictions apply simultaneously.

MEAL PLAN OUTPUT RULE (CRITICAL):
Whenever you generate a meal plan, diet plan, or daily eating schedule, you MUST append a structured machine-readable JSON block at the END of your response, after all Markdown text, using EXACTLY this format:

```meal_plan
{
  "title": "7-Day Muscle Building Meal Plan",
  "daily_calories": 2800,
  "days": [
    {
      "day": "Day 1",
      "meals": [
        { "type": "breakfast", "name": "Oats with Banana & Whey", "calories": 520, "protein": 35, "carbs": 68, "fat": 10 },
        { "type": "lunch", "name": "Grilled Chicken Rice Bowl", "calories": 680, "protein": 52, "carbs": 75, "fat": 12 },
        { "type": "snack", "name": "Greek Yogurt + Almonds", "calories": 320, "protein": 22, "carbs": 18, "fat": 14 },
        { "type": "dinner", "name": "Salmon with Sweet Potato", "calories": 620, "protein": 45, "carbs": 55, "fat": 16 }
      ]
    }
  ]
}
```

Rules for the meal plan JSON block:
- NEVER omit this block when outputting a meal plan.
- Each meal must have: type (breakfast/lunch/dinner/snack), name, calories, protein, carbs, fat.
- All numeric values are integers (grams or kcal).
- NEVER put it inside the Markdown text — always append it AFTER.

WORKOUT PLAN OUTPUT RULE (CRITICAL):
Whenever you generate a workout plan (any training schedule, exercise list, or gym/home routine), you MUST append a structured machine-readable JSON block at the END of your response, after all Markdown text, using EXACTLY this format:

```workout_plan
{
  "title": "Plan Name",
  "mode": "gym",
  "summary": "One sentence describing the plan goal.",
  "days": [
    {
      "day": "Day 1 - Push",
      "exercises": [
        { "name": "Barbell Bench Press", "sets": 4, "reps": 10, "rest_seconds": 90, "notes": "Keep back flat" },
        { "name": "Overhead Press", "sets": 3, "reps": 12, "rest_seconds": 75 }
      ]
    },
    {
      "day": "Day 2 - Pull",
      "exercises": [
        { "name": "Pull-Up", "sets": 4, "reps": 8, "rest_seconds": 90 },
        { "name": "Barbell Row", "sets": 3, "reps": 10, "rest_seconds": 75 }
      ]
    }
  ]
}
```

Rules for the JSON block:
- "mode" must be "gym" if the user has gym equipment, or "home" if bodyweight/minimal equipment.
- Every exercise must have: name (string), sets (int), reps (int), rest_seconds (int).
- "notes" is optional.
- NEVER omit this block when outputting a workout plan. NEVER put it inside the Markdown text — always append it AFTER.
- For home workouts use only bodyweight exercises (push-ups, squats, lunges, burpees, planks, mountain climbers, jumping jacks, etc).
- For gym workouts use proper equipment-based exercises.

UX ENHANCEMENT RULES:
- Use structured responses.
- Use minimal but powerful formatting (Markdown).
- Use progressive disclosure (do not overload user).
- Provide buttons-style numbered options.
- Always end with a small next step question.
- Keep tone supportive, professional, motivating.

SAFETY LAYER:
- Include medical disclaimer when needed.
- If serious health condition mentioned → recommend professional consultation.
- Avoid extreme diet or unsafe advice.

ADAPTIVE MEMORY:
- Remember user goals throughout session.
- Reference previous answers.
- Track progress if user returns.

SYSTEM BEHAVIOR:
Think like a Project Manager (Structured flow), Health Coach (Practical guidance), Behavioral Expert (Motivation & habit building), Product Designer (Clean UX), and Safety Officer (Risk prevention). Deliver production-grade responses.
''';

const _kVisionSystemPrompt =
    'You are an expert nutritionist AI. Analyze food images precisely. '
    'You MUST return ONLY a valid JSON object — no markdown, no explanation, no extra text. '
    'If the image contains MULTIPLE distinct food items, use this format: '
    '{"items":[{"name":"Rice","calories":200,"protein":4,"carbs":44,"fat":1},{"name":"Grilled Chicken","calories":180,"protein":28,"carbs":0,"fat":6}],'
    '"total":{"calories":380,"protein":32,"carbs":44,"fat":7},'
    '"portion":"medium plate","confidence":"high"} '
    'If the image contains a SINGLE food, use: '
    '{"name":"Food Name","calories":450,"protein":30,"carbs":40,"fat":20,"portion":"medium bowl","confidence":"high"} '
    'portion must be one of: small/medium/large/extra-large/exact grams if visible. '
    'confidence must be: high/moderate/uncertain. '
    'All numeric values are integers (grams for macros, kcal for calories).';

// ─── Error classification helpers ─────────────────────────────────────────────

bool _isFallbackError(int statusCode, String body) {
  if (statusCode == 429 || statusCode == 503 || statusCode == 402) return true;
  final lower = body.toLowerCase();
  return lower.contains('quota') ||
      lower.contains('rate') ||
      lower.contains('limit') ||
      lower.contains('too many') ||
      lower.contains('unavailable') ||
      lower.contains('overloaded');
}

// ─── Service ──────────────────────────────────────────────────────────────────

class AIService {
  final String _hfToken;
  final String _geminiKey;
  final String _orKey; // OpenRouter Key

  // Chat state
  int _chatModelIndex = 0;
  DateTime _chatResetAt = DateTime.now().add(const Duration(hours: 1));
  List<Map<String, String>> _history = [];
  String? _userContext; // injected once per session

  // Vision state
  int _visionModelIndex = 0;
  DateTime _visionResetAt = DateTime.now().add(const Duration(hours: 1));

  AIService()
      : _hfToken = dotenv.env['HF_TOKEN'] ?? '',
        _geminiKey = dotenv.env['GEMINI_API_KEY'] ?? '',
        _orKey = dotenv.env['OPENROUTER_API_KEY'] ?? '';

  // ── Chat model rotation ────────────────────────────────────────────────────

  void _advanceChatModel() {
    _chatModelIndex++;
    _chatResetAt = DateTime.now().add(const Duration(hours: 1));
    if (_chatModelIndex < _kChatModels.length) {
      debugPrint('[AI] Switched chat model to ${_kChatModels[_chatModelIndex].modelId}');
    }
  }

  void _maybeResetChatModel() {
    if (_chatModelIndex > 0 && DateTime.now().isAfter(_chatResetAt)) {
      debugPrint('[AI] Reset chat model to ${_kChatModels[0].modelId}');
      _chatModelIndex = 0;
    }
  }

  String get activeChatModel {
    _maybeResetChatModel();
    if (_chatModelIndex >= _kChatModels.length) return 'none (exhausted)';
    return _kChatModels[_chatModelIndex].modelId;
  }

  // ── Vision model rotation ──────────────────────────────────────────────────

  void _advanceVisionModel() {
    _visionModelIndex++;
    _visionResetAt = DateTime.now().add(const Duration(hours: 1));
    if (_visionModelIndex < _kVisionModels.length) {
      debugPrint('[AI] Switched vision model to ${_kVisionModels[_visionModelIndex].modelId}');
    }
  }

  void _maybeResetVisionModel() {
    if (_visionModelIndex > 0 && DateTime.now().isAfter(_visionResetAt)) {
      debugPrint('[AI] Reset vision model to ${_kVisionModels[0].modelId}');
      _visionModelIndex = 0;
    }
  }

  String get activeVisionModel {
    _maybeResetVisionModel();
    if (_visionModelIndex >= _kVisionModels.length) return 'none (exhausted)';
    return _kVisionModels[_visionModelIndex].modelId;
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  void clearHistory() {
    _history = [];
    _userContext = null;
  }

  void setUserContext(String context) => _userContext = context;

  void loadHistory(List<ChatMessageDoc> history) {
    _history = history
        .where((doc) => !doc.isWidget && doc.text.isNotEmpty)
        .map((doc) => {
              'role': doc.isUser ? 'user' : 'assistant',
              'content': doc.text,
            })
        .toList();
  }

  /// Sends a chat message, automatically cascading through Gemini and HuggingFace models.
  Future<String?> sendMessage(String text) async {
    _maybeResetChatModel();
    _history.add({'role': 'user', 'content': text});

    while (_chatModelIndex < _kChatModels.length) {
      final config = _kChatModels[_chatModelIndex];

      try {
        String? response;
        if (config.provider == AIProvider.openrouter) {
          response = await _sendOpenRouterMessage(config.modelId);
        } else if (config.provider == AIProvider.gemini) {
          response = await _sendGeminiMessage(config.modelId);
        } else {
          response = await _sendHfMessage(config.modelId);
        }

        if (response != null && response.isNotEmpty) {
          _history.add({'role': 'assistant', 'content': response});
          return response;
        }
      } catch (e) {
        debugPrint('[AI] ${config.modelId} failed: $e');
        _advanceChatModel();
        continue;
      }
    }

    _history.removeLast();
    return '__ALL_EXHAUSTED__';
  }

  /// Streams a chat message, cascading if models fail before yielding tokens.
  Stream<String> streamMessage(String text) async* {
    _maybeResetChatModel();
    _history.add({'role': 'user', 'content': text});

    String fullResponse = '';
    bool succeeded = false;

    while (_chatModelIndex < _kChatModels.length) {
      final config = _kChatModels[_chatModelIndex];

      try {
        if (config.provider == AIProvider.openrouter) {
          await for (final chunk in _streamOpenRouterMessage(config.modelId)) {
            if (chunk == '__FALLBACK_TRIGGER__') {
              succeeded = false;
              break; 
            }
            if (chunk.startsWith('__ERROR__:')) {
              yield chunk;
              _history.removeLast();
              return;
            }
            fullResponse += chunk;
            yield chunk;
            succeeded = true;
          }
        } else if (config.provider == AIProvider.gemini) {
          await for (final chunk in _streamGeminiMessage(config.modelId)) {
            fullResponse += chunk;
            yield chunk;
            succeeded = true;
          }
        } else {
          await for (final chunk in _streamHfMessage(config.modelId)) {
            if (chunk == '__FALLBACK_TRIGGER__') {
              succeeded = false;
              break; 
            }
            if (chunk.startsWith('__ERROR__:')) {
              yield chunk;
              _history.removeLast();
              return;
            }
            fullResponse += chunk;
            yield chunk;
            succeeded = true;
          }
        }

        if (succeeded) break;

        // If not succeeded (triggered fallback internally)
        _advanceChatModel();
      } catch (e) {
        debugPrint('[AI] ${config.modelId} stream failed: $e');
        _advanceChatModel();
      }
    }

    if (!succeeded) {
      _history.removeLast();
      yield '__ALL_EXHAUSTED__';
      return;
    }

    if (fullResponse.isNotEmpty) {
      _history.add({'role': 'assistant', 'content': fullResponse});
    } else {
      _history.removeLast();
    }
  }

  /// Analyzes a food image cascading through vision models.
  Future<String?> analyzeFoodImage(List<int> imageBytes, String mimeType) async {
    _maybeResetVisionModel();

    // Resize/compress: HF serverless limit is ~2MB JSON. Gemini accepts up to 20MB.
    final bytes = imageBytes.length > 1500000
        ? imageBytes.sublist(0, 1500000)
        : imageBytes;

    while (_visionModelIndex < _kVisionModels.length) {
      final config = _kVisionModels[_visionModelIndex];
      try {
        String? response;
        if (config.provider == AIProvider.gemini) {
          response = await _analyzeFoodImageGemini(bytes, mimeType, config.modelId);
        } else {
          response = await _analyzeFoodImageHf(bytes, mimeType, config.modelId);
        }

        if (response != null && response.isNotEmpty) {
          return response;
        }
      } catch (e) {
        debugPrint('[AI] ${config.modelId} vision failed: $e');
        _advanceVisionModel();
      }
    }

    return null; // All vision models exhausted
  }

  // ─── Internal OpenRouter Implementations ──────────────────────────────────

  Future<String?> _sendOpenRouterMessage(String modelId) async {
    if (_orKey.isEmpty) throw Exception('OPENROUTER_API_KEY missing');
    final response = await http.post(
      Uri.parse(_kOrUrl),
      headers: {
        'Authorization': 'Bearer $_orKey',
        'HTTP-Referer': 'https://github.com/HealthAI', 
        'X-Title': 'HealthAI Coach',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': modelId,
        'messages': _buildHfMessages(), // Same struct as HF
        'max_tokens': 3000,
        'temperature': 0.7,
        'stream': false,
      }),
    );

    debugPrint('[OR chat] $modelId → ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'] as String? ?? '';
    } else if (_isFallbackError(response.statusCode, response.body)) {
      throw Exception('OpenRouter Quota or Rate Limit hit');
    } else {
      debugPrint('[OR chat] $modelId error: ${response.body}');
      throw Exception('OR Error: ${response.statusCode}');
    }
  }

  Stream<String> _streamOpenRouterMessage(String modelId) async* {
    if (_orKey.isEmpty) {
      yield '__FALLBACK_TRIGGER__';
      return;
    }
    final request = http.Request('POST', Uri.parse(_kOrUrl));
    request.headers['Authorization'] = 'Bearer $_orKey';
    request.headers['HTTP-Referer'] = 'https://github.com/HealthAI';
    request.headers['X-Title'] = 'HealthAI Coach';
    request.headers['Content-Type'] = 'application/json';
    request.headers['Accept'] = 'text/event-stream';
    request.body = jsonEncode({
      'model': modelId,
      'messages': _buildHfMessages(),
      'max_tokens': 3000,
      'temperature': 0.7,
      'stream': true,
    });

    final streamedResponse =
        await http.Client().send(request).timeout(const Duration(seconds: 90));

    debugPrint('[OR stream] $modelId → ${streamedResponse.statusCode}');

    if (streamedResponse.statusCode == 200) {
      final byteStream = streamedResponse.stream;
      final lines = byteStream
          .transform(const Utf8Decoder())
          .transform(const LineSplitter());

      await for (final line in lines) {
        if (line.startsWith('data: ')) {
          final raw = line.substring(6).trim();
          if (raw == '[DONE]') break;
          try {
            final json = jsonDecode(raw) as Map<String, dynamic>;
            final delta = json['choices']?[0]?['delta']?['content'] as String?;
            if (delta != null && delta.isNotEmpty) {
              yield delta;
            }
          } catch (_) {}
        }
      }
    } else {
      final body = await streamedResponse.stream.transform(const Utf8Decoder()).join();
      if (_isFallbackError(streamedResponse.statusCode, body)) {
        yield '__FALLBACK_TRIGGER__';
      } else {
        yield '__ERROR__: ${streamedResponse.statusCode}';
      }
    }
  }

  // ─── Internal Gemini Implementations ────────────────────────────────────────

  Future<String?> _sendGeminiMessage(String modelId) async {
    if (_geminiKey.isEmpty) throw Exception('GEMINI_API_KEY missing');

    final model = gemini.GenerativeModel(
      model: modelId,
      apiKey: _geminiKey,
      systemInstruction: gemini.Content.system(
          _kSystemPrompt + (_userContext != null ? '\n\nUser Health Context:\n$_userContext' : '')),
    );

    final contents = _history.map((m) => gemini.Content(
        m['role'] == 'user' ? 'user' : 'model', [gemini.TextPart(m['content']!)])).toList();

    debugPrint('[Gemini chat] $modelId request...');
    final response = await model.generateContent(contents);
    return response.text;
  }

  Stream<String> _streamGeminiMessage(String modelId) async* {
    if (_geminiKey.isEmpty) throw Exception('GEMINI_API_KEY missing');

    final model = gemini.GenerativeModel(
      model: modelId,
      apiKey: _geminiKey,
      systemInstruction: gemini.Content.system(
          _kSystemPrompt + (_userContext != null ? '\n\nUser Health Context:\n$_userContext' : '')),
    );

    final contents = _history.map((m) => gemini.Content(
        m['role'] == 'user' ? 'user' : 'model', [gemini.TextPart(m['content']!)])).toList();

    debugPrint('[Gemini stream] $modelId request...');
    final stream = model.generateContentStream(contents);
    await for (final chunk in stream) {
      if (chunk.text != null && chunk.text!.isNotEmpty) {
        yield chunk.text!;
      }
    }
  }

  Future<String?> _analyzeFoodImageGemini(List<int> bytes, String mimeType, String modelId) async {
    if (_geminiKey.isEmpty) throw Exception('GEMINI_API_KEY missing');

    final model = gemini.GenerativeModel(
      model: modelId,
      apiKey: _geminiKey,
      generationConfig: gemini.GenerationConfig(temperature: 0.1),
    );

    final content = gemini.Content.multi([
      gemini.TextPart('$_kVisionSystemPrompt\nAnalyze this food image and return the nutritional info as JSON.'),
      gemini.DataPart(mimeType, Uint8List.fromList(bytes)),
    ]);

    debugPrint('[Gemini vision] $modelId request...');
    final response = await model.generateContent([content]);
    return response.text;
  }

  // ─── Internal Hugging Face Implementations ──────────────────────────────────

  List<Map<String, String>> _buildHfMessages() {
    return [
      {'role': 'system', 'content': _kSystemPrompt},
      if (_userContext != null) {'role': 'system', 'content': _userContext!},
      ..._history,
    ];
  }

  Future<String?> _sendHfMessage(String modelId) async {
    if (_hfToken.isEmpty) throw Exception('HF_TOKEN missing');
    final response = await http.post(
      Uri.parse(_kHfRouterUrl),
      headers: {
        'Authorization': 'Bearer $_hfToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': modelId,
        'messages': _buildHfMessages(),
        'max_tokens': 3000,
        'temperature': 0.7,
        'stream': false,
      }),
    );

    debugPrint('[HF chat] $modelId → ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'] as String? ?? '';
    } else if (_isFallbackError(response.statusCode, response.body)) {
      throw Exception('HF Quota or Rate Limit hit');
    } else {
      debugPrint('[HF chat] $modelId error: ${response.body}');
      throw Exception('HF Error: ${response.statusCode}');
    }
  }

  Stream<String> _streamHfMessage(String modelId) async* {
    if (_hfToken.isEmpty) {
      yield '__FALLBACK_TRIGGER__';
      return;
    }
    final request = http.Request('POST', Uri.parse(_kHfRouterUrl));
    request.headers['Authorization'] = 'Bearer $_hfToken';
    request.headers['Content-Type'] = 'application/json';
    request.headers['Accept'] = 'text/event-stream';
    request.body = jsonEncode({
      'model': modelId,
      'messages': _buildHfMessages(),
      'max_tokens': 3000,
      'temperature': 0.7,
      'stream': true,
    });

    final streamedResponse =
        await http.Client().send(request).timeout(const Duration(seconds: 90));

    debugPrint('[HF stream] $modelId → ${streamedResponse.statusCode}');

    if (streamedResponse.statusCode == 200) {
      final byteStream = streamedResponse.stream;
      final lines = byteStream
          .transform(const Utf8Decoder())
          .transform(const LineSplitter());

      await for (final line in lines) {
        if (line.startsWith('data: ')) {
          final raw = line.substring(6).trim();
          if (raw == '[DONE]') break;
          try {
            final json = jsonDecode(raw) as Map<String, dynamic>;
            final delta = json['choices']?[0]?['delta']?['content'] as String?;
            if (delta != null && delta.isNotEmpty) {
              yield delta;
            }
          } catch (_) {}
        }
      }
    } else {
      final body = await streamedResponse.stream.transform(const Utf8Decoder()).join();
      if (_isFallbackError(streamedResponse.statusCode, body)) {
        yield '__FALLBACK_TRIGGER__';
      } else {
        yield '__ERROR__: ${streamedResponse.statusCode}';
      }
    }
  }

  Future<String?> _analyzeFoodImageHf(List<int> bytes, String mimeType, String modelId) async {
    if (_hfToken.isEmpty) throw Exception('HF_TOKEN missing');
    final base64Image = base64Encode(bytes);
    final dataUri = 'data:$mimeType;base64,$base64Image';

    final messages = [
      {'role': 'system', 'content': _kVisionSystemPrompt},
      {
        'role': 'user',
        'content': [
          {
            'type': 'text',
            'text': 'Analyze this food image and return the nutritional info as JSON.',
          },
          {
            'type': 'image_url',
            'image_url': {'url': dataUri},
          },
        ],
      },
    ];

    final response = await http.post(
      Uri.parse(_kHfRouterUrl),
      headers: {
        'Authorization': 'Bearer $_hfToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': modelId,
        'messages': messages,
        'max_tokens': 256,
        'temperature': 0.1,
        'stream': false,
      }),
    );

    debugPrint('[HF vision] $modelId → ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'] as String? ?? '';
    } else if (_isFallbackError(response.statusCode, response.body)) {
      throw Exception('HF quota exceeded');
    }
    return null;
  }
}
