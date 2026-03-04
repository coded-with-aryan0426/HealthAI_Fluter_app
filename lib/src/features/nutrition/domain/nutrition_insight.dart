/// A single nutrition alert (deficiency, excess, or warning).
class NutritionAlert {
  final String type;     // deficiency | excess | warning
  final String nutrient;
  final String message;
  final String severity; // low | medium | high

  const NutritionAlert({
    required this.type,
    required this.nutrient,
    required this.message,
    required this.severity,
  });

  factory NutritionAlert.fromJson(Map<String, dynamic> j) => NutritionAlert(
        type: j['type']?.toString() ?? 'warning',
        nutrient: j['nutrient']?.toString() ?? '',
        message: j['message']?.toString() ?? '',
        severity: j['severity']?.toString() ?? 'low',
      );
}

/// AI-generated daily nutrition analysis result.
class NutritionInsight {
  final int score;          // 0–100
  final String grade;       // A / B / C / D / F
  final String summary;
  final List<String> positives;
  final List<NutritionAlert> alerts;
  final List<String> suggestions;
  final String tomorrowTip;
  final DateTime generatedAt;

  const NutritionInsight({
    required this.score,
    required this.grade,
    required this.summary,
    required this.positives,
    required this.alerts,
    required this.suggestions,
    required this.tomorrowTip,
    required this.generatedAt,
  });

  factory NutritionInsight.fromJson(Map<String, dynamic> j) {
    return NutritionInsight(
      score: (j['score'] as num?)?.toInt() ?? 50,
      grade: j['grade']?.toString() ?? 'C',
      summary: j['summary']?.toString() ?? '',
      positives: _parseStringList(j['positives']),
      alerts: _parseAlerts(j['alerts']),
      suggestions: _parseStringList(j['suggestions']),
      tomorrowTip: j['tomorrow_tip']?.toString() ?? '',
      generatedAt: DateTime.now(),
    );
  }

  static List<String> _parseStringList(dynamic v) {
    if (v is List) return v.map((e) => e.toString()).toList();
    return [];
  }

  static List<NutritionAlert> _parseAlerts(dynamic v) {
    if (v is! List) return [];
    return v
        .whereType<Map<String, dynamic>>()
        .map(NutritionAlert.fromJson)
        .toList();
  }
}

/// AI-generated weekly nutrition report.
class WeeklyNutritionReport {
  final double avgCalories;
  final double avgProtein;
  final int consistencyScore;
  final String weekGrade;
  final String headline;
  final List<String> achievements;
  final List<String> improvements;
  final String keyInsight;
  final String nextWeekFocus;
  final DateTime generatedAt;

  const WeeklyNutritionReport({
    required this.avgCalories,
    required this.avgProtein,
    required this.consistencyScore,
    required this.weekGrade,
    required this.headline,
    required this.achievements,
    required this.improvements,
    required this.keyInsight,
    required this.nextWeekFocus,
    required this.generatedAt,
  });

  factory WeeklyNutritionReport.fromJson(Map<String, dynamic> j) {
    return WeeklyNutritionReport(
      avgCalories: (j['avg_calories'] as num?)?.toDouble() ?? 0,
      avgProtein: (j['avg_protein'] as num?)?.toDouble() ?? 0,
      consistencyScore: (j['consistency_score'] as num?)?.toInt() ?? 0,
      weekGrade: j['week_grade']?.toString() ?? 'C',
      headline: j['headline']?.toString() ?? '',
      achievements: _list(j['achievements']),
      improvements: _list(j['improvements']),
      keyInsight: j['key_insight']?.toString() ?? '',
      nextWeekFocus: j['next_week_focus']?.toString() ?? '',
      generatedAt: DateTime.now(),
    );
  }

  static List<String> _list(dynamic v) {
    if (v is List) return v.map((e) => e.toString()).toList();
    return [];
  }
}
