import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../src/database/models/chat_session_doc.dart';

final aiServiceProvider = Provider<AIService>((ref) {
  return AIService();
});

// ─── HuggingFace chat models ──────────────────────────────────────────────────
// Tried in order. Falls back on quota/rate-limit.
const List<String> _kHfChatModels = [
  'meta-llama/Llama-3.3-70B-Instruct',  // Best: strong health/fitness reasoning
  'meta-llama/Llama-3.1-8B-Instruct',   // Fallback: fast & free
  'mistralai/Mistral-7B-Instruct-v0.3', // Last resort
];

// ─── HuggingFace vision models (food scanner) ────────────────────────────────
// Multimodal models that accept base64 images via the same HF Router endpoint.
const List<String> _kHfVisionModels = [
  'Qwen/Qwen2.5-VL-7B-Instruct',            // Best: state-of-art food recognition
  'meta-llama/Llama-3.2-11B-Vision-Instruct', // Fallback: strong reasoning
];

const String _kHfRouterUrl =
    'https://router.huggingface.co/v1/chat/completions';

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

bool _isHfFallbackError(int statusCode, String body) {
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

  // Chat state
  int _chatModelIndex = 0;
  DateTime _chatResetAt = DateTime.now().add(const Duration(hours: 1));
  List<Map<String, String>> _history = [];
  String? _userContext; // injected once per session, sent as a system message

  // Vision state
  int _visionModelIndex = 0;
  DateTime _visionResetAt = DateTime.now().add(const Duration(hours: 1));

  AIService() : _hfToken = _resolveHfToken();

  static String _resolveHfToken() {
    final key = dotenv.env['HF_TOKEN'] ?? '';
    if (key.isEmpty) {
      throw Exception(
          'HF_TOKEN is not set in the .env file. Please add your HuggingFace token.');
    }
    return key;
  }

  // ── Chat model rotation ────────────────────────────────────────────────────

  void _advanceChatModel() {
    _chatModelIndex++;
    _chatResetAt = DateTime.now().add(const Duration(hours: 1));
    if (_chatModelIndex < _kHfChatModels.length) {
      debugPrint('[HF] Switching chat → ${_kHfChatModels[_chatModelIndex]}');
    }
  }

  void _maybeResetChatModel() {
    if (_chatModelIndex > 0 && DateTime.now().isAfter(_chatResetAt)) {
      debugPrint('[HF] 1h reset — chat back to ${_kHfChatModels[0]}');
      _chatModelIndex = 0;
    }
  }

  String get activeChatModel {
    _maybeResetChatModel();
    if (_chatModelIndex >= _kHfChatModels.length) return 'none (all exhausted)';
    return _kHfChatModels[_chatModelIndex];
  }

  // ── Vision model rotation ──────────────────────────────────────────────────

  void _advanceVisionModel() {
    _visionModelIndex++;
    _visionResetAt = DateTime.now().add(const Duration(hours: 1));
    if (_visionModelIndex < _kHfVisionModels.length) {
      debugPrint(
          '[HF] Switching vision → ${_kHfVisionModels[_visionModelIndex]}');
    }
  }

  void _maybeResetVisionModel() {
    if (_visionModelIndex > 0 && DateTime.now().isAfter(_visionResetAt)) {
      debugPrint('[HF] 1h reset — vision back to ${_kHfVisionModels[0]}');
      _visionModelIndex = 0;
    }
  }

  String get activeVisionModel {
    _maybeResetVisionModel();
    if (_visionModelIndex >= _kHfVisionModels.length) {
      return 'none (all exhausted)';
    }
    return _kHfVisionModels[_visionModelIndex];
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  void clearHistory() {
    _history = [];
    _userContext = null;
  }

  /// Sets the user's health profile context. Called on every new/loaded session
  /// so the AI always has the user's data and never needs to re-ask for it.
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

  List<Map<String, String>> _buildMessages() {
    return [
      {'role': 'system', 'content': _kSystemPrompt},
      if (_userContext != null) {'role': 'system', 'content': _userContext!},
      ..._history,
    ];
  }

  /// Sends a chat message via HuggingFace Inference Router.
  /// Falls back through [_kHfChatModels] on quota/rate-limit errors.
  Future<String?> sendMessage(String text) async {
    _maybeResetChatModel();
    _history.add({'role': 'user', 'content': text});
    final messages = _buildMessages();

    while (_chatModelIndex < _kHfChatModels.length) {
      final model = _kHfChatModels[_chatModelIndex];
      try {
        final response = await http.post(
          Uri.parse(_kHfRouterUrl),
          headers: {
            'Authorization': 'Bearer $_hfToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': model,
            'messages': messages,
            'max_tokens': 3000,
            'temperature': 0.7,
            'stream': false,
          }),
        );

        debugPrint('[HF chat] $model → ${response.statusCode}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final content =
              data['choices'][0]['message']['content'] as String? ?? '';
          _history.add({'role': 'assistant', 'content': content});
          return content;
        } else if (_isHfFallbackError(response.statusCode, response.body)) {
          debugPrint('[HF chat] $model rate-limited, falling back');
          _advanceChatModel();
          continue;
        } else {
          debugPrint('[HF chat] $model error: ${response.body}');
          _history.removeLast();
          return "I'm having trouble connecting right now. Please try again in a moment.";
        }
      } catch (e) {
        debugPrint('[HF chat] $model exception: $e');
        _history.removeLast();
        return "I'm having trouble connecting right now. Please try again in a moment.";
      }
    }

    _history.removeLast();
    return '__ALL_EXHAUSTED__';
  }

  /// Streams chat tokens via HuggingFace Server-Sent Events.
  /// Yields each incremental text delta as a [String].
  /// On quota/error, yields a sentinel string starting with '__ERROR__:'.
  Stream<String> streamMessage(String text) async* {
    _maybeResetChatModel();
    _history.add({'role': 'user', 'content': text});
    final messages = _buildMessages();

    String fullResponse = '';
    bool succeeded = false;

    while (_chatModelIndex < _kHfChatModels.length) {
      final model = _kHfChatModels[_chatModelIndex];
      try {
        final request = http.Request('POST', Uri.parse(_kHfRouterUrl));
        request.headers['Authorization'] = 'Bearer $_hfToken';
        request.headers['Content-Type'] = 'application/json';
        request.headers['Accept'] = 'text/event-stream';
        request.body = jsonEncode({
          'model': model,
          'messages': messages,
          'max_tokens': 3000,
          'temperature': 0.7,
          'stream': true,
        });

        final streamedResponse =
            await http.Client().send(request).timeout(const Duration(seconds: 90));

        debugPrint('[HF stream] $model → ${streamedResponse.statusCode}');

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
                final delta =
                    json['choices']?[0]?['delta']?['content'] as String?;
                if (delta != null && delta.isNotEmpty) {
                  fullResponse += delta;
                  yield delta;
                }
              } catch (_) {
                // Malformed SSE chunk — skip
              }
            }
          }

          succeeded = true;
          break;
        } else {
          final body = await streamedResponse.stream
              .transform(const Utf8Decoder())
              .join();
          if (_isHfFallbackError(streamedResponse.statusCode, body)) {
            debugPrint('[HF stream] $model rate-limited, falling back');
            _advanceChatModel();
            continue;
          }
          yield '__ERROR__: ${streamedResponse.statusCode}';
          _history.removeLast();
          return;
        }
      } on TimeoutException {
        debugPrint('[HF stream] $model timeout');
        _advanceChatModel();
        continue;
      } catch (e) {
        debugPrint('[HF stream] $model exception: $e');
        yield '__ERROR__: $e';
        _history.removeLast();
        return;
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

  /// Analyzes a food image using HuggingFace vision models.
  /// Falls back through [_kHfVisionModels] on quota/rate-limit errors.
  Future<String?> analyzeFoodImage(
      List<int> imageBytes, String mimeType) async {
    _maybeResetVisionModel();

    // Resize/compress: HF serverless has a ~2MB JSON body limit.
    final bytes = imageBytes.length > 1500000
        ? imageBytes.sublist(0, 1500000)
        : imageBytes;

    final base64Image = base64Encode(bytes);
    final dataUri = 'data:$mimeType;base64,$base64Image';

    final messages = [
      {
        'role': 'system',
        'content': _kVisionSystemPrompt,
      },
      {
        'role': 'user',
        'content': [
          {
            'type': 'text',
            'text':
                'Analyze this food image and return the nutritional info as JSON.',
          },
          {
            'type': 'image_url',
            'image_url': {'url': dataUri},
          },
        ],
      },
    ];

    while (_visionModelIndex < _kHfVisionModels.length) {
      final model = _kHfVisionModels[_visionModelIndex];
      try {
        final response = await http.post(
          Uri.parse(_kHfRouterUrl),
          headers: {
            'Authorization': 'Bearer $_hfToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': model,
            'messages': messages,
            'max_tokens': 256,
            'temperature': 0.1,
            'stream': false,
          }),
        );

        debugPrint('[HF vision] $model → ${response.statusCode}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final content =
              data['choices'][0]['message']['content'] as String? ?? '';
          return content;
        } else if (_isHfFallbackError(response.statusCode, response.body)) {
          debugPrint('[HF vision] $model rate-limited, falling back');
          _advanceVisionModel();
          continue;
        } else {
          debugPrint('[HF vision] $model error: ${response.body}');
          return null;
        }
      } catch (e) {
        debugPrint('[HF vision] $model exception: $e');
        return null;
      }
    }

    return null; // all vision models exhausted
  }
}
