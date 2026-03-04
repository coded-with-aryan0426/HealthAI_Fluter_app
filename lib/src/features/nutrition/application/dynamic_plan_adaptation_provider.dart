import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../database/models/daily_log_doc.dart';
import '../../../database/models/workout_doc.dart';
import '../../../services/ai_service.dart';
import '../../../services/local_db_service.dart';
import '../../profile/application/user_provider.dart';
import '../application/eating_pattern_analyzer.dart';
import '../application/nutrition_targets_provider.dart';
import '../domain/nutrition_targets.dart';

// ── Trigger model ─────────────────────────────────────────────────────────────

enum AdaptationTrigger {
  workoutDay,        // Heavy workout → increase calories/protein
  restDay,           // No workout → slightly reduce calories
  poorSleep,         // < 6h sleep → flag recovery nutrients
  highStressEating,  // Overeat + poor sleep → mindful eating prompt
  proteinDeficit,    // Consistently below protein goal
  undereating,       // Avg calories < 80% of goal for 3+ days
}

class PlanAdaptation {
  final AdaptationTrigger trigger;
  final String title;
  final String message;
  final int calorieDelta;   // positive = add, negative = reduce
  final int proteinDelta;   // grams
  final List<String> foodSuggestions;
  final DateTime detectedAt;

  const PlanAdaptation({
    required this.trigger,
    required this.title,
    required this.message,
    this.calorieDelta = 0,
    this.proteinDelta = 0,
    this.foodSuggestions = const [],
    required this.detectedAt,
  });
}

// ── State ─────────────────────────────────────────────────────────────────────

class AdaptationState {
  final bool loading;
  final List<PlanAdaptation> activeAdaptations;
  final String? aiRecommendation;
  final DateTime? analyzedAt;

  const AdaptationState({
    this.loading = false,
    this.activeAdaptations = const [],
    this.aiRecommendation,
    this.analyzedAt,
  });

  AdaptationState copyWith({
    bool? loading,
    List<PlanAdaptation>? activeAdaptations,
    String? aiRecommendation,
    DateTime? analyzedAt,
  }) =>
      AdaptationState(
        loading: loading ?? this.loading,
        activeAdaptations: activeAdaptations ?? this.activeAdaptations,
        aiRecommendation: aiRecommendation ?? this.aiRecommendation,
        analyzedAt: analyzedAt ?? this.analyzedAt,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class DynamicPlanAdaptationNotifier extends Notifier<AdaptationState> {
  @override
  AdaptationState build() {
    return const AdaptationState();
  }

  Future<void> analyze() async {
    state = state.copyWith(loading: true);

    try {
      final db = ref.read(isarProvider);
      final user = ref.read(userProvider);
      final targets = ref.read(nutritionTargetsProvider);
      final eatingProfile = ref.read(eatingProfileProvider);

      // ── Gather last 7 days of data ────────────────────────────────────────
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

        final recentLogs = db.dailyLogDocs
            .where()
            .filter()
            .dateGreaterThan(
                today.subtract(const Duration(days: 7, seconds: 1)))
            .findAllSync();

        final recentWorkouts = db.workoutDocs
            .where()
            .filter()
            .dateGreaterThan(
                today.subtract(const Duration(days: 7, seconds: 1)))
            .findAllSync();

      // Today's log
      final todayLog = recentLogs
          .where((l) => l.date.day == now.day && l.date.month == now.month)
          .firstOrNull;

      // ── Rule-based trigger detection ──────────────────────────────────────
      final adaptations = <PlanAdaptation>[];

      // 1. Workout day trigger
      final workedOutToday = recentWorkouts.any(
          (w) => w.date.day == now.day && w.date.month == now.month);
      if (workedOutToday) {
        adaptations.add(PlanAdaptation(
          trigger: AdaptationTrigger.workoutDay,
          title: 'Workout Day Boost',
          message:
              'You trained today — add 150–200 extra kcal focused on protein and carbs for recovery.',
          calorieDelta: 175,
          proteinDelta: 20,
          foodSuggestions: [
            'Chocolate milk (post-workout)',
            'Banana + peanut butter',
            'Greek yogurt with granola',
          ],
          detectedAt: now,
        ));
      }

      // 2. Rest day trigger (no workout in last 2 days)
      final workedOutRecently = recentWorkouts.any((w) {
        final diff = now.difference(w.date).inDays;
        return diff <= 1;
      });
      if (!workedOutRecently && recentWorkouts.isNotEmpty) {
        adaptations.add(PlanAdaptation(
          trigger: AdaptationTrigger.restDay,
          title: 'Rest Day Adjustment',
          message:
              'No workout logged in 2 days. Consider reducing carbs by ~50g and focusing on whole foods.',
          calorieDelta: -150,
          proteinDelta: 0,
          foodSuggestions: [
            'Leafy green salad',
            'Grilled fish',
            'Steamed vegetables',
          ],
          detectedAt: now,
        ));
      }

      // 3. Poor sleep trigger
      if (todayLog != null && todayLog.sleepMinutes > 0 &&
          todayLog.sleepMinutes < 360) {
        adaptations.add(PlanAdaptation(
          trigger: AdaptationTrigger.poorSleep,
          title: 'Recovery Nutrition',
          message:
              'You slept less than 6 hours. Prioritise magnesium-rich foods and avoid high-sugar meals to aid recovery.',
          calorieDelta: 0,
          proteinDelta: 0,
          foodSuggestions: [
            'Pumpkin seeds',
            'Dark chocolate (1 square)',
            'Chamomile tea',
            'Almonds',
          ],
          detectedAt: now,
        ));
      }

      // 4. High stress eating (overeat + poor sleep)
      if (todayLog != null &&
          todayLog.sleepMinutes < 360 &&
          todayLog.caloriesConsumed > targets.calories * 1.2) {
        adaptations.add(PlanAdaptation(
          trigger: AdaptationTrigger.highStressEating,
          title: 'Mindful Eating Alert',
          message:
              'Poor sleep combined with overeating can disrupt hunger hormones. Try eating slowly and avoid screens during meals.',
          calorieDelta: 0,
          proteinDelta: 0,
          foodSuggestions: [
            'Warm herbal tea',
            'Light vegetable soup',
            'Apple slices with almond butter',
          ],
          detectedAt: now,
        ));
      }

      // 5. Consistent protein deficit (eating profile)
      if (eatingProfile != null && !eatingProfile.proteinConsistent) {
        adaptations.add(PlanAdaptation(
          trigger: AdaptationTrigger.proteinDeficit,
          title: 'Protein Gap Detected',
          message:
              'You\'ve been missing your protein target most days. Try adding a protein-rich snack between meals.',
          calorieDelta: 0,
          proteinDelta: 15,
          foodSuggestions: [
            'Cottage cheese (½ cup)',
            'Hard-boiled eggs (2)',
            'Protein shake',
            'Edamame',
          ],
          detectedAt: now,
        ));
      }

      // 6. Undereating
      if (eatingProfile != null && eatingProfile.tendencyToUndereat) {
        adaptations.add(PlanAdaptation(
          trigger: AdaptationTrigger.undereating,
          title: 'Calorie Deficit Warning',
          message:
              'You\'ve been consistently eating below 80% of your calorie target. This can slow your metabolism and reduce energy.',
          calorieDelta: 200,
          proteinDelta: 10,
          foodSuggestions: [
            'Nuts and seeds',
            'Avocado on toast',
            'Whole grain cereal with milk',
          ],
          detectedAt: now,
        ));
      }

      // ── AI narrative recommendation ───────────────────────────────────────
      String? aiRec;
      if (adaptations.isNotEmpty) {
        try {
          final triggers =
              adaptations.map((a) => a.trigger.name).join(', ');
          final profile = eatingProfile?.aiSummary ?? 'no pattern data';
          final prompt =
              'Based on these detected nutrition triggers: [$triggers] '
              'and user eating pattern: $profile, '
              'give ONE short (2 sentences max) personalised nutrition adjustment tip. '
              'Be direct and actionable. No bullet points.';
          final ai = ref.read(aiServiceProvider);
          aiRec = await ai.sendMessage(prompt);
          if (aiRec != null &&
              (aiRec.isEmpty || aiRec.startsWith('__'))) {
            aiRec = null;
          }
        } catch (_) {}
      }

      state = state.copyWith(
        loading: false,
        activeAdaptations: adaptations,
        aiRecommendation: aiRec,
        analyzedAt: now,
      );
    } catch (e) {
      debugPrint('[DynamicPlanAdaptation] error: $e');
      state = state.copyWith(loading: false);
    }
  }
}

final dynamicPlanAdaptationProvider =
    NotifierProvider<DynamicPlanAdaptationNotifier, AdaptationState>(
        DynamicPlanAdaptationNotifier.new);
