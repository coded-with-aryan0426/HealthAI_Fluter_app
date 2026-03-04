import 'dart:developer' as dev;
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';

/// Full snapshot of today's health data from HealthKit (iOS) or Health Connect (Android).
class HealthSnapshot {
  final int steps;
  final int sleepMinutes;
  final int activeCaloriesBurned;
  final int exerciseMinutes;
  final int standHours;
  final double heartRateBpm;     // average today
  final double distanceMeters;
  final bool hasPermission;

  const HealthSnapshot({
    this.steps = 0,
    this.sleepMinutes = 0,
    this.activeCaloriesBurned = 0,
    this.exerciseMinutes = 0,
    this.standHours = 0,
    this.heartRateBpm = 0,
    this.distanceMeters = 0,
    this.hasPermission = false,
  });
}

// ── Data types we want to read ────────────────────────────────────────────────
final _kReadTypes = <HealthDataType>[
  HealthDataType.STEPS,
  HealthDataType.SLEEP_ASLEEP,
  HealthDataType.ACTIVE_ENERGY_BURNED,
  HealthDataType.HEART_RATE,
  if (Platform.isIOS) HealthDataType.DISTANCE_WALKING_RUNNING,
  if (Platform.isIOS) HealthDataType.EXERCISE_TIME,
  if (Platform.isAndroid) HealthDataType.WORKOUT,
];

class HealthService {
  final _health = Health();

  // Permission state: null = unknown, true = granted, false = denied
  bool? _permissionGranted;

  // Cache last fetch result to avoid hammering Health Connect
  HealthSnapshot? _cachedSnapshot;
  DateTime? _lastFetchTime;
  static const _cacheDuration = Duration(minutes: 5);

  /// Call once at startup. Shows the system permission dialog.
  Future<bool> requestPermissions() async {
    try {
      final types = _kReadTypes;
      final perms = List.filled(types.length, HealthDataAccess.READ);
      final granted = await _health.requestAuthorization(types, permissions: perms);
      _permissionGranted = granted;
      dev.log('[HealthService] requestPermissions → granted=$granted', name: 'HealthService');
      return granted;
    } catch (e, st) {
      dev.log('[HealthService] requestPermissions failed: $e', name: 'HealthService', error: e, stackTrace: st);
      _permissionGranted = false;
      return false;
    }
  }

  /// Returns true if we already have health permissions (no dialog).
  Future<bool> hasPermissions() async {
    // Return cached result if we already know
    if (_permissionGranted != null) return _permissionGranted!;

    try {
      final result = await _health.hasPermissions(_kReadTypes);
      final granted = result ?? false;
      dev.log('[HealthService] hasPermissions → $granted', name: 'HealthService');
      // Only cache a positive result; keep re-checking if denied
      // so user can grant later without restarting
      if (granted) _permissionGranted = true;
      return granted;
    } catch (e) {
      dev.log('[HealthService] hasPermissions failed: $e', name: 'HealthService', error: e);
      return false;
    }
  }

  /// Fetch today's full health snapshot.
  /// - Returns cached data if fresh enough.
  /// - Returns empty snapshot (no exception storm) when permission is denied.
  Future<HealthSnapshot> fetchToday({bool forceRefresh = false}) async {
    // Return cache if fresh and not forcing
    if (!forceRefresh && _cachedSnapshot != null && _lastFetchTime != null) {
      final age = DateTime.now().difference(_lastFetchTime!);
      if (age < _cacheDuration) {
        dev.log('[HealthService] returning cached snapshot (age=${age.inSeconds}s)', name: 'HealthService');
        return _cachedSnapshot!;
      }
    }

    // Check / request permissions — but STOP if denied, no retry
    if (_permissionGranted != true) {
      final already = await hasPermissions();
      if (!already) {
        final granted = await requestPermissions();
        if (!granted) {
          dev.log('[HealthService] fetchToday: permissions denied, returning empty snapshot',
              name: 'HealthService');
          return const HealthSnapshot(hasPermission: false);
        }
      }
    }

    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      final data = <HealthDataPoint>[];
      for (final type in _kReadTypes) {
        try {
          final points = await _health.getHealthDataFromTypes(
            startTime: startOfDay,
            endTime: now,
            types: [type],
          );
          data.addAll(points);
        } catch (e) {
          // A SecurityException here means permission was revoked mid-session
          // Mark permission as unknown so next full fetch re-checks
          if (e.toString().contains('SecurityException') ||
              e.toString().contains('permission')) {
            _permissionGranted = null;
          }
          dev.log('[HealthService] skipping $type: $e', name: 'HealthService');
        }
      }

      dev.log('[HealthService] raw data points: ${data.length}', name: 'HealthService');

      final deduped = _health.removeDuplicates(data);
      dev.log('[HealthService] deduped points: ${deduped.length}', name: 'HealthService');

      int steps = 0;
      int sleepMinutes = 0;
      int activeCalories = 0;
      int exerciseMinutes = 0;
      double totalHeartRate = 0;
      int heartRateCount = 0;
      double distanceMeters = 0;

      for (final point in deduped) {
        final raw = point.value;
        final double numVal =
            raw is NumericHealthValue ? raw.numericValue.toDouble() : 0.0;

        switch (point.type) {
          case HealthDataType.STEPS:
            steps += numVal.toInt();
            break;
          case HealthDataType.SLEEP_ASLEEP:
            sleepMinutes += numVal.toInt();
            break;
          case HealthDataType.ACTIVE_ENERGY_BURNED:
            activeCalories += numVal.toInt();
            break;
          case HealthDataType.HEART_RATE:
            totalHeartRate += numVal;
            heartRateCount++;
            break;
          case HealthDataType.DISTANCE_WALKING_RUNNING:
            distanceMeters += numVal;
            break;
          case HealthDataType.EXERCISE_TIME:
            exerciseMinutes += numVal.toInt();
            break;
          case HealthDataType.WORKOUT:
            exerciseMinutes += (numVal / 60).round();
            break;
          default:
            break;
        }
      }

      if (exerciseMinutes == 0 && steps > 0) {
        exerciseMinutes = (steps / 100).round().clamp(0, 180);
      }
      final standHours = (steps / 1000).floor().clamp(0, 12);
      final avgHeartRate =
          heartRateCount > 0 ? totalHeartRate / heartRateCount : 0.0;

      dev.log(
        '[HealthService] snapshot: steps=$steps sleep=${sleepMinutes}min '
        'cals=$activeCalories exercise=${exerciseMinutes}min '
        'stand=${standHours}h hr=${avgHeartRate.toStringAsFixed(0)}bpm '
        'dist=${distanceMeters.toStringAsFixed(0)}m',
        name: 'HealthService',
      );

      final snapshot = HealthSnapshot(
        steps: steps,
        sleepMinutes: sleepMinutes,
        activeCaloriesBurned: activeCalories,
        exerciseMinutes: exerciseMinutes,
        standHours: standHours,
        heartRateBpm: avgHeartRate,
        distanceMeters: distanceMeters,
        hasPermission: true,
      );

      _cachedSnapshot = snapshot;
      _lastFetchTime = DateTime.now();
      return snapshot;
    } catch (e, st) {
      dev.log('[HealthService] fetchToday failed: $e',
          name: 'HealthService', error: e, stackTrace: st);
      // Return cache if available, otherwise empty
      return _cachedSnapshot ?? const HealthSnapshot(hasPermission: false);
    }
  }
}

// Single shared instance — avoids permission state being reset on every rebuild
final healthServiceProvider = Provider<HealthService>((ref) => HealthService());

final healthSnapshotProvider = FutureProvider<HealthSnapshot>((ref) async {
  // keepAlive prevents Riverpod from disposing this provider when no widget
  // is currently watching it (e.g. during navigation). Without this, every
  // time the dashboard rebuilds it disposes + re-creates the provider,
  // triggering a new fetchToday() → requestPermissions() → SecurityException storm.
  ref.keepAlive();
  final service = ref.read(healthServiceProvider);
  return service.fetchToday();
});
