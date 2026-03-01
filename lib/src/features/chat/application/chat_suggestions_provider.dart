import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:isar/isar.dart';
import '../../dashboard/application/daily_activity_provider.dart';
import '../../habits/application/habit_provider.dart';
import '../../profile/application/user_provider.dart';
import '../../../services/local_db_service.dart';
import '../../../database/models/workout_doc.dart';

/// A single suggestion chip shown on the welcome screen.
class ChatSuggestion {
  final String text;
  final IconData icon;
  final bool isHighlighted;

  const ChatSuggestion({
    required this.text,
    required this.icon,
    this.isHighlighted = false,
  });
}

/// Builds a dynamic, context-aware list of chat suggestions based on the
/// user's current health data, time of day, activity, streaks, and remaining
/// goals. Falls back to generic suggestions when there is no meaningful signal.
final chatSuggestionsProvider = Provider<List<ChatSuggestion>>((ref) {
  final log = ref.watch(dailyActivityProvider);
  final habits = ref.watch(habitsProvider);
  final user = ref.watch(userProvider);
  final isar = ref.read(isarProvider);

  final suggestions = <ChatSuggestion>[];
  final now = DateTime.now();
  final hour = now.hour;

  // ── Time-of-day context ───────────────────────────────────────────────────
  final isMorning = hour >= 5 && hour < 12;
  final isAfternoon = hour >= 12 && hour < 17;
  final isEvening = hour >= 17 && hour < 21;
  final isNight = hour >= 21 || hour < 5;

  // ── Yesterday's workout ────────────────────────────────────────────────────
  final yesterday = DateTime(now.year, now.month, now.day - 1);
  final hadWorkoutYesterday = isar.workoutDocs
      .where()
      .filter()
      .dateBetween(
        yesterday,
        yesterday.add(const Duration(hours: 23, minutes: 59)),
      )
      .findAllSync()
      .isNotEmpty;

  if (hadWorkoutYesterday && isMorning) {
    suggestions.add(const ChatSuggestion(
      text: 'How sore should I expect to be today after yesterday\'s workout?',
      icon: PhosphorIconsFill.heartbeat,
      isHighlighted: true,
    ));
    suggestions.add(const ChatSuggestion(
      text: 'Best recovery foods after yesterday\'s workout',
      icon: PhosphorIconsFill.forkKnife,
    ));
  }

  // ── No workout in 3 days ──────────────────────────────────────────────────
  final threeDaysAgo = now.subtract(const Duration(days: 3));
  final recentWorkouts = isar.workoutDocs
      .where()
      .filter()
      .dateGreaterThan(threeDaysAgo)
      .findAllSync();

  if (recentWorkouts.isEmpty) {
    suggestions.add(const ChatSuggestion(
      text: 'Time to get back on track — build me a workout plan',
      icon: PhosphorIconsFill.barbell,
      isHighlighted: true,
    ));
  }

  // ── Calorie goal ──────────────────────────────────────────────────────────
  final calGoal = user.calorieGoal > 0 ? user.calorieGoal : 2000;
  final calConsumed = log.caloriesConsumed;
  final calPercent = calGoal > 0 ? calConsumed / calGoal : 1.0;
  final calRemaining = calGoal - calConsumed;

  // Under-eating at lunch / afternoon
  if (calPercent < 0.7 && calConsumed > 0 && (isAfternoon || isEvening)) {
    suggestions.add(ChatSuggestion(
      text: 'Help me hit my calorie goal — I\'ve only had ${calConsumed} / $calGoal kcal',
      icon: PhosphorIconsFill.fire,
      isHighlighted: true,
    ));
  }

  // Evening calorie gap — specific meal idea
  if (isEvening && calRemaining > 300 && calConsumed > 0) {
    suggestions.add(ChatSuggestion(
      text: 'Evening meal idea to close my $calRemaining kcal gap',
      icon: PhosphorIconsFill.forkKnife,
      isHighlighted: true,
    ));
  }

  // Morning — plan the day
  if (isMorning && calConsumed == 0) {
    suggestions.add(ChatSuggestion(
      text: 'Plan my meals for today to hit ${calGoal} kcal',
      icon: PhosphorIconsFill.forkKnife,
      isHighlighted: true,
    ));
  }

  // ── Low protein ────────────────────────────────────────────────────────────
  final proteinGoal = user.proteinGoalG > 0 ? user.proteinGoalG : 120;
  final proteinConsumed = log.proteinGrams;
  final proteinRemaining = proteinGoal - proteinConsumed;
  if (proteinGoal > 0 && proteinConsumed < proteinGoal * 0.5 && proteinConsumed > 0 && isAfternoon) {
    suggestions.add(ChatSuggestion(
      text: 'Quick high-protein meal ideas — I still need ${proteinRemaining}g protein',
      icon: PhosphorIconsFill.forkKnife,
    ));
  }

  // ── Habit streak at risk ──────────────────────────────────────────────────
  final notifier = ref.read(habitsProvider.notifier);
  final streak = notifier.calculateStreak();
  final completedToday = notifier.todayCompleted.length;
  final totalHabits = habits.length;

  if (totalHabits > 0 && completedToday == 0 && !isMorning) {
    suggestions.add(ChatSuggestion(
      text: 'Help me stay consistent — I haven\'t done any habits yet today',
      icon: PhosphorIconsFill.target,
      isHighlighted: streak >= 3,
    ));
  } else if (streak >= 5) {
    suggestions.add(ChatSuggestion(
      text: 'I\'m on a $streak-day streak — how do I keep building on it?',
      icon: PhosphorIconsFill.flame,
      isHighlighted: true,
    ));
  } else if (streak >= 3) {
    suggestions.add(ChatSuggestion(
      text: 'Tips to protect my $streak-day habit streak',
      icon: PhosphorIconsFill.flame,
    ));
  }

  // ── Low water ─────────────────────────────────────────────────────────────
  final waterPct = log.waterGoalMl > 0 ? log.waterMl / log.waterGoalMl : 1.0;
  if (waterPct < 0.4 && hour >= 12) {
    suggestions.add(const ChatSuggestion(
      text: 'Tips to drink more water throughout the day',
      icon: PhosphorIconsFill.drop,
    ));
  }

  // ── Sleep ─────────────────────────────────────────────────────────────────
  if (log.sleepMinutes > 0 && log.sleepMinutes < 360) {
    if (isMorning || isAfternoon) {
      suggestions.add(const ChatSuggestion(
        text: 'I slept poorly — how can I train effectively today?',
        icon: PhosphorIconsFill.moon,
      ));
    }
  }

  // ── Night wind-down ───────────────────────────────────────────────────────
  if (isNight) {
    suggestions.add(const ChatSuggestion(
      text: 'Wind-down routine for better sleep tonight',
      icon: PhosphorIconsFill.moon,
      isHighlighted: false,
    ));
  }

  // ── Afternoon workout prompt ──────────────────────────────────────────────
  if (isAfternoon && recentWorkouts.isEmpty) {
    suggestions.add(const ChatSuggestion(
      text: 'Give me a quick 30-min afternoon workout',
      icon: PhosphorIconsFill.barbell,
      isHighlighted: true,
    ));
  }

  // ── Morning motivation ────────────────────────────────────────────────────
  if (isMorning && suggestions.length < 3) {
    suggestions.add(ChatSuggestion(
      text: 'Give me a motivational health tip to start the day',
      icon: PhosphorIconsFill.sparkle,
      isHighlighted: true,
    ));
  }

  // ── Generic fallbacks (always shown if list is short) ─────────────────────
  const fallbacks = [
    ChatSuggestion(
      text: 'Create a personalised workout plan for me',
      icon: PhosphorIconsFill.barbell,
    ),
    ChatSuggestion(
      text: 'What should I eat today?',
      icon: PhosphorIconsFill.forkKnife,
    ),
    ChatSuggestion(
      text: 'Motivate me to train',
      icon: PhosphorIconsFill.lightning,
    ),
    ChatSuggestion(
      text: 'Best recovery exercises for sore muscles',
      icon: PhosphorIconsFill.heartbeat,
    ),
    ChatSuggestion(
      text: 'Help me sleep better tonight',
      icon: PhosphorIconsFill.moon,
    ),
    ChatSuggestion(
      text: 'How many calories did I burn today?',
      icon: PhosphorIconsFill.fire,
    ),
    ChatSuggestion(
      text: 'Review my progress this week',
      icon: PhosphorIconsFill.chartBar,
    ),
    ChatSuggestion(
      text: 'Suggest a high-protein breakfast',
      icon: PhosphorIconsFill.forkKnife,
    ),
  ];

  for (final f in fallbacks) {
    if (suggestions.length >= 6) break;
    if (!suggestions.any((s) => s.text == f.text)) {
      suggestions.add(f);
    }
  }

  // Highlighted (contextual) suggestions first
  suggestions.sort((a, b) {
    if (a.isHighlighted && !b.isHighlighted) return -1;
    if (!a.isHighlighted && b.isHighlighted) return 1;
    return 0;
  });

  return suggestions.take(6).toList();
});
