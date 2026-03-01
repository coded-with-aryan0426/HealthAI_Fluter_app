import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';

/// A snapshot of today's health data synced from HealthKit / Health Connect.
class HealthSnapshot {
  final int steps;
  final int sleepMinutes;
  final int activeCaloriesBurned;
  final bool hasPermission;

  const HealthSnapshot({
    this.steps = 0,
    this.sleepMinutes = 0,
    this.activeCaloriesBurned = 0,
    this.hasPermission = false,
  });
}

final _healthTypes = [
  HealthDataType.STEPS,
  HealthDataType.SLEEP_ASLEEP,
  HealthDataType.ACTIVE_ENERGY_BURNED,
];

class HealthService {
  final _health = Health();

  Future<bool> requestPermissions() async {
    try {
      final requested = await _health.requestAuthorization(
        _healthTypes,
        permissions: [
          HealthDataAccess.READ,
          HealthDataAccess.READ,
          HealthDataAccess.READ,
        ],
      );
      return requested;
    } catch (_) {
      return false;
    }
  }

  Future<HealthSnapshot> fetchToday() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      final hasAuth = await _health.hasPermissions(_healthTypes) ?? false;
      if (!hasAuth) {
        final granted = await requestPermissions();
        if (!granted) {
          return const HealthSnapshot(hasPermission: false);
        }
      }

      final data = await _health.getHealthDataFromTypes(
        startTime: startOfDay,
        endTime: now,
        types: _healthTypes,
      );

      int steps = 0;
      int sleepMinutes = 0;
      int activeCalories = 0;

      for (final point in data) {
        final value = (point.value as NumericHealthValue).numericValue;

        if (point.type == HealthDataType.STEPS) {
          steps += value.toInt();
            } else if (point.type == HealthDataType.SLEEP_ASLEEP) {
              sleepMinutes += value.toInt();
            } else if (point.type == HealthDataType.ACTIVE_ENERGY_BURNED) {
              activeCalories += value.toInt();
        }
      }

      return HealthSnapshot(
        steps: steps,
        sleepMinutes: sleepMinutes,
        activeCaloriesBurned: activeCalories,
        hasPermission: true,
      );
    } catch (_) {
      return const HealthSnapshot(hasPermission: false);
    }
  }
}

final healthServiceProvider = Provider<HealthService>((ref) => HealthService());

final healthSnapshotProvider = FutureProvider<HealthSnapshot>((ref) async {
  final service = ref.read(healthServiceProvider);
  return service.fetchToday();
});
