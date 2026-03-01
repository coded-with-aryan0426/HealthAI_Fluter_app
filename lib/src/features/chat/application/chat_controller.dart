import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/ai_service.dart';
import '../../../services/gemma_service.dart';
import '../../../services/local_db_service.dart';
import '../../../services/ai_context_builder.dart';
import '../../../database/models/chat_session_doc.dart';
import '../../workout/application/workout_plan_parser.dart';
import '../../nutrition/application/meal_plan_parser.dart';
import 'weekly_report_provider.dart';

final chatControllerProvider =
    NotifierProvider<ChatController, ChatSessionDoc?>(ChatController.new);

/// Typing indicator (shows bouncing dots during the FIRST token wait).
final chatTypingProvider = StateProvider<bool>((ref) => false);

/// Rate-limit countdown: remaining seconds (0 = not rate-limited).
final chatRateLimitProvider = StateProvider<int>((ref) => 0);

/// Holds the incrementally-streamed text for the current AI response.
/// The UI renders this as the "live" assistant bubble while streaming.
final chatStreamingTextProvider = StateProvider<String?>((ref) => null);

/// One-shot prefilled message: set from outside chat (e.g. AI Insight "Chat about this").
/// ChatScreen consumes and clears it in initState.
final chatPrefilledMessageProvider = StateProvider<String?>((ref) => null);

class ChatController extends Notifier<ChatSessionDoc?> {
  Timer? _rateLimitTimer;

  @override
  ChatSessionDoc? build() => null;

  Future<void> loadSession(Id sessionId) async {
    final isar = ref.read(isarProvider);
    final session = await isar.chatSessionDocs.get(sessionId);
    if (session != null) {
      final prefs = await SharedPreferences.getInstance();
      final contextMemory = prefs.getBool('context_memory_enabled') ?? true;
      ref.read(aiServiceProvider).loadHistory(session.messages);
      if (contextMemory) {
        ref.read(aiServiceProvider).setUserContext(buildAiContext(ref));
      }
      await ref.read(gemmaServiceProvider).clearChat();
      state = session;
    }
  }

  Future<void> startNewSession() async {
    final isar = ref.read(isarProvider);
    final prefs = await SharedPreferences.getInstance();
    final contextMemory = prefs.getBool('context_memory_enabled') ?? true;

    final newSession = ChatSessionDoc()
      ..title = "New Conversation"
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now()
      ..messages = [];

    ref.read(aiServiceProvider).clearHistory();
    if (contextMemory) {
      ref.read(aiServiceProvider).setUserContext(buildAiContext(ref));
    }
    await ref.read(gemmaServiceProvider).clearChat();

    await isar.writeTxn(() async {
      await isar.chatSessionDocs.put(newSession);
    });

    state = newSession;
  }

  void _startRateLimitCountdown(int seconds) {
    _rateLimitTimer?.cancel();
    ref.read(chatRateLimitProvider.notifier).state = seconds;
    _rateLimitTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      final current = ref.read(chatRateLimitProvider);
      if (current <= 1) {
        t.cancel();
        _rateLimitTimer = null;
        ref.read(chatRateLimitProvider.notifier).state = 0;
      } else {
        ref.read(chatRateLimitProvider.notifier).state = current - 1;
      }
    });
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    if (ref.read(chatRateLimitProvider) > 0) return;

    if (state == null) await startNewSession();

    final isar = ref.read(isarProvider);
    final currentSession = state!;
    final isOffline = ref.read(offlineModeProvider);

    final userMsg = ChatMessageDoc()
      ..text = text
      ..isUser = true
      ..timestamp = DateTime.now();

    final updatedMessages =
        List<ChatMessageDoc>.from(currentSession.messages)..add(userMsg);
    currentSession.messages = updatedMessages;
    currentSession.updatedAt = DateTime.now();

    // Auto-title from first user message
    if (currentSession.messages.length <= 2) {
      currentSession.title =
          text.length > 28 ? "${text.substring(0, 28)}..." : text;
    }

    await isar.writeTxn(() async {
      await isar.chatSessionDocs.put(currentSession);
    });

    state = currentSession;
    ref.read(chatTypingProvider.notifier).state = true;

    String? responseText;

      if (isOffline) {
        // ── On-device Gemma path ───────────────────────────────────────────────
        try {
          final isFirstMessage = currentSession.messages.length == 1;
          final prompt = isFirstMessage
              ? '$text\n\n${buildAiContext(ref)}'
              : text;
          responseText =
              await ref.read(gemmaServiceProvider).sendMessage(prompt);
        } catch (e) {
          responseText =
              "⚠️ Offline AI error: ${e.toString().split('\n').first}. "
              "Make sure the model is fully loaded.";
        }
      } else {
        // ── AI (cloud) path ────────────────────────────────────────────────────
        final aiService = ref.read(aiServiceProvider);
        final prefs = await SharedPreferences.getInstance();
        final useStreaming = prefs.getBool('streaming_responses_enabled') ?? true;

        if (useStreaming) {
          // Stream tokens — show live bubble
          final buffer = StringBuffer();
          await for (final delta in aiService.streamMessage(text)) {
            if (delta == '__ALL_EXHAUSTED__') {
              responseText = '__ALL_EXHAUSTED__';
              break;
            }
            if (delta.startsWith('__ERROR__:')) {
              responseText =
                  "I'm having trouble connecting right now. Please try again in a moment.";
              break;
            }
            buffer.write(delta);
            ref.read(chatStreamingTextProvider.notifier).state = buffer.toString();
          }
          if (responseText == null && buffer.isNotEmpty) {
            responseText = buffer.toString();
          }
        } else {
          // Non-streaming: single request
          final result = await aiService.sendMessage(text);
          responseText = result;
        }
        // Clear streaming state
        ref.read(chatStreamingTextProvider.notifier).state = null;
      }

    ref.read(chatTypingProvider.notifier).state = false;

    // Network error
    if (responseText == null) {
      final errMsg = ChatMessageDoc()
        ..text =
            "I'm having trouble connecting right now. Please check your internet connection and try again."
        ..isUser = false
        ..timestamp = DateTime.now();
      currentSession.messages =
          List<ChatMessageDoc>.from(currentSession.messages)..add(errMsg);
      currentSession.updatedAt = DateTime.now();
      await isar.writeTxn(
          () async => isar.chatSessionDocs.put(currentSession));
      state = currentSession;
      return;
    }

    // All models exhausted sentinel
    if (responseText == '__ALL_EXHAUSTED__') {
      final exhaustedMsg = ChatMessageDoc()
        ..text =
            '⚠️ All available AI models have hit their quota limits. Please try again in an hour, or switch to **Offline Mode**.'
        ..isUser = false
        ..timestamp = DateTime.now();
      currentSession.messages =
          List<ChatMessageDoc>.from(currentSession.messages)..add(exhaustedMsg);
      currentSession.updatedAt = DateTime.now();
      await isar.writeTxn(
          () async => isar.chatSessionDocs.put(currentSession));
      state = currentSession;
      return;
    }

    // Rate-limit sentinel
    if (responseText.startsWith('__RATE_LIMIT__:')) {
      final secs = int.tryParse(responseText.split(':').last) ?? 60;
      _startRateLimitCountdown(secs);
      final rateLimitMsg = ChatMessageDoc()
        ..text =
            '⏳ API quota reached. I\'ll be ready again in **$secs seconds**.'
        ..isUser = false
        ..timestamp = DateTime.now();
      currentSession.messages =
          List<ChatMessageDoc>.from(currentSession.messages)..add(rateLimitMsg);
      currentSession.updatedAt = DateTime.now();
      await isar.writeTxn(
          () async => isar.chatSessionDocs.put(currentSession));
      state = currentSession;
      return;
    }

    // ── Parse for workout plan and meal plan JSON fences ──────────────────────
    final workoutParsed = WorkoutPlanParser.parse(responseText);
    final mealParsed = MealPlanParser.parse(workoutParsed.cleanText);
    final aiMsgs = <ChatMessageDoc>[];

    // Clean text (both fences stripped) as a normal text bubble
    if (mealParsed.cleanText.isNotEmpty) {
      aiMsgs.add(ChatMessageDoc()
        ..text = mealParsed.cleanText
        ..isUser = false
        ..widgetType = ''
        ..timestamp = DateTime.now());
    }

    // Workout plan widget bubble
    if (workoutParsed.hasPlan) {
      aiMsgs.add(ChatMessageDoc()
        ..text = jsonEncode(workoutParsed.plan!.toJson())
        ..isUser = false
        ..isWidget = true
        ..widgetType = 'workout'
        ..timestamp = DateTime.now().add(const Duration(milliseconds: 100)));
    }

    // Meal plan widget bubble
    if (mealParsed.hasPlan) {
      aiMsgs.add(ChatMessageDoc()
        ..text = jsonEncode(mealParsed.plan!.toJson())
        ..isUser = false
        ..isWidget = true
        ..widgetType = 'meal'
        ..timestamp = DateTime.now().add(const Duration(milliseconds: 200)));
    }

    currentSession.messages =
        List<ChatMessageDoc>.from(currentSession.messages)..addAll(aiMsgs);
    currentSession.updatedAt = DateTime.now();

    await isar.writeTxn(() async => isar.chatSessionDocs.put(currentSession));
    state = currentSession;
  }

  /// Picks an image from the gallery/camera, sends it to the vision AI, and
  /// injects a [food_scan] widget bubble with the nutrition result.
  Future<void> sendImageMessage({ImageSource source = ImageSource.gallery}) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1024,
    );
    if (picked == null) return;

    if (state == null) await startNewSession();

    final isar = ref.read(isarProvider);
    final currentSession = state!;

    // User bubble showing image placeholder
    final userMsg = ChatMessageDoc()
      ..text = '📷 Food photo attached — analysing nutrition…'
      ..isUser = true
      ..timestamp = DateTime.now();

    final msgs = List<ChatMessageDoc>.from(currentSession.messages)..add(userMsg);
    currentSession.messages = msgs;
    currentSession.updatedAt = DateTime.now();
    if (currentSession.messages.length <= 2) {
      currentSession.title = 'Food Scan';
    }
    await isar.writeTxn(() async => isar.chatSessionDocs.put(currentSession));
    state = currentSession;
    ref.read(chatTypingProvider.notifier).state = true;

    // Call vision API
    final bytes = await picked.readAsBytes();
    final ext = picked.path.split('.').last.toLowerCase();
    final mime = ext == 'png' ? 'image/png' : 'image/jpeg';
    final result = await ref.read(aiServiceProvider).analyzeFoodImage(bytes, mime);

    ref.read(chatTypingProvider.notifier).state = false;

    final scanJson = result?.trim().isNotEmpty == true ? result! : '{}';

    // AI bubble — food_scan widget type
    final aiMsg = ChatMessageDoc()
      ..text = scanJson
      ..isUser = false
      ..isWidget = true
      ..widgetType = 'food_scan'
      ..timestamp = DateTime.now();

    currentSession.messages =
        List<ChatMessageDoc>.from(currentSession.messages)..add(aiMsg);
    currentSession.updatedAt = DateTime.now();
    await isar.writeTxn(() async => isar.chatSessionDocs.put(currentSession));
    state = currentSession;
  }

  /// Generates a weekly report card and injects it as a widget bubble in chat.
  Future<void> requestWeeklyReport() async {
    if (state == null) await startNewSession();
    final isar = ref.read(isarProvider);
    final currentSession = state!;

    // User trigger message
    final userMsg = ChatMessageDoc()
      ..text = '📊 Generate my weekly health report card'
      ..isUser = true
      ..timestamp = DateTime.now();

    // Typing indicator while generating
    ref.read(chatTypingProvider.notifier).state = true;
    currentSession.messages =
        List<ChatMessageDoc>.from(currentSession.messages)..add(userMsg);
    currentSession.updatedAt = DateTime.now();
    if (currentSession.messages.length <= 2) {
      currentSession.title = 'Weekly Report';
    }
    await isar.writeTxn(() async => isar.chatSessionDocs.put(currentSession));
    state = currentSession;

    // Generate report data
    try {
      await ref.read(weeklyReportProvider.notifier).generate();
    } catch (_) {}

    ref.read(chatTypingProvider.notifier).state = false;

    // Inject as a widget bubble — the 'report' widgetType renders WeeklyReportCard
    final reportMsg = ChatMessageDoc()
      ..text = 'weekly_report'
      ..isUser = false
      ..isWidget = true
      ..widgetType = 'report'
      ..timestamp = DateTime.now();

    currentSession.messages =
        List<ChatMessageDoc>.from(currentSession.messages)..add(reportMsg);
    currentSession.updatedAt = DateTime.now();
    await isar.writeTxn(() async => isar.chatSessionDocs.put(currentSession));
    state = currentSession;
  }
}
