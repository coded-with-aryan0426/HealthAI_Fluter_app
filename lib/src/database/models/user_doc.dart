import 'package:isar/isar.dart';

part 'user_doc.g.dart';

@collection
class UserDoc {
  Id id = Isar.autoIncrement;

  late String uid;
  String email = '';
  String? displayName;
  String? photoUrl;
  DateTime? dob;
  String? gender;
  double? heightCm;
  double? weightKg;

  late DateTime createdAt;
  late DateTime lastActive;

    // Goals
    String primaryGoal = 'general_fitness'; // fat_loss / muscle_gain / maintenance / recomposition / general_fitness
    String fitnessLevel = 'intermediate';
    int calorieGoal = 2000;
    int proteinGoalG = 150;
    int carbGoalG = 250;
    int fatGoalG = 65;
    int waterGoalMl = 2500;

    // Body metrics for BMR/TDEE calculation
    int ageYears = 25;
    String activityLevel = 'moderate'; // sedentary / light / moderate / active / very_active

    // Dietary profile
    List<String> foodAllergies = [];        // nuts / dairy / gluten / shellfish / eggs / soy
    List<String> medicalConditions = [];    // diabetes / hypertension / high_cholesterol

    // Meal planning preferences
    int mealsPerDay = 3;
    String cuisinePreference = '';          // Indian / Mediterranean / Western / Asian / Any

    // Eating profile (JSON serialized, updated by pattern analyzer)
    String? eatingProfileJson;

  // Gamification
  List<String> unlockedAchievements = [];
  int totalPoints = 0;

  // AI summary (cached weekly)
  String? weeklyAiSummary;
  DateTime? weeklyAiSummaryGeneratedAt;

  // AI daily insight (cached per-day)
  String? dailyInsightText;
  DateTime? dailyInsightGeneratedAt;

  // AI habit insight (cached per-day)
  String? habitInsightText;
  DateTime? habitInsightGeneratedAt;

  String? aiContextSummary;

  UserPreferences preferences = UserPreferences();
}

@embedded
class UserPreferences {
  List<String> dietary = [];
  String unitSystem = 'metric';
  String theme = 'system';
  bool notificationsEnabled = true;
  bool habitRemindersEnabled = false;
  bool waterRemindersEnabled = false;
}
