import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../database/models/nutrition_log_doc.dart';
import '../../../database/models/user_doc.dart';
import '../../../services/local_db_service.dart';
import '../../profile/application/user_provider.dart';

// ── Eating profile model ───────────────────────────────────────────────────────

class EatingProfile {
  /// Average calories over last 14 days (logged days only)
  final double avgCalories;

  /// How many days per week the user consistently logs meals
  final double logConsistency; // 0.0–7.0

  /// Whether user tends to hit their protein target
  final bool proteinConsistent;

  /// Whether user tends to overeat (avg > 110% of goal)
  final bool tendencyToOvereat;

  /// Whether user tends to undereat (avg < 80% of goal)
  final bool tendencyToUndereat;

  /// Most frequently skipped meal type
  final String? mostSkippedMeal;

  /// Dominant meal types logged (sorted by frequency)
  final List<String> dominantMealTypes;

  /// How many days out of last 14 had data
  final int daysWithData;

  /// Last time the profile was computed
  final DateTime computedAt;

  const EatingProfile({
    required this.avgCalories,
    required this.logConsistency,
    required this.proteinConsistent,
    required this.tendencyToOvereat,
    required this.tendencyToUndereat,
    required this.mostSkippedMeal,
    required this.dominantMealTypes,
    required this.daysWithData,
    required this.computedAt,
  });

  factory EatingProfile.fromJson(Map<String, dynamic> json) => EatingProfile(
        avgCalories: (json['avgCalories'] as num?)?.toDouble() ?? 0,
        logConsistency: (json['logConsistency'] as num?)?.toDouble() ?? 0,
        proteinConsistent: json['proteinConsistent'] as bool? ?? false,
        tendencyToOvereat: json['tendencyToOvereat'] as bool? ?? false,
        tendencyToUndereat: json['tendencyToUndereat'] as bool? ?? false,
        mostSkippedMeal: json['mostSkippedMeal'] as String?,
        dominantMealTypes: (json['dominantMealTypes'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
        daysWithData: (json['daysWithData'] as num?)?.toInt() ?? 0,
        computedAt: json['computedAt'] != null
            ? DateTime.parse(json['computedAt'] as String)
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'avgCalories': avgCalories,
        'logConsistency': logConsistency,
        'proteinConsistent': proteinConsistent,
        'tendencyToOvereat': tendencyToOvereat,
        'tendencyToUndereat': tendencyToUndereat,
        'mostSkippedMeal': mostSkippedMeal,
        'dominantMealTypes': dominantMealTypes,
        'daysWithData': daysWithData,
        'computedAt': computedAt.toIso8601String(),
      };

  /// Human-readable summary string for AI prompts
  String get aiSummary {
    final parts = <String>[];
    if (avgCalories > 0) {
      parts.add('avg ${avgCalories.round()} kcal/day');
    }
    if (tendencyToOvereat) parts.add('tends to overeat');
    if (tendencyToUndereat) parts.add('tends to undereat');
    if (!proteinConsistent) parts.add('inconsistent protein');
    if (mostSkippedMeal != null) parts.add('often skips $mostSkippedMeal');
    if (logConsistency < 4) parts.add('logs inconsistently');
    return parts.isEmpty ? 'No pattern data yet' : parts.join(', ');
  }
}

// ── Provider ───────────────────────────────────────────────────────────────────

/// Returns the current eating profile, computed from the last 14 days of logs.
/// Re-reads from UserDoc.eatingProfileJson (persisted) and also offers
/// [EatingPatternAnalyzer.analyze] to recompute + persist on demand.
final eatingProfileProvider = Provider<EatingProfile?>((ref) {
  final user = ref.watch(userProvider);
  final json = user.eatingProfileJson;
  if (json == null || json.isEmpty) return null;
  try {
    return EatingProfile.fromJson(
        jsonDecode(json) as Map<String, dynamic>);
  } catch (_) {
    return null;
  }
});

// ── Analyzer service ───────────────────────────────────────────────────────────

class EatingPatternAnalyzer {
  final Isar _db;
  EatingPatternAnalyzer(this._db);

  static const _kMealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

  /// Compute an [EatingProfile] from the last [days] days of [NutritionLogDoc]
  /// and persist it into [UserDoc.eatingProfileJson].
  Future<EatingProfile?> analyze({int days = 14, int calorieGoal = 2000}) async {
    try {
      final now = DateTime.now();
      final cutoff = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: days - 1));

        final logs = _db.nutritionLogDocs
            .where()
            .dateGreaterThan(cutoff.subtract(const Duration(seconds: 1)))
            .findAllSync();

      if (logs.isEmpty) return null;

      // ── Calorie stats ────────────────────────────────────────────────────────
      final calorieEntries = logs.where((l) => l.totalCalories > 0).toList();
      final avgCalories = calorieEntries.isEmpty
          ? 0.0
          : calorieEntries.fold(0, (s, l) => s + l.totalCalories) /
              calorieEntries.length;

      // ── Consistency ─────────────────────────────────────────────────────────
      final daysWithData = calorieEntries.length;
      final logConsistency = daysWithData / days * 7; // normalised to 7-day week

      // ── Protein consistency ──────────────────────────────────────────────────
      final proteinHitCount = logs.where((l) => l.hitProteinGoal).length;
      final proteinConsistent =
          daysWithData > 0 && (proteinHitCount / daysWithData) >= 0.6;

      // ── Over/undereat ────────────────────────────────────────────────────────
      final overeatDays = calorieEntries
          .where((l) => l.totalCalories > calorieGoal * 1.1)
          .length;
      final undereatDays = calorieEntries
          .where((l) => l.totalCalories < calorieGoal * 0.8)
          .length;
      final tendencyToOvereat =
          daysWithData > 0 && (overeatDays / daysWithData) >= 0.4;
      final tendencyToUndereat =
          daysWithData > 0 && (undereatDays / daysWithData) >= 0.4;

      // ── Meal type frequency ──────────────────────────────────────────────────
      final mealTypeCounts = <String, int>{for (final t in _kMealTypes) t: 0};
      for (final log in logs) {
        for (final type in log.mealTypesLogged.split(',')) {
          final t = type.trim();
          if (mealTypeCounts.containsKey(t)) {
            mealTypeCounts[t] = mealTypeCounts[t]! + 1;
          }
        }
      }
      final sortedTypes = mealTypeCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final dominantMealTypes =
          sortedTypes.where((e) => e.value > 0).map((e) => e.key).toList();

      // Most skipped = lowest frequency meal type (among the main 3)
      final mainTypes = ['Breakfast', 'Lunch', 'Dinner'];
      String? mostSkippedMeal;
      if (daysWithData > 3) {
        final leastLogged = mainTypes.reduce((a, b) =>
            (mealTypeCounts[a] ?? 0) < (mealTypeCounts[b] ?? 0) ? a : b);
        if ((mealTypeCounts[leastLogged] ?? 0) < daysWithData * 0.5) {
          mostSkippedMeal = leastLogged;
        }
      }

      final profile = EatingProfile(
        avgCalories: avgCalories,
        logConsistency: logConsistency,
        proteinConsistent: proteinConsistent,
        tendencyToOvereat: tendencyToOvereat,
        tendencyToUndereat: tendencyToUndereat,
        mostSkippedMeal: mostSkippedMeal,
        dominantMealTypes: dominantMealTypes,
        daysWithData: daysWithData,
        computedAt: DateTime.now(),
      );

      // ── Persist to UserDoc ───────────────────────────────────────────────────
      final userDocs = _db.userDocs.where().findAllSync();
      if (userDocs.isNotEmpty) {
        final user = userDocs.first;
        user.eatingProfileJson = jsonEncode(profile.toJson());
        await _db.writeTxn(() => _db.userDocs.put(user));
      }

      debugPrint('[EatingPatternAnalyzer] profile updated: ${profile.aiSummary}');
      return profile;
    } catch (e) {
      debugPrint('[EatingPatternAnalyzer] error: $e');
      return null;
    }
  }
}

final eatingPatternAnalyzerProvider = Provider<EatingPatternAnalyzer>((ref) {
  final db = ref.read(isarProvider);
  return EatingPatternAnalyzer(db);
});
