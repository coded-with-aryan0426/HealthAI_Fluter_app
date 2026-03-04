import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../features/dashboard/application/daily_activity_provider.dart';
import '../features/habits/application/habit_provider.dart';
import '../features/profile/application/user_provider.dart';
import '../database/models/workout_doc.dart';
import 'local_db_service.dart';

// ─── Provider ─────────────────────────────────────────────────────────────────

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService.instance;
});

/// Watches daily activity, habits, and workouts and keeps the 8 PM evening
/// nudge notification up-to-date with today's real data.
///
/// Consume this provider once near the root of the widget tree to activate it:
///   ref.watch(eveningNudgeSchedulerProvider);
final eveningNudgeSchedulerProvider = Provider<void>((ref) {
  final log = ref.watch(dailyActivityProvider);
  final habits = ref.watch(habitsProvider);
  final user = ref.watch(userProvider);
  final isar = ref.read(isarProvider);

  final today = DateTime.now();
  final todayMidnight = DateTime(today.year, today.month, today.day);
  final hadWorkout = isar.workoutDocs
      .where()
      .filter()
      .dateBetween(todayMidnight, todayMidnight.add(const Duration(days: 1)))
      .limit(1)
      .findAllSync()
      .isNotEmpty;

  final notifier = ref.read(habitsProvider.notifier);
  final completedToday = notifier.todayCompleted.length;
  final calGoal = user.calorieGoal > 0 ? user.calorieGoal : 2000;

  NotificationService.instance.scheduleEveningNudge(
    completedHabits: completedToday,
    totalHabits: habits.length,
    caloriesConsumed: log.caloriesConsumed,
    calorieGoal: calGoal,
    hadWorkoutToday: hadWorkout,
  );
});

// ─── Notification IDs ─────────────────────────────────────────────────────────

class _NotifId {
  static const int morningMotivation = 1001;
  static const int habitReminder = 1002;
  static const int waterReminder = 1003;
  static const int weeklyReport = 1004;
  static const int workoutReminder = 1005;
  static const int eveningNudge = 1006;
}

// ─── Prefs keys ───────────────────────────────────────────────────────────────

class _PrefKey {
  static const String notificationsEnabled = 'notif_enabled';
  static const String morningMotivationEnabled = 'notif_morning_enabled';
  static const String habitReminderEnabled = 'notif_habit_enabled';
  static const String waterReminderEnabled = 'notif_water_enabled';
  static const String weeklyReportEnabled = 'notif_weekly_enabled';
}

// ─── Service ──────────────────────────────────────────────────────────────────

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

      await _plugin.initialize(
        const InitializationSettings(android: androidInit, iOS: iosInit),
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

    _initialized = true;
  }

  void _onNotificationTap(NotificationResponse response) {
    // Navigate on tap — handled via shared_preferences flag.
  }

  // ── Permission request ────────────────────────────────────────────────────

  bool _permissionRequested = false;

  Future<bool> requestPermission() async {
    if (_permissionRequested) return true;
    _permissionRequested = true;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final granted = await ios?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
      return granted;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted =
          await android?.requestNotificationsPermission() ?? false;
      return granted;
    }
    return true;
  }

  // ── Notification detail presets ───────────────────────────────────────────

  static const _dailyChannel = AndroidNotificationDetails(
    'healthai_daily',
    'Daily Motivation',
    channelDescription: 'Daily health motivation and reminders',
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/launcher_icon',
    styleInformation: BigTextStyleInformation(''),
  );

  static const _reminderChannel = AndroidNotificationDetails(
    'healthai_reminders',
    'Health Reminders',
    channelDescription: 'Habit, water, and workout reminders',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
    icon: '@mipmap/launcher_icon',
  );

  static const _weeklyChannel = AndroidNotificationDetails(
    'healthai_weekly',
    'Weekly Reports',
    channelDescription: 'Weekly AI health report card',
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/launcher_icon',
    styleInformation: BigTextStyleInformation(''),
  );

  NotificationDetails get _dailyDetails => const NotificationDetails(
        android: _dailyChannel,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

  NotificationDetails get _reminderDetails => const NotificationDetails(
        android: _reminderChannel,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      );

  NotificationDetails get _weeklyDetails => const NotificationDetails(
        android: _weeklyChannel,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

  // ── Schedule helpers ──────────────────────────────────────────────────────

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute,
      {int dayOffset = 0}) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
        tz.local, now.year, now.month, now.day + dayOffset, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  // ── Morning motivation ────────────────────────────────────────────────────

  static const List<String> _morningMessages = [
    "Good morning! Ready to crush today's goals? Your AI coach is here.",
    "Rise and shine! Let's check your progress and plan a great day.",
    "Morning check-in time! How are you feeling today? Open your coach.",
    "New day, new goals! Your personalized health plan is waiting for you.",
    "Good morning! Your streak is on the line — let's keep it going!",
    "Fuel up and move! Your AI coach has today's nutrition tips ready.",
    "Morning! Track your sleep and energy to unlock today's workout plan.",
    "Another day, another step closer to your goal! Open HealthAI to stay on track.",
  ];

  Future<void> scheduleMorningMotivation({int hour = 8, int minute = 0}) async {
    await _plugin.cancel(_NotifId.morningMotivation);
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(_PrefKey.notificationsEnabled) ?? true)) return;
    if (!(prefs.getBool(_PrefKey.morningMotivationEnabled) ?? true)) return;

    final msgIndex = DateTime.now().day % _morningMessages.length;
    final msg = _morningMessages[msgIndex];

      await _plugin.zonedSchedule(
        _NotifId.morningMotivation,
        'HealthAI Morning Check-in',
        msg,
        _nextInstanceOfTime(hour, minute),
        _dailyDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
  }

  // ── Habit reminder ────────────────────────────────────────────────────────

  Future<void> scheduleHabitReminder({int hour = 20, int minute = 0}) async {
    await _plugin.cancel(_NotifId.habitReminder);
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(_PrefKey.habitReminderEnabled) ?? true)) return;

      await _plugin.zonedSchedule(
        _NotifId.habitReminder,
        'Habit Check-in',
        "Don't forget to log today's habits before bed — keep that streak alive!",
        _nextInstanceOfTime(hour, minute),
        _reminderDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
  }

  // ── Water reminder ────────────────────────────────────────────────────────

  Future<void> scheduleWaterReminders() async {
    for (int i = 0; i < 6; i++) {
      await _plugin.cancel(_NotifId.waterReminder + i);
    }
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(_PrefKey.waterReminderEnabled) ?? false)) return;

    final times = [9, 11, 13, 15, 17, 19];
    for (int i = 0; i < times.length; i++) {
        await _plugin.zonedSchedule(
          _NotifId.waterReminder + i,
          'Hydration Reminder',
          'Time to drink a glass of water! Stay hydrated for peak performance.',
          _nextInstanceOfTime(times[i], 0),
          _reminderDetails,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        );
    }
  }

  // ── Weekly report ─────────────────────────────────────────────────────────

  Future<void> scheduleWeeklyReport(
      {int weekday = DateTime.sunday,
      int hour = 9,
      int minute = 0}) async {
    await _plugin.cancel(_NotifId.weeklyReport);
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(_PrefKey.weeklyReportEnabled) ?? true)) return;

    final now = tz.TZDateTime.now(tz.local);
    int daysUntil = (weekday - now.weekday).toInt();
    if (daysUntil <= 0) daysUntil += 7;

    final scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day + daysUntil,
      hour,
      minute,
    );

      await _plugin.zonedSchedule(
        _NotifId.weeklyReport,
        'Your Weekly Health Report is Ready!',
        "AI has analyzed your week. Tap to see your report card, highlights, and next week's focus.",
        scheduled,
        _weeklyDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
  }

  // ── Workout reminder ──────────────────────────────────────────────────────

  Future<void> scheduleWorkoutReminder({
    required String workoutName,
    required DateTime scheduledTime,
  }) async {
    await _plugin.cancel(_NotifId.workoutReminder);
    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);
    if (tzTime.isBefore(tz.TZDateTime.now(tz.local))) return;

      await _plugin.zonedSchedule(
        _NotifId.workoutReminder,
        'Workout Reminder',
        "Time for $workoutName! Your AI coach is ready to guide you through it.",
        tzTime,
        _reminderDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
  }

  // ── Evening proactive nudge (8 PM) ───────────────────────────────────────

  Future<void> scheduleEveningNudge({
    int completedHabits = 0,
    int totalHabits = 0,
    int caloriesConsumed = 0,
    int calorieGoal = 2000,
    bool hadWorkoutToday = false,
  }) async {
    await _plugin.cancel(_NotifId.eveningNudge);
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(_PrefKey.notificationsEnabled) ?? true)) return;

    final parts = <String>[];

    if (totalHabits > 0) {
      if (completedHabits == totalHabits) {
        parts.add('All $totalHabits habits done today — amazing!');
      } else {
        final remaining = totalHabits - completedHabits;
        parts.add(
            '$remaining habit${remaining > 1 ? 's' : ''} still to go — keep the streak alive!');
      }
    }

    final calRemaining = calorieGoal - caloriesConsumed;
    if (caloriesConsumed > 0 && calRemaining > 200) {
      parts.add('You\'re $calRemaining kcal under your goal — grab a snack.');
    } else if (caloriesConsumed > 0 && calRemaining < -200) {
      parts.add('You\'re ${-calRemaining} kcal over today — lighter dinner?');
    }

    if (!hadWorkoutToday) {
      parts.add('No workout logged yet — even a 15-min walk counts!');
    }

    final body = parts.isEmpty
        ? 'Check in with your AI coach to review today\'s progress.'
        : parts.join(' ');

      await _plugin.zonedSchedule(
        _NotifId.eveningNudge,
        'Evening Health Check-in',
        body,
        _nextInstanceOfTime(20, 0),
        _dailyDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
  }

  // ── Schedule all defaults ─────────────────────────────────────────────────

  Future<void> scheduleAllDefaults() async {
    await scheduleMorningMotivation(hour: 8, minute: 0);
    await scheduleHabitReminder(hour: 20, minute: 0);
    await scheduleWeeklyReport();
  }

  // ── Cancel all ────────────────────────────────────────────────────────────

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // ── Preferences getters/setters ───────────────────────────────────────────

  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_PrefKey.notificationsEnabled) ?? true;
  }

  Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_PrefKey.notificationsEnabled, value);
    if (value) {
      await scheduleAllDefaults();
    } else {
      await cancelAll();
    }
  }

  Future<bool> getMorningMotivationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_PrefKey.morningMotivationEnabled) ?? true;
  }

  Future<void> setMorningMotivationEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_PrefKey.morningMotivationEnabled, value);
    if (value) {
      await scheduleMorningMotivation();
    } else {
      await _plugin.cancel(_NotifId.morningMotivation);
    }
  }

  Future<bool> getHabitReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_PrefKey.habitReminderEnabled) ?? true;
  }

  Future<void> setHabitReminderEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_PrefKey.habitReminderEnabled, value);
    if (value) {
      await scheduleHabitReminder();
    } else {
      await _plugin.cancel(_NotifId.habitReminder);
    }
  }

  Future<bool> getWaterReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_PrefKey.waterReminderEnabled) ?? false;
  }

  Future<void> setWaterReminderEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_PrefKey.waterReminderEnabled, value);
    if (value) {
      await scheduleWaterReminders();
    } else {
      for (int i = 0; i < 6; i++) {
        await _plugin.cancel(_NotifId.waterReminder + i);
      }
    }
  }

  Future<bool> getWeeklyReportEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_PrefKey.weeklyReportEnabled) ?? true;
  }

  Future<void> setWeeklyReportEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_PrefKey.weeklyReportEnabled, value);
    if (value) {
      await scheduleWeeklyReport();
    } else {
      await _plugin.cancel(_NotifId.weeklyReport);
    }
  }

  // ── Test notification ─────────────────────────────────────────────────────

  Future<void> showTestNotification() async {
      await _plugin.show(
        9999,
        'Notifications are working!',
        'HealthAI will now send you daily motivation and health reminders.',
        _dailyDetails,
      );
  }
}
