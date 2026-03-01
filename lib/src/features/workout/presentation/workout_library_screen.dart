import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:isar/isar.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:health_app/src/theme/app_colors.dart';
import '../../../services/local_db_service.dart';
import '../../../database/models/workout_plan_doc.dart';
import '../../../database/models/workout_doc.dart';
import '../application/workout_plan_controller.dart';
import 'widgets/adaptive_suggestions_card.dart';

// ── History provider (local to this screen) ───────────────────────────────────

final workoutHistoryProvider = Provider<List<WorkoutDoc>>((ref) {
  final isar = ref.watch(isarProvider);
  final all = isar.workoutDocs.where().idGreaterThan(0).findAllSync();
  all.sort((a, b) => b.date.compareTo(a.date));
  return all.take(20).toList();
});

// ── Screen ────────────────────────────────────────────────────────────────────

class WorkoutLibraryScreen extends ConsumerStatefulWidget {
  const WorkoutLibraryScreen({super.key});

  @override
  ConsumerState<WorkoutLibraryScreen> createState() =>
      _WorkoutLibraryScreenState();
}

class _WorkoutLibraryScreenState
    extends ConsumerState<WorkoutLibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

      return Scaffold(
        backgroundColor:
            isDark ? AppColors.deepObsidian : const Color(0xFFF7F8FC),
        body: NestedScrollView(
          headerSliverBuilder: (_, __) => [
            SliverAppBar(
              pinned: true,
              expandedHeight: 120,
              backgroundColor:
                  isDark ? AppColors.deepObsidian : Colors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              automaticallyImplyLeading: false,
              leading: context.canPop()
                  ? IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(PhosphorIconsRegular.arrowLeft,
                            color: isDark ? Colors.white : AppColors.lightTextPrimary,
                            size: 18),
                      ),
                      onPressed: () => context.pop(),
                    )
                  : null,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsets.fromLTRB(
                    context.canPop() ? 56 : 16, 0, 16, 52),
                title: Text(
                  'Workout',
                  style: TextStyle(
                    color: isDark
                        ? Colors.white
                        : AppColors.lightTextPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              bottom: TabBar(
                controller: _tab,
                labelColor:
                    isDark ? Colors.white : AppColors.lightTextPrimary,
                unselectedLabelColor:
                    isDark ? Colors.white38 : Colors.black38,
                indicatorColor: AppColors.softIndigo,
                indicatorWeight: 3,
                labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13),
                tabs: const [
                  Tab(text: 'My Plans'),
                  Tab(text: 'Programs'),
                  Tab(text: 'History'),
                ],
              ),
            ),
          ],
        body: TabBarView(
          controller: _tab,
          children: [
              _PlansTab(isDark: isDark),
              _ProgramsTab(isDark: isDark),
              _HistoryTab(isDark: isDark),
            ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/chat'),
        backgroundColor: AppColors.softIndigo,
        elevation: 8,
        icon: const Icon(PhosphorIconsFill.sparkle,
            color: Colors.white, size: 18),
        label: const Text('AI Generate',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13)),
        ).animate().scale(delay: 400.ms, curve: Curves.easeOutBack),
    );
  }
}

// ── Plans Tab ─────────────────────────────────────────────────────────────────

class _PlansTab extends ConsumerWidget {
  final bool isDark;
  const _PlansTab({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(savedPlansProvider);

    return plansAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.softIndigo),
      ),
      error: (e, _) => Center(
        child: Text('Error: $e',
            style: const TextStyle(color: Colors.red)),
      ),
      data: (plans) {
        if (plans.isEmpty) {
          return Column(
            children: [
              const SizedBox(height: 16),
              AdaptiveSuggestionsCard(isDark: isDark),
              Expanded(
                child: _EmptyState(
                  icon: PhosphorIconsFill.barbell,
                  title: 'No saved plans yet',
                  subtitle:
                      'Tap AI Generate to create your first personalized workout plan.',
                  isDark: isDark,
                ),
              ),
            ],
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 120),
          itemCount: plans.length + 1, // +1 for AI card at top
          itemBuilder: (_, i) {
            if (i == 0) {
              return AdaptiveSuggestionsCard(isDark: isDark);
            }
            final plan = plans[i - 1];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _PlanCard(plan: plan, isDark: isDark)
                  .animate(delay: Duration(milliseconds: 60 * i))
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.1, end: 0, duration: 400.ms),
            );
          },
        );
      },
    );
  }
}

class _PlanCard extends ConsumerWidget {
  final WorkoutPlanDoc plan;
  final bool isDark;
  const _PlanCard({required this.plan, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGym = plan.mode == 'gym';
    final accent = isGym ? AppColors.softIndigo : AppColors.dynamicMint;
    final exerciseCount = plan.exercises.length;
    final totalSets =
        plan.exercises.fold(0, (sum, e) => sum + e.sets);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push('/workout/preview', extra: plan);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.charcoalGlass : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.04),
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Mode icon
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accent, accent.withValues(alpha: 0.6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: accent.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Icon(
                isGym
                    ? PhosphorIconsFill.barbell
                    : PhosphorIconsFill.personSimpleRun,
                color: Colors.white, size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? Colors.white
                          : AppColors.lightTextPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _PlanChip(
                          label: '$exerciseCount exercises',
                          color: accent),
                      const SizedBox(width: 6),
                      _PlanChip(
                          label: '$totalSets sets',
                          color: accent),
                      const SizedBox(width: 6),
                      _PlanChip(
                          label: isGym ? 'Gym' : 'Home',
                          color: accent),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Start button
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                context.push('/workout', extra: plan);
              },
              child: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: accent.withValues(alpha: 0.3)),
                ),
                child: Icon(PhosphorIconsFill.play,
                    color: accent, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanChip extends StatelessWidget {
  final String label;
  final Color color;
  const _PlanChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color)),
    );
  }
}

// ── Programs Tab ──────────────────────────────────────────────────────────────

class _ProgramsTab extends ConsumerWidget {
  final bool isDark;
  const _ProgramsTab({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.softIndigo.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(PhosphorIconsFill.trophy,
                size: 34, color: AppColors.softIndigo),
          ),
          const SizedBox(height: 16),
          Text(
            'Multi-Week Programs',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Build and track structured multi-week training programs.',
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: isDark
                    ? Colors.white38
                    : AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => context.push('/workout/programs'),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [
                  AppColors.softIndigo,
                  Color(0xFF8B5CF6),
                ]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.softIndigo.withValues(alpha: 0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 6))
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(PhosphorIconsFill.trophy,
                      color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text('View Programs',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── History Tab ───────────────────────────────────────────────────────────────

class _HistoryTab extends ConsumerWidget {
  final bool isDark;
  const _HistoryTab({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(workoutHistoryProvider);

    if (history.isEmpty) {
      return _EmptyState(
        icon: PhosphorIconsFill.clockCounterClockwise,
        title: 'No workouts yet',
        subtitle: 'Complete your first session to see it here.',
        isDark: isDark,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      itemCount: history.length,
      itemBuilder: (_, i) {
        final w = history[i];
        return _HistoryCard(workout: w, isDark: isDark)
            .animate(delay: Duration(milliseconds: 60 * i))
            .fadeIn(duration: 400.ms)
            .slideX(begin: 0.05, end: 0, duration: 400.ms);
      },
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final WorkoutDoc workout;
  final bool isDark;
  const _HistoryCard({required this.workout, required this.isDark});

  String _formatDuration(int secs) {
    if (secs == 0) return '—';
    final m = secs ~/ 60;
    final s = secs % 60;
    return m > 0 ? '${m}m ${s}s' : '${s}s';
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '${d.day}/${d.month}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final setsDone = workout.exercises
        .fold(0, (sum, e) => sum + e.sets.where((s) => s.completed).length);
    final totalSets =
        workout.exercises.fold(0, (sum, e) => sum + e.sets.length);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.charcoalGlass : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(PhosphorIconsFill.barbell,
                color: AppColors.warning, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(workout.title,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? Colors.white
                            : AppColors.lightTextPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(
                  _formatDate(workout.date),
                  style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.45)),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatDuration(workout.durationSeconds),
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.warning),
              ),
              const SizedBox(height: 2),
              Text(
                '$setsDone/$totalSets sets',
                style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.4)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppColors.softIndigo.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  size: 38,
                  color: AppColors.softIndigo.withValues(alpha: 0.5)),
            ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 20),
            Text(title,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? Colors.white
                        : AppColors.lightTextPrimary),
                textAlign: TextAlign.center)
                .animate(delay: 100.ms).fadeIn(),
            const SizedBox(height: 8),
            Text(subtitle,
                style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.45)),
                textAlign: TextAlign.center)
                .animate(delay: 180.ms).fadeIn(),
          ],
        ),
      ),
    );
  }
}
