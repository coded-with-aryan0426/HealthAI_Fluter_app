import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../services/local_db_service.dart';
import '../../../services/ai_service.dart';
import '../../../database/models/workout_doc.dart';

// ── Data model ────────────────────────────────────────────────────────────────

class AdaptiveSuggestion {
  final String title;
  final String body;
  final String type; // 'increase_weight' | 'add_volume' | 'deload' | 'general'
  final String exerciseName;

  const AdaptiveSuggestion({
    required this.title,
    required this.body,
    required this.type,
    required this.exerciseName,
  });

  factory AdaptiveSuggestion.fromJson(Map<String, dynamic> json) {
    return AdaptiveSuggestion(
      title: json['title'] as String? ?? 'Suggestion',
      body: json['body'] as String? ?? '',
      type: json['type'] as String? ?? 'general',
      exerciseName: json['exercise_name'] as String? ?? '',
    );
  }
}

class AdaptiveAnalysisResult {
  final List<AdaptiveSuggestion> suggestions;
  final String weekSummary;
  final DateTime analysedAt;

  const AdaptiveAnalysisResult({
    required this.suggestions,
    required this.weekSummary,
    required this.analysedAt,
  });
}

// ── State notifier ────────────────────────────────────────────────────────────

class AdaptiveAnalysisNotifier
    extends AsyncNotifier<AdaptiveAnalysisResult?> {
  @override
  Future<AdaptiveAnalysisResult?> build() async {
    // Build result from last week's workouts
    return _runAnalysis();
  }

  Future<AdaptiveAnalysisResult?> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_runAnalysis);
    return state.valueOrNull;
  }

  Future<AdaptiveAnalysisResult?> _runAnalysis() async {
    final isar = ref.read(isarProvider);
    final ai = ref.read(aiServiceProvider);

    // Collect last 7 days of workouts
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final docs = isar.workoutDocs
        .where()
        .idGreaterThan(0)
        .findAllSync()
      ..removeWhere((d) => d.date.isBefore(cutoff));

    if (docs.isEmpty) return null;

    // Build a compact workout summary for the AI
    final summary = _buildWorkoutSummary(docs);
    if (summary.isEmpty) return null;

    const systemPrompt =
        'You are an AI personal trainer. Analyse the user\'s last 7 days of '
        'workouts and return ONLY a valid JSON object with no markdown wrapper. '
        'Format: {"week_summary": "...", "suggestions": ['
        '{"title": "...", "body": "...", "type": "increase_weight|add_volume|deload|general", "exercise_name": "..."}'
        ']}. '
        'Provide 2–4 actionable, specific suggestions. '
        'week_summary should be 1–2 sentences. '
        'suggestion body should be ≤ 30 words.';

    try {
      // Use a one-shot HuggingFace call (not via the chat history)
      final rawResponse = await _callHuggingFace(
        ai,
        system: systemPrompt,
        user: 'Workout data from the last 7 days:\n$summary',
      );
      if (rawResponse == null) return null;

      final json = _extractJson(rawResponse);
      if (json == null) return null;

      final suggestions = (json['suggestions'] as List<dynamic>? ?? [])
          .map((s) => AdaptiveSuggestion.fromJson(
              Map<String, dynamic>.from(s as Map)))
          .toList();

      return AdaptiveAnalysisResult(
        suggestions: suggestions,
        weekSummary: json['week_summary'] as String? ?? '',
        analysedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('[AdaptiveAnalysis] error: $e');
      return null;
    }
  }

  String _buildWorkoutSummary(List<WorkoutDoc> docs) {
    final buf = StringBuffer();
    for (final doc in docs) {
      buf.writeln('--- ${doc.title} (${_fmt(doc.date)}) ---');
      for (final ex in doc.exercises) {
        final completedSets = ex.sets.where((s) => s.completed).toList();
        if (completedSets.isEmpty) continue;
        final best = completedSets.fold<WorkoutSetDoc?>(
          null,
          (prev, s) => prev == null || s.weightKg > prev.weightKg ? s : prev,
        );
        if (best != null) {
          buf.writeln(
              '  ${ex.name}: ${completedSets.length} sets, best set ${best.weightKg}kg × ${best.reps} reps');
        }
      }
      buf.writeln('  Total volume: ${doc.totalVolumeKg}kg');
    }
    return buf.toString();
  }

  String _fmt(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Map<String, dynamic>? _extractJson(String raw) {
    // Try direct parse first
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {}
    // Try to extract JSON from text
    final match = RegExp(r'\{[\s\S]*\}').firstMatch(raw);
    if (match != null) {
      try {
        return Map<String, dynamic>.from(
            jsonDecode(match.group(0)!) as Map);
      } catch (_) {}
    }
    return null;
  }

  /// One-shot HuggingFace call (bypasses chat history stored in AIService).
  Future<String?> _callHuggingFace(
    AIService ai, {
    required String system,
    required String user,
  }) async {
    // We reuse the HF infrastructure in AIService but send a fresh
    // one-shot message (no session history needed for analysis).
    // Since AIService doesn't expose a raw one-shot method, we call
    // sendMessage with a self-contained user message that embeds system instructions.
    // To keep it clean, we provide a combined prompt.
    final combined =
        '[SYSTEM]\n$system\n\n[USER]\n$user\n\nReturn ONLY valid JSON.';
    return ai.sendMessage(combined);
  }
}

final adaptiveAnalysisProvider =
    AsyncNotifierProvider<AdaptiveAnalysisNotifier, AdaptiveAnalysisResult?>(
  AdaptiveAnalysisNotifier.new,
);
