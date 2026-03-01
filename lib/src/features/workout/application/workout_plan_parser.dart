import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../domain/workout_plan_model.dart';

class ParseResult {
  final String cleanText;
  final WorkoutPlanData? plan;

  const ParseResult({required this.cleanText, this.plan});

  bool get hasPlan => plan != null;
}

/// Extracts a workout plan JSON from raw LLM responses.
///
/// Strategy (in order):
/// 1. ```workout_plan … ```  (our preferred fence label)
/// 2. ```json … ```  or  ``` … ```  containing a JSON object with "days"
/// 3. Brace-balanced scan: find every top-level { … } in the text,
///    try to parse each one, return the first that has a valid "days" array.
///
/// After extraction the matching text is stripped from the response so the
/// chat bubble only shows clean human-readable Markdown.
class WorkoutPlanParser {
  // Named fence  ```workout_plan  …  ```
  static final _namedFence =
      RegExp(r'```workout_plan\s*([\s\S]*?)```', caseSensitive: false);

  // Any code fence ```(json)? … ```
  static final _anyFence =
      RegExp(r'```(?:json)?\s*([\s\S]*?)```', caseSensitive: false);

  static ParseResult parse(String raw) {
    // ── Strategy 1: named fence ────────────────────────────────────────────
    final m1 = _namedFence.firstMatch(raw);
    if (m1 != null) {
      final json = m1.group(1)?.trim() ?? '';
      final plan = _tryDecode(json);
      if (plan != null) {
        final clean = raw.replaceFirst(m1.group(0)!, '').trim();
        return ParseResult(cleanText: clean, plan: plan);
      }
    }

    // ── Strategy 2: any code fence that contains valid plan JSON ───────────
    for (final m in _anyFence.allMatches(raw)) {
      final inner = m.group(1)?.trim() ?? '';
      // Only attempt if it looks like JSON (starts with { and has "days")
      if (inner.startsWith('{') && inner.contains('"days"')) {
        final plan = _tryDecode(inner);
        if (plan != null) {
          final clean = raw.replaceFirst(m.group(0)!, '').trim();
          return ParseResult(cleanText: clean, plan: plan);
        }
      }
    }

    // ── Strategy 3: brace-balanced scan over raw text ──────────────────────
    // The LLM sometimes dumps JSON without a fence at all.
    final candidates = _extractJsonCandidates(raw);
    for (final candidate in candidates) {
      if (!candidate.contains('"days"')) continue;
      final plan = _tryDecode(candidate);
      if (plan != null) {
        final clean = raw.replaceFirst(candidate, '').trim();
        return ParseResult(cleanText: clean, plan: plan);
      }
    }

    return ParseResult(cleanText: raw.trim());
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Walks [text] character by character and yields every brace-balanced
  /// top-level { … } substring.
  static List<String> _extractJsonCandidates(String text) {
    final results = <String>[];
    int depth = 0;
    int start = -1;
    bool inString = false;
    bool escape = false;

    for (int i = 0; i < text.length; i++) {
      final ch = text[i];

      if (escape) {
        escape = false;
        continue;
      }
      if (ch == r'\' && inString) {
        escape = true;
        continue;
      }
      if (ch == '"') {
        inString = !inString;
        continue;
      }
      if (inString) continue;

      if (ch == '{') {
        if (depth == 0) start = i;
        depth++;
      } else if (ch == '}') {
        depth--;
        if (depth == 0 && start != -1) {
          results.add(text.substring(start, i + 1));
          start = -1;
        }
      }
    }
    return results;
  }

  static WorkoutPlanData? _tryDecode(String jsonStr) {
    if (jsonStr.isEmpty) return null;
    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is! Map<String, dynamic>) return null;
      final plan = WorkoutPlanData.fromJson(decoded);
      if (plan.totalExercises == 0) return null;
      return plan;
    } catch (e) {
      debugPrint('[WorkoutPlanParser] decode failed: $e');
      return null;
    }
  }
}
