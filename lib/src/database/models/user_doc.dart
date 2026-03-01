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
  String primaryGoal = 'general_fitness';
  String fitnessLevel = 'intermediate';
  int calorieGoal = 2000;
  int proteinGoalG = 150;
  int waterGoalMl = 2500;

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
