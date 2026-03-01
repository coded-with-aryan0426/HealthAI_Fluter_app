import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../services/local_db_service.dart';
import '../../../database/models/user_doc.dart';

final userProvider = NotifierProvider<UserNotifier, UserDoc>(UserNotifier.new);

class UserNotifier extends Notifier<UserDoc> {
  Isar get _db => ref.read(isarProvider);

  @override
  UserDoc build() {
    final existing = _db.userDocs.where().idGreaterThan(0).findFirstSync();
    if (existing != null) return _sanitize(existing);
    return _createDefault();
  }

  /// Fix any corrupted/out-of-range values that may have been stored.
  UserDoc _sanitize(UserDoc u) {
    bool dirty = false;
    if (u.calorieGoal <= 0 || u.calorieGoal > 10000) {
      u.calorieGoal = 2000;
      dirty = true;
    }
    if (u.proteinGoalG <= 0 || u.proteinGoalG > 1000) {
      u.proteinGoalG = 150;
      dirty = true;
    }
    if (u.waterGoalMl <= 0 || u.waterGoalMl > 10000) {
      u.waterGoalMl = 2500;
      dirty = true;
    }
    if (dirty) {
      _db.writeTxnSync(() => _db.userDocs.putSync(u));
    }
    return u;
  }

  UserDoc _createDefault() {
    final user = UserDoc()
      ..uid = 'local_user'
      ..email = ''
      ..displayName = null // will be set during onboarding
      ..createdAt = DateTime.now()
      ..lastActive = DateTime.now();
    _db.writeTxnSync(() => _db.userDocs.putSync(user));
    return user;
  }

  Future<void> updateProfile({
    String? name,
    String? photoUrl,
    double? weightKg,
    double? heightCm,
    DateTime? dob,
    String? gender,
    String? primaryGoal,
    String? fitnessLevel,
    int? calorieGoal,
    int? proteinGoalG,
    List<String>? dietary,
  }) async {
    final updated = _clone(state)
      ..displayName = name ?? state.displayName
      ..photoUrl = photoUrl ?? state.photoUrl
      ..weightKg = weightKg ?? state.weightKg
      ..heightCm = heightCm ?? state.heightCm
      ..dob = dob ?? state.dob
      ..gender = gender ?? state.gender
      ..primaryGoal = primaryGoal ?? state.primaryGoal
      ..fitnessLevel = fitnessLevel ?? state.fitnessLevel
      ..calorieGoal = (calorieGoal ?? state.calorieGoal).clamp(500, 6000)
        ..proteinGoalG = (proteinGoalG ?? state.proteinGoalG).clamp(10, 500)
      ..lastActive = DateTime.now();
    if (dietary != null) {
      updated.preferences = (UserPreferences()
        ..dietary = dietary
        ..unitSystem = state.preferences.unitSystem
        ..theme = state.preferences.theme
        ..notificationsEnabled = state.preferences.notificationsEnabled
        ..habitRemindersEnabled = state.preferences.habitRemindersEnabled
        ..waterRemindersEnabled = state.preferences.waterRemindersEnabled);
    }
    await _db.writeTxn(() => _db.userDocs.put(updated));
    state = updated;
  }

  Future<void> completeOnboarding({
    required String name,
    double? heightCm,
    double? weightKg,
    DateTime? dob,
    String? gender,
    required String primaryGoal,
    required String fitnessLevel,
    int? calorieGoal,
    List<String> dietary = const [],
  }) async {
    // Calculate default calorie goal if not provided
    final cal = calorieGoal ?? _estimateCalories(
      weightKg: weightKg,
      heightCm: heightCm,
      dob: dob,
      gender: gender,
      goal: primaryGoal,
    );

    final updated = _clone(state)
      ..displayName = name
      ..heightCm = heightCm
      ..weightKg = weightKg
      ..dob = dob
      ..gender = gender
      ..primaryGoal = primaryGoal
      ..fitnessLevel = fitnessLevel
      ..calorieGoal = cal
      ..lastActive = DateTime.now();
    updated.preferences = (UserPreferences()
      ..dietary = dietary
      ..unitSystem = state.preferences.unitSystem
      ..theme = state.preferences.theme
      ..notificationsEnabled = state.preferences.notificationsEnabled
      ..habitRemindersEnabled = state.preferences.habitRemindersEnabled
      ..waterRemindersEnabled = state.preferences.waterRemindersEnabled);

    await _db.writeTxn(() => _db.userDocs.put(updated));
    state = updated;
  }

  /// Mifflin-St Jeor calorie estimate
  int _estimateCalories({
    double? weightKg,
    double? heightCm,
    DateTime? dob,
    String? gender,
    required String goal,
  }) {
    if (weightKg == null || heightCm == null || dob == null) return 2000;
    final age = DateTime.now().difference(dob).inDays ~/ 365;
    double bmr = gender == 'female'
        ? 10 * weightKg + 6.25 * heightCm - 5 * age - 161
        : 10 * weightKg + 6.25 * heightCm - 5 * age + 5;
    // Moderate activity multiplier
    double tdee = bmr * 1.55;
    if (goal == 'weight_loss') tdee -= 400;
    if (goal == 'muscle_gain') tdee += 300;
    return tdee.round().clamp(1200, 4000);
  }

  Future<void> updateUnitSystem(String unit) async {
    final prefs = UserPreferences()
      ..dietary = state.preferences.dietary
      ..unitSystem = unit
      ..theme = state.preferences.theme
      ..notificationsEnabled = state.preferences.notificationsEnabled
      ..habitRemindersEnabled = state.preferences.habitRemindersEnabled
      ..waterRemindersEnabled = state.preferences.waterRemindersEnabled;
    final updated = _clone(state)..preferences = prefs;
    await _db.writeTxn(() => _db.userDocs.put(updated));
    state = updated;
  }

  Future<void> cacheWeeklySummary(String summary) async {
    final updated = _clone(state)
      ..weeklyAiSummary = summary
      ..weeklyAiSummaryGeneratedAt = DateTime.now();
    await _db.writeTxn(() => _db.userDocs.put(updated));
    state = updated;
  }

  Future<void> cacheDailyInsight(String text) async {
    final updated = _clone(state)
      ..dailyInsightText = text
      ..dailyInsightGeneratedAt = DateTime.now();
    await _db.writeTxn(() => _db.userDocs.put(updated));
    state = updated;
  }

  Future<void> cacheHabitInsight(String text) async {
    final updated = _clone(state)
      ..habitInsightText = text
      ..habitInsightGeneratedAt = DateTime.now();
    await _db.writeTxn(() => _db.userDocs.put(updated));
    state = updated;
  }

  /// Sign out: clear the display name so the next launch shows onboarding.
  Future<void> signOut() async {
    final updated = _clone(state)..displayName = null;
    await _db.writeTxn(() => _db.userDocs.put(updated));
    state = updated;
  }

  /// Delete account: wipe every Isar collection then reset state.
  Future<void> deleteAccount() async {
    await _db.writeTxn(() async {
      await _db.clear(); // clears all collections in the schema
    });
    state = _createDefault();
  }

  UserDoc _clone(UserDoc src) {
    return UserDoc()
      ..id = src.id
      ..uid = src.uid
      ..email = src.email
      ..displayName = src.displayName
      ..photoUrl = src.photoUrl
      ..dob = src.dob
      ..gender = src.gender
      ..heightCm = src.heightCm
      ..weightKg = src.weightKg
      ..createdAt = src.createdAt
      ..lastActive = src.lastActive
      ..primaryGoal = src.primaryGoal
      ..fitnessLevel = src.fitnessLevel
      ..calorieGoal = src.calorieGoal
      ..proteinGoalG = src.proteinGoalG
      ..waterGoalMl = src.waterGoalMl
      ..unlockedAchievements = src.unlockedAchievements
      ..totalPoints = src.totalPoints
      ..weeklyAiSummary = src.weeklyAiSummary
      ..weeklyAiSummaryGeneratedAt = src.weeklyAiSummaryGeneratedAt
      ..dailyInsightText = src.dailyInsightText
      ..dailyInsightGeneratedAt = src.dailyInsightGeneratedAt
      ..habitInsightText = src.habitInsightText
      ..habitInsightGeneratedAt = src.habitInsightGeneratedAt
      ..aiContextSummary = src.aiContextSummary
      ..preferences = src.preferences;
  }
}
