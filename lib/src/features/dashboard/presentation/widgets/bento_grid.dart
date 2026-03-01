import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:health_app/src/theme/app_colors.dart';
import '../../application/daily_activity_provider.dart';

class BentoGrid extends ConsumerWidget {
  const BentoGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read the current daily activity state
    final today = ref.watch(dailyActivityProvider);
    // Two columns, auto flow layout
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.1, // slightly wider than tall
        shrinkWrap: true, // required for slivers or simple scrollviews
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Water Progress
          const _BentoCard(
            title: 'WATER',
            mainValue: '1200',
            subtitle: '/ 2500 ml',
            iconColor: AppColors.success,
            iconData: Icons.water_drop,
          ),
          // Sleep Score
          _BentoCard(
            title: 'SLEEP',
            mainValue: '${(today.sleepMinutes / 60).toStringAsFixed(1)}',
            subtitle: 'Hours',
            iconColor: AppColors.softIndigo,
            iconData: Icons.bedtime,
          ),
          // Next Workout
          const _BentoCard(
            title: 'WORKOUT',
            mainValue: 'None',
            subtitle: '-',
            iconColor: AppColors.warning,
            iconData: Icons.fitness_center,
          ),
          // Macros
          _BentoCard(
            title: 'PROTEIN',
            mainValue: '${today.proteinGrams}g',
            subtitle: 'Logged',
            iconColor: AppColors.danger,
            iconData: Icons.local_dining,
          ),
        ].animate(interval: 100.ms).fade(duration: 600.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
      ),
    );
  }
}

class _BentoCard extends StatelessWidget {
  final String title;
  final String mainValue;
  final String subtitle;
  final Color iconColor;
  final IconData iconData;

  const _BentoCard({
    required this.title,
    required this.mainValue,
    required this.subtitle,
    required this.iconColor,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    // Bento card depends on CardTheme implicitly set for the App Theme
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(iconData, color: iconColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mainValue,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 28,
                  ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
