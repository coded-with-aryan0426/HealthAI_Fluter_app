class MealPlanModel {
  final String title;
  final int dailyCalories;
  final List<MealPlanDay> days;

  const MealPlanModel({
    required this.title,
    required this.dailyCalories,
    required this.days,
  });

  factory MealPlanModel.fromJson(Map<String, dynamic> json) {
    return MealPlanModel(
      title: json['title'] as String? ?? 'Meal Plan',
      dailyCalories: (json['daily_calories'] as num?)?.toInt() ?? 0,
      days: (json['days'] as List<dynamic>? ?? [])
          .map((d) => MealPlanDay.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'daily_calories': dailyCalories,
        'days': days.map((d) => d.toJson()).toList(),
      };
}

class MealPlanDay {
  final String day;
  final List<MealPlanItem> meals;

  const MealPlanDay({required this.day, required this.meals});

  factory MealPlanDay.fromJson(Map<String, dynamic> json) => MealPlanDay(
        day: json['day'] as String? ?? '',
        meals: (json['meals'] as List<dynamic>? ?? [])
            .map((m) => MealPlanItem.fromJson(m as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'day': day,
        'meals': meals.map((m) => m.toJson()).toList(),
      };
}

class MealPlanItem {
  final String type; // breakfast / lunch / dinner / snack
  final String name;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  const MealPlanItem({
    required this.type,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory MealPlanItem.fromJson(Map<String, dynamic> json) => MealPlanItem(
        type: json['type'] as String? ?? 'meal',
        name: json['name'] as String? ?? '',
        calories: (json['calories'] as num?)?.toInt() ?? 0,
        protein: (json['protein'] as num?)?.toInt() ?? 0,
        carbs: (json['carbs'] as num?)?.toInt() ?? 0,
        fat: (json['fat'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'type': type,
        'name': name,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
      };
}
