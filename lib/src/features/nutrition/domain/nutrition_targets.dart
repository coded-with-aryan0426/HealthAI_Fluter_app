import '../../../database/models/user_doc.dart';

/// Computed daily nutrition targets based on user's BMR/TDEE and goal.
class NutritionTargets {
  final int calories;
  final int proteinG;
  final int carbsG;
  final int fatG;
  final int fiberG;
  final int sodiumMg;
  final double bmr;
  final double tdee;

  const NutritionTargets({
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.fiberG = 25,
    this.sodiumMg = 2300,
    required this.bmr,
    required this.tdee,
  });

  // ── BMR (Mifflin-St Jeor) ────────────────────────────────────────────────────
  static double _bmr(UserDoc u) {
    final w = u.weightKg ?? 70.0;
    final h = u.heightCm ?? 170.0;
    final a = u.ageYears;
    final base = (10 * w) + (6.25 * h) - (5 * a);
    final isMale = (u.gender ?? 'male').toLowerCase() == 'male';
    return isMale ? base + 5 : base - 161;
  }

  // ── TDEE (activity multiplier) ───────────────────────────────────────────────
  static double _tdee(double bmr, String activityLevel) {
    const m = {
      'sedentary': 1.2,
      'light': 1.375,
      'moderate': 1.55,
      'active': 1.725,
      'very_active': 1.9,
    };
    return bmr * (m[activityLevel] ?? 1.55);
  }

  // ── Calorie target by goal ────────────────────────────────────────────────────
  static int _calorieTarget(double tdee, String goal) {
    switch (goal) {
      case 'fat_loss':
        return (tdee * 0.80).round();
      case 'muscle_gain':
        return (tdee * 1.10).round();
      case 'recomposition':
        return tdee.round();
      default:
        return tdee.round();
    }
  }

  // ── Macro split by goal ───────────────────────────────────────────────────────
  factory NutritionTargets.fromUser(UserDoc user) {
    final bmr = _bmr(user);
    final tdee = _tdee(bmr, user.activityLevel);
    final calories = _calorieTarget(tdee, user.primaryGoal);
    final weight = user.weightKg ?? 70.0;

    late int proteinG, carbsG, fatG;
    switch (user.primaryGoal) {
      case 'fat_loss':
        proteinG = (weight * 2.2).round();
        fatG = ((calories * 0.28) / 9).round();
        carbsG = ((calories - (proteinG * 4) - (fatG * 9)) / 4).round().clamp(50, 9999);
      case 'muscle_gain':
        proteinG = (weight * 2.0).round();
        carbsG = ((calories * 0.45) / 4).round();
        fatG = ((calories - (proteinG * 4) - (carbsG * 4)) / 9).round().clamp(20, 9999);
      default:
        proteinG = ((calories * 0.30) / 4).round();
        carbsG = ((calories * 0.40) / 4).round();
        fatG = ((calories * 0.30) / 9).round();
    }

    return NutritionTargets(
      calories: calories,
      proteinG: proteinG,
      carbsG: carbsG,
      fatG: fatG,
      bmr: bmr,
      tdee: tdee,
    );
  }
}
