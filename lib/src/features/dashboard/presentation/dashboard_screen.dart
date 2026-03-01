import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/hero_activity_rings.dart';
import '../application/daily_activity_provider.dart';
import '../application/daily_insight_provider.dart';
import '../application/weekly_stats_provider.dart';
import 'package:health_app/src/theme/app_colors.dart';
import 'package:health_app/src/theme/theme_provider.dart';
import '../../profile/application/user_provider.dart';
import '../../workout/application/workout_controller.dart';
import '../../habits/application/habit_provider.dart';
import '../../../database/models/habit_doc.dart';
import '../../fasting/application/fasting_provider.dart';
import '../../body_composition/application/body_provider.dart';
import '../../supplements/application/supplement_provider.dart';
import '../../chat/application/chat_controller.dart'
    show chatPrefilledMessageProvider;
import '../../../services/notification_service.dart'
    show eveningNudgeSchedulerProvider;

// ── Achievement definitions ───────────────────────────────────────────────────
const _kAchievements = <String, _AchievementDef>{
  'first_water':    _AchievementDef('First Drop',        'Logged your first water',         PhosphorIconsFill.drop,        Color(0xFF41C9E2)),
  'hydration_hero': _AchievementDef('Hydration Hero',    'Hit daily water goal',            PhosphorIconsFill.drop,        Color(0xFF00B4D8)),
  'step_starter':   _AchievementDef('Step Starter',      'Logged 1,000+ steps',             PhosphorIconsFill.sneaker,     AppColors.dynamicMint),
  'mover':          _AchievementDef('Mover',             'Hit 10,000 steps in a day',       PhosphorIconsFill.personSimpleRun, AppColors.dynamicMint),
  'calorie_logger': _AchievementDef('Calorie Logger',    'Logged your first meal',          PhosphorIconsFill.forkKnife,   AppColors.warning),
  'goal_crusher':   _AchievementDef('Goal Crusher',      'Hit calorie goal for today',      PhosphorIconsFill.trophy,      AppColors.warning),
  'sleep_tracker':  _AchievementDef('Sleep Tracker',     'Logged first sleep entry',        PhosphorIconsFill.moon,        AppColors.softIndigo),
  'well_rested':    _AchievementDef('Well Rested',       'Slept 7+ hours',                  PhosphorIconsFill.moon,        AppColors.softIndigo),
  'first_workout':  _AchievementDef('First Workout',     'Completed first exercise',        PhosphorIconsFill.barbell,     AppColors.danger),
  'protein_pro':    _AchievementDef('Protein Pro',       'Hit protein goal for today',      PhosphorIconsFill.egg,         AppColors.danger),
};

class _AchievementDef {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  const _AchievementDef(this.title, this.subtitle, this.icon, this.color);
}

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Health sync (best-effort, never blocks UI)
      ref.read(dailyActivityProvider.notifier).syncFromHealth();
      // Achievement check
      await _checkAndShowAchievements();
    });
  }

  /// Evaluates today's stats against achievement conditions.
  /// Newly unlocked achievements are shown one-by-one as trophy modals.
  Future<void> _checkAndShowAchievements() async {
    if (!mounted) return;
    final today = ref.read(dailyActivityProvider);
    final user  = ref.read(userProvider);
    final calorieGoal  = user.calorieGoal;
    final proteinGoal  = user.proteinGoalG;
    final waterGoal    = today.waterGoalMl;

    final candidates = <String>[];
    if (today.waterMl > 0)                                    candidates.add('first_water');
    if (today.waterMl >= waterGoal)                           candidates.add('hydration_hero');
    if (today.stepCount >= 1000)                              candidates.add('step_starter');
    if (today.stepCount >= 10000)                             candidates.add('mover');
    if (today.caloriesConsumed > 0)                           candidates.add('calorie_logger');
    if (today.caloriesConsumed >= calorieGoal)                candidates.add('goal_crusher');
    if (today.sleepMinutes > 0)                               candidates.add('sleep_tracker');
    if (today.sleepMinutes >= 420)                            candidates.add('well_rested');
    if (today.caloriesBurned > 0)                             candidates.add('first_workout');
    if (today.proteinGrams >= proteinGoal)                    candidates.add('protein_pro');

    final newlyUnlocked = await ref.read(userProvider.notifier).unlockAchievements(candidates);
    if (!mounted) return;

    for (final id in newlyUnlocked) {
      final def = _kAchievements[id];
      if (def == null) continue;
      HapticFeedback.heavyImpact();
      await _showTrophyModal(def);
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 400));
    }
  }

  Future<void> _showTrophyModal(_AchievementDef def) async {
    if (!mounted) return;
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Achievement',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 350),
      transitionBuilder: (ctx, anim, _, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: anim, child: child),
        );
      },
      pageBuilder: (ctx, _, __) => _TrophyModal(def: def),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = ref.watch(dailyActivityProvider);
    final user = ref.watch(userProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayName = user.displayName ?? 'You';

    // Keep 8 PM evening nudge notification synced with today's live data
    ref.watch(eveningNudgeSchedulerProvider);

    // #44 – is this user's very first session (all stats are zero)?
    final isAllZero = today.waterMl == 0 &&
        today.stepCount == 0 &&
        today.caloriesConsumed == 0 &&
        today.caloriesBurned == 0 &&
        today.sleepMinutes == 0 &&
        today.proteinGrams == 0;

    return PopScope(
      canPop: false,
      child: Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Glassmorphic sticky header
          SliverAppBar(
            pinned: true,
            expandedHeight: 0,
            backgroundColor: isDark
                ? AppColors.deepObsidian.withOpacity(0.85)
                : Colors.white.withOpacity(0.85),
            elevation: 0,
            scrolledUnderElevation: 0,
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(color: Colors.transparent),
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_greeting()},',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                      Text(
                        displayName,
                        style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Consumer(builder: (ctx, r, _) {
                      final dark = r.watch(themeProvider) == ThemeMode.dark;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          r.read(themeProvider.notifier).toggleTheme();
                        },
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.08)
                                : Colors.black.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            dark
                                ? PhosphorIconsFill.moon
                                : PhosphorIconsFill.sun,
                            size: 20,
                            color: dark ? AppColors.softIndigo : AppColors.warning,
                          ),
                        ),
                      );
                    }),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          context.push('/profile');
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [AppColors.dynamicMint, AppColors.softIndigo],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.softIndigo.withOpacity(0.4),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: ClipOval(
                              child: user.photoUrl != null
                                  ? Image.network(user.photoUrl!, fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(PhosphorIconsFill.user, color: Colors.white, size: 20))
                                  : Center(
                                      child: Text(
                                        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                                      ),
                                    ),
                            ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 12),

              // ── #45 Welcome Banner (first-time only) ──
              const _WelcomeBanner(),

              // ── Active Workout Resume Banner ──
              _ActiveWorkoutBanner(),

              // ── Upcoming Habits Banner ──
              const _UpcomingHabitsBanner(),

              // ── #44 First-launch empty state hint ──
              if (isAllZero) const _FirstLaunchHint(),

              // ── Hero Activity Rings ──
              const HeroActivityRings(),
              const SizedBox(height: 8),

              // ── Ring legend labels ──
              _RingLegend(today: today)
                  .animate()
                  .fadeIn(delay: 600.ms, duration: 400.ms),

              const SizedBox(height: 28),

              // ── Water Tracker Card ──
              _WaterTrackerCard(today: today, isEmpty: isAllZero)
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideY(begin: 0.15, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),

                const SizedBox(height: 16),

                // ── AI Daily Insight Card ──
                _AiInsightCard(isEmpty: isAllZero),

                const SizedBox(height: 16),

                // ── Weekly Overview Banner ──
                const _WeeklyBanner(),

                const SizedBox(height: 16),

                // ── Section title ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "Today's Stats",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                ),
              ).animate().fadeIn(delay: 350.ms),

              const SizedBox(height: 16),

               // ── Bento Grid ──
               _BentoGrid(today: today, user: user, isEmpty: isAllZero),

               const SizedBox(height: 28),

               // ── Health Tools Section title ──
               Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 24),
                 child: Text(
                   'Health Tools',
                   style: Theme.of(context).textTheme.titleLarge?.copyWith(
                         fontWeight: FontWeight.bold,
                         fontSize: 18,
                       ),
                 ),
               ).animate().fadeIn(delay: 450.ms),

               const SizedBox(height: 16),

               // ── Health Tools Cards ──
               const _HealthToolsSection(),

                 const SizedBox(height: 100),
             ]),
           ),
         ],
       ),
     ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ActionButton(
            label: 'Scan',
            icon: PhosphorIconsFill.camera,
            gradient: [const Color(0xFF6B7AFF), const Color(0xFF9B59B6)],
            onTap: () => context.push('/scanner'),
          ),
            _ActionButton(
              label: 'Workout',
              icon: PhosphorIconsFill.barbell,
              gradient: [AppColors.warning, const Color(0xFFFF6B6B)],
              onTap: () => context.push('/workout/library'),
            ),
          _ActionButton(
            label: 'AI Coach',
            icon: PhosphorIconsFill.sparkle,
            gradient: [AppColors.dynamicMint, const Color(0xFF00B4D8)],
            onTap: () => context.push('/chat'),
          ),
          _ActionButton(
            label: 'Profile',
            icon: PhosphorIconsFill.user,
            gradient: [const Color(0xFFFF9F43), const Color(0xFFFFD700)],
            onTap: () => context.push('/profile'),
          ),
        ]
            .animate(interval: 60.ms)
            .scale(
              begin: const Offset(0.85, 0.85),
              end: const Offset(1, 1),
              duration: 400.ms,
              curve: Curves.easeOutBack,
            )
              .fadeIn(),
      ),
    );
  }
}

// ── Ring Legend ──────────────────────────────────────────────────────────────
class _RingLegend extends StatelessWidget {
  final dynamic today;
  const _RingLegend({required this.today});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _LegendDot(
            color: AppColors.warning,
            label: 'Calories',
            value: '${today.caloriesBurned} kcal',
          ),
          _LegendDot(
            color: AppColors.dynamicMint,
            label: 'Exercise',
            value: '${today.exerciseCompletedMinutes} min',
          ),
          _LegendDot(
            color: AppColors.softIndigo,
            label: 'Stand',
            value: '${today.standCompletedHours} hrs',
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  const _LegendDot({required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 6)],
              ),
            ),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  fontWeight: FontWeight.w500,
                )),
          ],
        ),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            )),
      ],
    );
  }
}

// ── Water Tracker Card ───────────────────────────────────────────────────────
class _WaterTrackerCard extends ConsumerWidget {
  final dynamic today;
  final bool isEmpty;
  const _WaterTrackerCard({required this.today, this.isEmpty = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final percent = (today.waterMl / today.waterGoalMl).clamp(0.0, 1.0);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onLongPress: () => _showWaterAmountSheet(context, ref),
        child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF1A2A3A), const Color(0xFF0D1B2A)]
                : [const Color(0xFFE0F7FF), const Color(0xFFB3E5FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: const Color(0xFF41C9E2).withOpacity(isDark ? 0.25 : 0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF41C9E2).withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF41C9E2).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(PhosphorIconsFill.drop,
                          color: Color(0xFF41C9E2), size: 20),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('WATER',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: const Color(0xFF41C9E2).withOpacity(0.8),
                            )),
                        Text(
                          isEmpty ? 'Start your day hydrated!' : 'Daily Hydration',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isEmpty ? FontWeight.w600 : FontWeight.normal,
                            color: isEmpty
                                ? const Color(0xFF41C9E2)
                                : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${today.waterMl}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF41C9E2),
                        ),
                      ),
                      TextSpan(
                        text: ' / ${today.waterGoalMl}ml',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Animated progress bar
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: percent),
              duration: 1200.ms,
              curve: Curves.easeOutCubic,
              builder: (context, v, _) {
                return Stack(
                  children: [
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF41C9E2).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: v,
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF41C9E2), Color(0xFF00B4D8)],
                          ),
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF41C9E2).withOpacity(0.4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 16),

            // +/- controls
            Row(
              children: [
                _WaterChip(
                    label: '-250ml',
                    onTap: () => ref
                        .read(dailyActivityProvider.notifier)
                        .removeWater(250)),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      ref
                          .read(dailyActivityProvider.notifier)
                          .addWater(250);
                    },
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF41C9E2), Color(0xFF00B4D8)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF41C9E2).withOpacity(0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(PhosphorIconsFill.plus,
                              color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text('Add 250ml',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                  _WaterChip(
                      label: '+500ml',
                      onTap: () => ref
                          .read(dailyActivityProvider.notifier)
                          .addWater(500)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WaterChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _WaterChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF41C9E2).withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: const Color(0xFF41C9E2).withOpacity(0.25)),
        ),
        alignment: Alignment.center,
        child: Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF41C9E2))),
      ),
    );
  }
}

// ── Quick Action Button ───────────────────────────────────────────────────────
class _ActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: 100.ms);
    _scale = Tween<double>(begin: 1.0, end: 0.9).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: widget.gradient.first.withOpacity(0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(widget.icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bento Grid ───────────────────────────────────────────────────────────────
class _BentoGrid extends ConsumerWidget {
  final dynamic today;
  final dynamic user;
  final bool isEmpty;
  const _BentoGrid({required this.today, required this.user, this.isEmpty = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calorieGoal = (user.calorieGoal as int?) ?? 2000;
    final proteinGoal = (user.proteinGoalG as int?) ?? 150;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.0,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _BentoCard(
            title: 'SLEEP',
            mainValue: today.sleepMinutes == 0
                ? '—'
                : (today.sleepMinutes / 60).toStringAsFixed(1),
            unit: today.sleepMinutes == 0 ? '' : 'hrs',
            subtitle: today.sleepMinutes == 0
                ? (isEmpty ? 'Tap to log sleep' : 'Tap to log')
                : 'Last night',
            iconData: PhosphorIconsFill.moon,
            gradientColors: [const Color(0xFF6B7AFF), const Color(0xFF9B59B6)],
            progress: (today.sleepMinutes / 480).clamp(0.0, 1.0),
            isEmpty: isEmpty && today.sleepMinutes == 0,
            onTap: () => _showSleepLogSheet(context, ref),
          ),
           _BentoCard(
              title: 'STEPS',
              mainValue: today.stepCount == 0 ? '—' : '${today.stepCount}',
              unit: '',
              subtitle: today.stepCount == 0
                  ? (isEmpty ? 'Walk to get started' : '/ 10,000 goal')
                  : '/ 10,000 goal',
              iconData: PhosphorIconsFill.sneaker,
              gradientColors: [AppColors.dynamicMint, const Color(0xFF00B4D8)],
              progress: (today.stepCount / 10000).clamp(0.0, 1.0),
              isEmpty: isEmpty && today.stepCount == 0,
              onTap: () => _showStepsDetailSheet(context, ref, today.stepCount),
            ),
          _BentoCard(
            title: 'PROTEIN',
            mainValue: today.proteinGrams == 0 ? '—' : '${today.proteinGrams}',
            unit: today.proteinGrams == 0 ? '' : 'g',
            subtitle: today.proteinGrams == 0
                ? (isEmpty ? 'Log your first meal' : 'Daily target: ${proteinGoal}g')
                : 'Daily target: ${proteinGoal}g',
            iconData: PhosphorIconsFill.egg,
            gradientColors: [AppColors.danger, const Color(0xFFFF6B35)],
            progress: (today.proteinGrams / proteinGoal).clamp(0.0, 1.0),
            isEmpty: isEmpty && today.proteinGrams == 0,
            onTap: () => context.push('/nutrition'),
          ),
          _BentoCard(
            title: 'CALORIES IN',
            mainValue: today.caloriesConsumed == 0 ? '—' : '${today.caloriesConsumed}',
            unit: today.caloriesConsumed == 0 ? '' : 'kcal',
            subtitle: today.caloriesConsumed == 0
                ? (isEmpty ? 'Tap to log food' : 'Goal: $calorieGoal kcal')
                : 'Goal: $calorieGoal kcal',
            iconData: PhosphorIconsFill.forkKnife,
            gradientColors: [AppColors.warning, const Color(0xFFFFD700)],
            progress: (today.caloriesConsumed / calorieGoal).clamp(0.0, 1.0),
            isEmpty: isEmpty && today.caloriesConsumed == 0,
            onTap: () => context.push('/nutrition'),
          ),
        ]
            .animate(interval: 80.ms)
            .fadeIn(duration: 500.ms)
            .slideY(
                begin: 0.2,
                end: 0,
                duration: 500.ms,
                curve: Curves.easeOutCubic),
      ),
    );
  }
}

class _BentoCard extends StatelessWidget {
  final String title;
  final String mainValue;
  final String unit;
  final String subtitle;
  final Color Function(double)? colorOverride;
  final IconData iconData;
  final List<Color> gradientColors;
  final double progress;
  final VoidCallback? onTap;
  final bool isEmpty;

  const _BentoCard({
    required this.title,
    required this.mainValue,
    required this.unit,
    required this.subtitle,
    required this.iconData,
    required this.gradientColors,
    required this.progress,
    this.colorOverride,
    this.onTap,
    this.isEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = gradientColors.first;

    Widget card = GestureDetector(
      onTap: onTap != null ? () {
        HapticFeedback.lightImpact();
        onTap!();
      } : null,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? AppColors.charcoalGlass : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.black.withOpacity(0.04),
          ),
          boxShadow: isDark
              ? [BoxShadow(color: accent.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8))]
              : [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(color: accent.withOpacity(0.35), blurRadius: 8, offset: const Offset(0, 3))
                    ],
                  ),
                  child: Icon(iconData, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: mainValue,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      if (unit.isNotEmpty)
                        TextSpan(
                          text: ' $unit',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: accent,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
                const SizedBox(height: 10),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress),
                  duration: 1400.ms,
                  curve: Curves.easeOutCubic,
                  builder: (ctx, v, _) {
                    return Stack(
                      children: [
                        Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: v,
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: gradientColors),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (isEmpty) {
      return card
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .shimmer(duration: 1600.ms, color: accent.withOpacity(0.08));
    }
    return card;
  }
}

extension PaddingExtension on Widget {
  Widget paddingOnlyRight(double right) {
    return Padding(padding: EdgeInsets.only(right: right), child: this);
  }
}

// ── Upcoming Habits Banner ───────────────────────────────────────────────────
class _UpcomingHabitsBanner extends ConsumerWidget {
  const _UpcomingHabitsBanner();

  IconData _iconFor(String name) {
    switch (name) {
      case 'flower_lotus': return PhosphorIconsFill.flowerLotus;
      case 'sneaker':      return PhosphorIconsFill.sneaker;
      case 'pill':         return PhosphorIconsFill.pill;
      case 'book':         return PhosphorIconsFill.bookOpen;
      case 'barbell':      return PhosphorIconsFill.barbell;
      case 'bed':          return PhosphorIconsFill.bed;
      case 'fork':         return PhosphorIconsFill.forkKnife;
      case 'drop':         return PhosphorIconsFill.drop;
      case 'brain':        return PhosphorIconsFill.brain;
      case 'run':          return PhosphorIconsFill.personSimpleRun;
      case 'heart':        return PhosphorIconsFill.heart;
      case 'moon':         return PhosphorIconsFill.moon;
      case 'sun':          return PhosphorIconsFill.sun;
      case 'pencil':       return PhosphorIconsFill.pencilSimple;
      case 'music':        return PhosphorIconsFill.musicNotes;
      case 'coffee':       return PhosphorIconsFill.coffee;
      case 'leaf':         return PhosphorIconsFill.leaf;
      case 'fire':         return PhosphorIconsFill.fire;
      default:             return PhosphorIconsFill.target;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);
    final notifier = ref.read(habitsProvider.notifier);
    final today = DateTime.now();

    // Show habits not yet completed today (max 3)
    final pending = habits
        .where((h) => !notifier.isCompletedOn(h, today))
        .take(3)
        .toList();

    if (pending.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          context.go('/habits');
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1A1B2E)
                : const Color(0xFFF5F5FF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.softIndigo.withOpacity(isDark ? 0.2 : 0.15),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.softIndigo.withOpacity(0.07),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.softIndigo.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  PhosphorIconsFill.clock,
                  color: AppColors.softIndigo,
                  size: 18,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TODAY\'S HABITS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.4,
                            color: AppColors.softIndigo.withOpacity(0.8),
                          ),
                        ),
                        Text(
                          '${pending.length} remaining',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...pending.map((h) => _HabitRow(
                          habit: h,
                          iconData: _iconFor(h.iconName),
                          onTap: () => ref.read(habitsProvider.notifier).toggle(h.id, today),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(delay: 100.ms, duration: 350.ms)
          .slideY(begin: -0.05, end: 0, duration: 350.ms, curve: Curves.easeOutCubic),
    );
  }
}

class _HabitRow extends StatelessWidget {
  final HabitDoc habit;
  final IconData iconData;
  final VoidCallback onTap;

  const _HabitRow({
    required this.habit,
    required this.iconData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Color(habit.colorValue);
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: accent.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accent.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Icon(iconData, color: accent, size: 15),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                habit.title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.85),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: accent.withOpacity(0.4), width: 1.5),
              ),
              child: Icon(
                PhosphorIconsRegular.check,
                size: 12,
                color: accent.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── AI Daily Insight Card ─────────────────────────────────────────────────────
class _AiInsightCard extends ConsumerWidget {
  final bool isEmpty;
  const _AiInsightCard({this.isEmpty = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightAsync = ref.watch(dailyInsightProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // #44 – show a friendly placeholder if no data logged yet
    if (isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: _buildEmptyState(context, ref, isDark),
      ).animate().fadeIn(delay: 400.ms, duration: 400.ms)
          .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: insightAsync.when(
        loading: () => _buildShimmer(isDark),
        error: (_, __) => const SizedBox.shrink(),
        data: (text) => _buildCard(context, ref, text, isDark),
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms)
        .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1A1B2E), const Color(0xFF13151F)]
              : [const Color(0xFFF0F0FF), const Color(0xFFE8EAFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.softIndigo.withOpacity(isDark ? 0.25 : 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.softIndigo, AppColors.dynamicMint],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
              .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.3)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI INSIGHT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: AppColors.softIndigo.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Log your first activity and I\'ll generate a personalised insight just for you.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? Colors.white.withOpacity(0.6)
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ref.read(chatPrefilledMessageProvider.notifier).state =
                        'I\'m just getting started. What should I focus on first for my health?';
                    context.push('/chat');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.softIndigo, AppColors.dynamicMint],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded,
                            color: Colors.white, size: 13),
                        SizedBox(width: 5),
                        Text(
                          'Ask AI Coach',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, WidgetRef ref, String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1A1B2E), const Color(0xFF13151F)]
              : [const Color(0xFFF0F0FF), const Color(0xFFE8EAFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.softIndigo.withOpacity(isDark ? 0.25 : 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.softIndigo.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.softIndigo, AppColors.dynamicMint],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.softIndigo.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.3)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'AI INSIGHT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: AppColors.softIndigo.withOpacity(0.8),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ref.read(dailyInsightProvider.notifier).refresh();
                      },
                      child: Icon(
                        PhosphorIconsRegular.arrowsClockwise,
                        size: 14,
                        color: AppColors.softIndigo.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
                  const SizedBox(height: 6),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.55,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? Colors.white.withOpacity(0.85)
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref.read(chatPrefilledMessageProvider.notifier).state =
                          'Tell me more about this insight: $text';
                      context.push('/chat');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.softIndigo, AppColors.dynamicMint],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chat_bubble_outline_rounded,
                              color: Colors.white, size: 13),
                          SizedBox(width: 5),
                          Text(
                            'Chat about this',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer(bool isDark) {
    return Container(
      height: 90,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1B2E) : const Color(0xFFF0F0FF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.softIndigo.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.softIndigo.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(height: 8, width: 80,
                    decoration: BoxDecoration(color: AppColors.softIndigo.withOpacity(0.15), borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 10),
                Container(height: 8, decoration: BoxDecoration(color: AppColors.softIndigo.withOpacity(0.1), borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 6),
                Container(height: 8, width: 180, decoration: BoxDecoration(color: AppColors.softIndigo.withOpacity(0.08), borderRadius: BorderRadius.circular(4))),
              ],
            ),
          ),
        ],
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(duration: 1200.ms, color: AppColors.softIndigo.withOpacity(0.05));
  }
}

// ── Active Workout Banner ─────────────────────────────────────────────────────
class _ActiveWorkoutBanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeWorkout = ref.watch(activeWorkoutProvider);
    if (activeWorkout == null) return const SizedBox.shrink();

    final elapsedSeconds = ref.watch(activeWorkoutElapsedProvider);
    final minutes = (elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (elapsedSeconds % 60).toString().padLeft(2, '0');
    final elapsedText = '$minutes:$secs';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          context.push('/workout/player');
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B35), Color(0xFFFF3D3D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF3D3D).withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(PhosphorIconsFill.barbell, color: Colors.white, size: 22),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scaleXY(begin: 0.9, end: 1.05, duration: 900.ms),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'WORKOUT IN PROGRESS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      activeWorkout.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Live elapsed timer
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    elapsedText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 1,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'RESUME',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1),
    );
  }
}

// ── Weekly Overview Banner ────────────────────────────────────────────────────
class _WeeklyBanner extends ConsumerWidget {
  const _WeeklyBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(weeklyStatsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          context.push('/weekly');
        },
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1A1D2E), const Color(0xFF13151F)]
                  : [const Color(0xFFF5F0FF), const Color(0xFFEDE8FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.softIndigo.withOpacity(isDark ? 0.2 : 0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.softIndigo.withOpacity(0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.softIndigo, Color(0xFF9B59B6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.softIndigo.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  PhosphorIconsFill.chartBar,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'WEEKLY OVERVIEW',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: AppColors.softIndigo,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${stats.totalWorkouts} workouts · ${stats.avgSteps} avg steps',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                PhosphorIconsRegular.caretRight,
                color: AppColors.softIndigo.withOpacity(0.6),
                size: 18,
              ),
            ],
          ),
        ),
        ).animate().fadeIn(delay: 480.ms, duration: 350.ms)
            .slideY(begin: 0.06, end: 0, duration: 350.ms, curve: Curves.easeOutCubic),
      );
    }
  }

// ── Health Tools Section ──────────────────────────────────────────────────────
class _HealthToolsSection extends ConsumerWidget {
  const _HealthToolsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fastState = ref.watch(fastingProvider);
    final elapsed   = ref.watch(fastingElapsedProvider).valueOrNull ?? 0;
    final latest    = ref.watch(latestBodyEntryProvider);
    final supTaken  = ref.watch(takenCountTodayProvider);
    final supTotal  = ref.watch(supplementsProvider).length;
    final isDark    = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _HealthToolCard(
            route: '/fasting',
            icon: PhosphorIconsFill.timer,
            gradientColors: const [Color(0xFF9B59B6), Color(0xFF8E44AD)],
            title: 'Fasting',
            subtitle: fastState.isActive
                ? '${(elapsed / 3600).toStringAsFixed(1)}h / ${fastState.session?.targetHours ?? 16}h  —  ${FastingNotifier.phaseFromHours(elapsed / 3600.0).label}'
                : 'Tap to start a fast',
            badge: fastState.isActive ? 'Active' : null,
            badgeColor: const Color(0xFF9B59B6),
            isDark: isDark,
          ).animate(delay: 500.ms).fadeIn(duration: 350.ms).slideY(begin: 0.08, duration: 350.ms),

          const SizedBox(height: 12),

          _HealthToolCard(
            route: '/body',
            icon: PhosphorIconsFill.scales,
            gradientColors: const [Color(0xFF00C9A7), Color(0xFF00B4D8)],
            title: 'Body Composition',
            subtitle: latest != null
                ? 'Last: ${latest.weightKg.toStringAsFixed(1)} kg'
                : 'Log your first measurement',
            badge: null,
            badgeColor: const Color(0xFF00C9A7),
            isDark: isDark,
          ).animate(delay: 560.ms).fadeIn(duration: 350.ms).slideY(begin: 0.08, duration: 350.ms),

          const SizedBox(height: 12),

          _HealthToolCard(
            route: '/supplements',
            icon: PhosphorIconsFill.pill,
            gradientColors: const [Color(0xFF6366F1), Color(0xFF845EC2)],
            title: 'Supplements',
            subtitle: supTotal == 0
                ? 'Build your supplement stack'
                : '$supTaken / $supTotal taken today',
            badge: supTotal > 0 && supTaken == supTotal ? 'Done' : null,
            badgeColor: const Color(0xFF6366F1),
            isDark: isDark,
          ).animate(delay: 620.ms).fadeIn(duration: 350.ms).slideY(begin: 0.08, duration: 350.ms),
        ],
      ),
    );
  }
}

class _HealthToolCard extends StatelessWidget {
  final String route;
  final IconData icon;
  final List<Color> gradientColors;
  final String title;
  final String subtitle;
  final String? badge;
  final Color badgeColor;
  final bool isDark;

  const _HealthToolCard({
    required this.route,
    required this.icon,
    required this.gradientColors,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final accent = gradientColors.first;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push(route);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.charcoalGlass : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accent.withOpacity(isDark ? 0.18 : 0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0 : 0.04),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: accent.withOpacity(0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badge!,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: badgeColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.45),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              PhosphorIconsRegular.caretRight,
              color: accent.withOpacity(0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sleep Log Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

void _showSleepLogSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SleepLogSheet(
      onSave: (int minutes, String quality) {
        ref.read(dailyActivityProvider.notifier).updateSleep(minutes);
        HapticFeedback.mediumImpact();
        final h = minutes ~/ 60;
        final m = minutes % 60;
        final label = m == 0 ? '${h}h' : '${h}h ${m}m';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Sleep logged: $label ($quality) ✓'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF6B7AFF).withOpacity(0.9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 90),
        ));
      },
    ),
  );
}

class _SleepLogSheet extends StatefulWidget {
  final void Function(int minutes, String quality) onSave;
  const _SleepLogSheet({required this.onSave});

  @override
  State<_SleepLogSheet> createState() => _SleepLogSheetState();
}

class _SleepLogSheetState extends State<_SleepLogSheet> {
  // Defaults: bedtime 10:30 PM, wake 6:45 AM
  TimeOfDay _bedtime = const TimeOfDay(hour: 22, minute: 30);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 6, minute: 45);
  String _quality = 'Good';

  static const _qualities = ['Poor', 'Fair', 'Good', 'Great'];

  int get _durationMinutes {
    int bedMinutes = _bedtime.hour * 60 + _bedtime.minute;
    int wakeMinutes = _wakeTime.hour * 60 + _wakeTime.minute;
    // If wake is before bed (crosses midnight), add a full day
    if (wakeMinutes <= bedMinutes) wakeMinutes += 24 * 60;
    return wakeMinutes - bedMinutes;
  }

  String get _durationLabel {
    final total = _durationMinutes;
    final h = total ~/ 60;
    final m = total % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final min = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$min $period';
  }

  Future<void> _pickTime(bool isBedtime) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isBedtime ? _bedtime : _wakeTime,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          timePickerTheme: TimePickerThemeData(
            backgroundColor: Theme.of(ctx).brightness == Brightness.dark
                ? AppColors.charcoalGlass
                : Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isBedtime) {
        _bedtime = picked;
      } else {
        _wakeTime = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.charcoalGlass : Colors.white;
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSub = isDark ? Colors.white54 : Colors.black45;
    const accent = Color(0xFF6B7AFF);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            'Log Sleep',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 24),

          // Bedtime row
          Text('Bedtime',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textSub,
                  letterSpacing: 0.5)),
          const SizedBox(height: 8),
          _TimeRow(
            time: _formatTime(_bedtime),
            accent: accent,
            isDark: isDark,
            onTap: () => _pickTime(true),
          ),
          const SizedBox(height: 16),

          // Wake time row
          Text('Wake Time',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textSub,
                  letterSpacing: 0.5)),
          const SizedBox(height: 8),
          _TimeRow(
            time: _formatTime(_wakeTime),
            accent: accent,
            isDark: isDark,
            onTap: () => _pickTime(false),
          ),
          const SizedBox(height: 20),

          // Duration preview
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accent.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(PhosphorIconsFill.moon, color: accent, size: 20),
                const SizedBox(width: 10),
                Text(
                  'Duration: $_durationLabel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Quality selector
          Text('Quality',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textSub,
                  letterSpacing: 0.5)),
          const SizedBox(height: 10),
          Row(
            children: _qualities.map((q) {
              final selected = q == _quality;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _quality = q);
                  },
                  child: Container(
                    margin: EdgeInsets.only(
                        right: q == _qualities.last ? 0 : 8),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selected
                          ? accent
                          : accent.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: selected
                              ? accent
                              : accent.withOpacity(0.2)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      q,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : accent,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),

          // Save button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onSave(_durationMinutes, _quality);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text(
                'Save Sleep',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  final String time;
  final Color accent;
  final bool isDark;
  final VoidCallback onTap;

  const _TimeRow({
    required this.time,
    required this.accent,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.08)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              time,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Change',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: accent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Steps Detail Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

void _showStepsDetailSheet(
    BuildContext context, WidgetRef ref, int currentSteps) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _StepsDetailSheet(
      currentSteps: currentSteps,
      onUpdateSteps: (int steps) {
        ref.read(dailyActivityProvider.notifier).updateSteps(steps);
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Steps updated: $steps ✓'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.dynamicMint.withOpacity(0.9),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 90),
        ));
      },
    ),
  );
}

class _StepsDetailSheet extends StatefulWidget {
  final int currentSteps;
  final void Function(int steps) onUpdateSteps;
  const _StepsDetailSheet(
      {required this.currentSteps, required this.onUpdateSteps});

  @override
  State<_StepsDetailSheet> createState() => _StepsDetailSheetState();
}

class _StepsDetailSheetState extends State<_StepsDetailSheet> {
  static const int _goal = 10000;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentSteps.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = AppColors.dynamicMint;
    final progress = (widget.currentSteps / _goal).clamp(0.0, 1.0);
    final remaining = (_goal - widget.currentSteps).clamp(0, _goal);

    return DraggableScrollableSheet(
      initialChildSize: 0.62,
      minChildSize: 0.4,
      maxChildSize: 0.88,
      expand: false,
      builder: (_, scrollController) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.deepObsidian.withOpacity(0.96)
                  : Colors.white.withOpacity(0.98),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.07)
                      : Colors.black.withOpacity(0.06)),
            ),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.2)
                          : Colors.black.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Title row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [accent, const Color(0xFF00B4D8)]),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                              color: accent.withOpacity(0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4))
                        ],
                      ),
                      child: const Icon(PhosphorIconsFill.sneaker,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Steps Today',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? Colors.white
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          'Goal: $_goal steps',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Big count
                Center(
                  child: RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: '${widget.currentSteps}',
                        style: TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.w900,
                            color: accent,
                            height: 1.0),
                      ),
                      TextSpan(
                        text: ' / $_goal',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white38 : Colors.black38),
                      ),
                    ]),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    progress >= 1.0
                        ? 'Goal reached! Great work!'
                        : '$remaining more steps to go',
                    style: TextStyle(
                      fontSize: 13,
                      color: progress >= 1.0
                          ? accent
                          : (isDark ? Colors.white38 : Colors.black45),
                      fontWeight: progress >= 1.0
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Progress bar
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (ctx, v, _) => Stack(children: [
                    Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: v,
                      child: Container(
                        height: 12,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [accent, const Color(0xFF00B4D8)]),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                                color: accent.withOpacity(0.4), blurRadius: 8)
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 28),

                // Manual entry
                Text(
                  'LOG STEPS MANUALLY',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter step count',
                    hintStyle: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black38),
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.04),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.1)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                          color: isDark
                              ? Colors.white.withOpacity(0.08)
                              : Colors.black.withOpacity(0.08)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: accent, width: 1.5),
                    ),
                    suffixText: 'steps',
                    suffixStyle: TextStyle(color: accent, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 16),

                // Quick-add chips
                Wrap(
                  spacing: 8,
                  children: [1000, 2500, 5000].map((v) {
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        final cur = int.tryParse(_controller.text) ??
                            widget.currentSteps;
                        _controller.text = (cur + v).toString();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: accent.withOpacity(0.25)),
                        ),
                        child: Text(
                          '+$v',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: accent,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),

                // Save
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      final steps = int.tryParse(_controller.text) ?? 0;
                      Navigator.of(context).pop();
                      widget.onUpdateSteps(steps);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text('Save Steps',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Water Custom Amount Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

void _showWaterAmountSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _WaterAmountSheet(
      onAdd: (int ml) {
        ref.read(dailyActivityProvider.notifier).addWater(ml);
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Added ${ml}ml of water ✓'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF41C9E2).withOpacity(0.9),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 90),
        ));
      },
    ),
  );
}

class _WaterAmountSheet extends StatefulWidget {
  final void Function(int ml) onAdd;
  const _WaterAmountSheet({required this.onAdd});

  @override
  State<_WaterAmountSheet> createState() => _WaterAmountSheetState();
}

class _WaterAmountSheetState extends State<_WaterAmountSheet> {
  final TextEditingController _controller = TextEditingController();
  static const _accent = Color(0xFF41C9E2);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.deepObsidian.withOpacity(0.96)
                  : Colors.white.withOpacity(0.98),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.07)
                      : Colors.black.withOpacity(0.06)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.2)
                          : Colors.black.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: _accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(PhosphorIconsFill.drop,
                          color: _accent, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Log Water',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? Colors.white
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Quick chips
                Text(
                  'QUICK ADD',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [150, 250, 330, 500, 750].map((ml) {
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.of(context).pop();
                        widget.onAdd(ml);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 11),
                        decoration: BoxDecoration(
                          color: _accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: _accent.withOpacity(0.25)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${ml}ml',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _accent,
                              ),
                            ),
                            Text(
                              ml <= 250
                                  ? 'Glass'
                                  : ml == 330
                                      ? 'Can'
                                      : ml == 500
                                          ? 'Bottle'
                                          : 'Large',
                              style: TextStyle(
                                fontSize: 10,
                                color: _accent.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Custom
                Text(
                  'CUSTOM AMOUNT',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark
                              ? Colors.white
                              : AppColors.lightTextPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter ml...',
                          hintStyle: TextStyle(
                              color:
                                  isDark ? Colors.white38 : Colors.black38),
                          filled: true,
                          fillColor: isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.black.withOpacity(0.04),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                                color: isDark
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.black.withOpacity(0.1)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                                color: isDark
                                    ? Colors.white.withOpacity(0.08)
                                    : Colors.black.withOpacity(0.08)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                                color: _accent, width: 1.5),
                          ),
                          suffixText: 'ml',
                          suffixStyle: const TextStyle(
                              color: _accent, fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        final ml = int.tryParse(_controller.text) ?? 0;
                        if (ml > 0) {
                          Navigator.of(context).pop();
                          widget.onAdd(ml);
                        }
                      },
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_accent, Color(0xFF00B4D8)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: _accent.withOpacity(0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                          child: const Icon(PhosphorIconsFill.plus,
                              color: Colors.white, size: 22),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

// ── #44 First-Launch Hint Banner ─────────────────────────────────────────────
class _FirstLaunchHint extends StatelessWidget {
  const _FirstLaunchHint();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.softIndigo.withOpacity(0.12)
              : AppColors.softIndigo.withOpacity(0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.softIndigo.withOpacity(isDark ? 0.3 : 0.18),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.softIndigo.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIconsFill.sparkle,
                size: 18,
                color: AppColors.softIndigo,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome! Let\'s get started',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Log water, meals, steps or sleep to see your stats come alive.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: -0.1, end: 0, duration: 500.ms, curve: Curves.easeOutCubic);
  }
}

// ── #45 Welcome Banner (first-time only) ─────────────────────────────────────
class _WelcomeBanner extends StatefulWidget {
  const _WelcomeBanner();

  @override
  State<_WelcomeBanner> createState() => _WelcomeBannerState();
}

class _WelcomeBannerState extends State<_WelcomeBanner>
    with SingleTickerProviderStateMixin {
  bool _visible = false;
  late AnimationController _ctrl;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _slide = Tween<Offset>(begin: const Offset(0, -0.4), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _checkAndShow();
  }

  Future<void> _checkAndShow() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('hasSeenWelcomeBanner') ?? false;
    if (!seen && mounted) {
      setState(() => _visible = true);
      _ctrl.forward();
      // Auto-dismiss after 8 s
      Future.delayed(const Duration(seconds: 8), () {
        if (mounted) _dismiss();
      });
    }
  }

  Future<void> _dismiss() async {
    await _ctrl.reverse();
    if (mounted) setState(() => _visible = false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenWelcomeBanner', true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E1E3A), const Color(0xFF151528)]
                    : [const Color(0xFFEEEEFF), const Color(0xFFE2E2FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.softIndigo.withOpacity(isDark ? 0.35 : 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.softIndigo.withOpacity(0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.softIndigo, AppColors.dynamicMint],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    PhosphorIconsFill.handWaving,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome to HealthAI!',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your personal AI health coach is ready. Start by logging today\'s meals, water, and activity.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _dismiss();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(
                      PhosphorIconsRegular.x,
                      size: 18,
                      color: isDark
                          ? Colors.white.withOpacity(0.4)
                          : Colors.black.withOpacity(0.3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── #46 Trophy Modal ─────────────────────────────────────────────────────────
class _TrophyModal extends StatefulWidget {
  final _AchievementDef def;
  const _TrophyModal({required this.def});

  @override
  State<_TrophyModal> createState() => _TrophyModalState();
}

class _TrophyModalState extends State<_TrophyModal> {
  @override
  void initState() {
    super.initState();
    // Auto-close after 2.5 s
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final def = widget.def;

    return Center(
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1B2E) : Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: def.color.withOpacity(isDark ? 0.4 : 0.25),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: def.color.withOpacity(0.25),
                  blurRadius: 40,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Glowing trophy icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [def.color, def.color.withOpacity(0.6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: def.color.withOpacity(0.5),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(def.icon, color: Colors.white, size: 36),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .shimmer(duration: 1200.ms, color: Colors.white.withOpacity(0.35))
                    .scale(
                      begin: const Offset(1.0, 1.0),
                      end: const Offset(1.06, 1.06),
                      duration: 800.ms,
                      curve: Curves.easeInOut,
                    ),
                const SizedBox(height: 20),
                // "Achievement Unlocked" badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: def.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: def.color.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(PhosphorIconsFill.trophy, color: def.color, size: 13),
                      const SizedBox(width: 5),
                      Text(
                        'ACHIEVEMENT UNLOCKED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: def.color,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  def.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  def.subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Tap anywhere to continue',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? Colors.white.withOpacity(0.3)
                        : Colors.black.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
