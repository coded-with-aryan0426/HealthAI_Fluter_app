import 'dart:convert';
import '../domain/meal_plan_model.dart';

class MealPlanParseResult {
  final String cleanText;
  final MealPlanModel? plan;
  bool get hasPlan => plan != null;
  const MealPlanParseResult({required this.cleanText, this.plan});
}

class MealPlanParser {
  static final _fenceRegex = RegExp(
    r'```meal_plan\s*([\s\S]*?)```',
    multiLine: true,
  );

  static MealPlanParseResult parse(String response) {
    final match = _fenceRegex.firstMatch(response);
    if (match == null) return MealPlanParseResult(cleanText: response);

    final jsonString = match.group(1)?.trim() ?? '';
    final cleanText = response
        .replaceFirst(_fenceRegex, '')
        .trim();

    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final plan = MealPlanModel.fromJson(data);
      return MealPlanParseResult(cleanText: cleanText, plan: plan);
    } catch (_) {
      return MealPlanParseResult(cleanText: response);
    }
  }
}
