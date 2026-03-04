import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:health_app/src/theme/app_colors.dart';
import 'package:health_app/src/theme/app_ui.dart';
import '../application/meal_plan_notifier.dart';
import '../application/nutrition_targets_provider.dart';
import '../domain/meal_plan_model.dart';

class MealPlannerScreen extends ConsumerStatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  ConsumerState<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends ConsumerState<MealPlannerScreen>
    with SingleTickerProviderStateMixin {
  int _selectedDayIndex = 0;
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final planState = ref.watch(mealPlanNotifierProvider);
    final targets = ref.watch(nutritionTargetsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.deepObsidian : const Color(0xFFF7F8FC),
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            pinned: true,
            expandedHeight: 60,
            backgroundColor: isDark ? AppColors.deepObsidian : Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
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
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go('/nutrition-tab'),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(56, 0, 16, 14),
              title: Text(
                'AI Meal Planner',
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            actions: [
              if (planState.activePlan != null)
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(PhosphorIconsRegular.trash,
                        color: AppColors.danger, size: 16),
                  ),
                  onPressed: () => _confirmDiscard(context, isDark),
                ),
              const SizedBox(width: 8),
            ],
          ),
        ],
        body: planState.status == MealPlanStatus.generating
            ? _GeneratingView(isDark: isDark)
            : planState.activePlan == null
                ? _EmptyPlanView(
                    isDark: isDark,
                    targets: targets,
                    onGenerate: (days) => ref
                        .read(mealPlanNotifierProvider.notifier)
                        .generatePlan(durationDays: days),
                  )
                : _ActivePlanView(
                    isDark: isDark,
                    planState: planState,
                    selectedDayIndex: _selectedDayIndex,
                    onDaySelected: (i) => setState(() => _selectedDayIndex = i),
                    targets: targets,
                  ),
      ),
    );
  }

  void _confirmDiscard(BuildContext context, bool isDark) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.charcoalCard : Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(PhosphorIconsFill.trash,
                    color: AppColors.danger, size: 28),
              ),
              const SizedBox(height: 16),
              Text('Discard Meal Plan?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                  )),
              const SizedBox(height: 8),
              Text(
                'Your current plan will be removed. You can generate a new one anytime.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white54 : Colors.black45),
              ),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      side: BorderSide(
                          color: isDark
                              ? Colors.white24
                              : Colors.black12),
                    ),
                    child: Text('Cancel',
                        style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ref
                          .read(mealPlanNotifierProvider.notifier)
                          .discardActivePlan();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Discard',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Generating shimmer view ────────────────────────────────────────────────────

class _GeneratingView extends StatelessWidget {
  final bool isDark;
  const _GeneratingView({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.dynamicMint, AppColors.softIndigo],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.dynamicMint.withValues(alpha: 0.3),
                    blurRadius: 30,
                    spreadRadius: 4,
                  )
                ],
              ),
              child: const Icon(PhosphorIconsFill.sparkle,
                  color: Colors.white, size: 44),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(begin: 0.92, end: 1.0, duration: 1000.ms),
            const SizedBox(height: 28),
            Text(
              'Crafting your plan...',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.lightTextPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'AI is personalising meals based on\nyour goals and dietary preferences',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white54 : Colors.black45,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            _DotsLoader(isDark: isDark),
          ],
        ),
      ),
    );
  }
}

class _DotsLoader extends StatelessWidget {
  final bool isDark;
  const _DotsLoader({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        3,
        (i) => Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: AppColors.dynamicMint,
            shape: BoxShape.circle,
          ),
        )
            .animate(
              delay: Duration(milliseconds: i * 200),
              onPlay: (c) => c.repeat(reverse: true),
            )
            .scaleXY(begin: 0.4, end: 1.0, duration: 600.ms),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────

class _EmptyPlanView extends StatelessWidget {
  final bool isDark;
  final dynamic targets;
  final void Function(int days) onGenerate;

  const _EmptyPlanView({
    required this.isDark,
    required this.targets,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0E2820), Color(0xFF0A1F18)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                  color: AppColors.dynamicMint.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.dynamicMint.withValues(alpha: 0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.dynamicMint.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(PhosphorIconsFill.sparkle,
                          color: AppColors.dynamicMint, size: 24),
                    ),
                    const SizedBox(width: 14),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('AI DIET PLANNER',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                              color: AppColors.dynamicMint,
                            )),
                        Text('Personalised for You',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            )),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Get a meal plan tailored to your\ncalorie targets, macro goals,\nand dietary preferences.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _TargetBadge(label: '${targets.calories}', unit: 'kcal/day'),
                    const SizedBox(width: 8),
                    _TargetBadge(label: '${targets.proteinG}g', unit: 'protein'),
                    const SizedBox(width: 8),
                    _TargetBadge(label: '${targets.carbsG}g', unit: 'carbs'),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05),

          const SizedBox(height: 28),

          Text('Choose a Plan Duration',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.lightTextPrimary,
              )).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 14),

          // Plan type cards
          _PlanTypeCard(
            title: 'Daily Plan',
            subtitle: 'One perfect day of meals',
            icon: PhosphorIconsFill.sun,
            gradient: const LinearGradient(
              colors: [Color(0xFFF59E0B), Color(0xFFEF7B06)],
            ),
            features: const [
              'Breakfast, Lunch, Dinner + Snack',
              'Hits your calorie target exactly',
              'Instant generation',
            ],
            onTap: () {
              HapticFeedback.mediumImpact();
              onGenerate(1);
            },
            isDark: isDark,
          ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.05),

          const SizedBox(height: 14),

          _PlanTypeCard(
            title: '7-Day Plan',
            subtitle: 'A full week of varied meals',
            icon: PhosphorIconsFill.calendarDots,
            gradient: const LinearGradient(
              colors: [AppColors.dynamicMint, AppColors.mintDark],
            ),
            features: const [
              'No meal repeated on consecutive days',
              'Weekly variety for sustained results',
              'Adopt any day into your log',
            ],
            onTap: () {
              HapticFeedback.mediumImpact();
              onGenerate(7);
            },
            isDark: isDark,
            highlighted: true,
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05),

          const SizedBox(height: 28),

          // Feature list
          _FeatureRow(
              icon: PhosphorIconsFill.target,
              title: 'Goal-aligned macros',
              subtitle: 'Protein, carbs & fat tuned to your goal',
              isDark: isDark),
          const SizedBox(height: 12),
          _FeatureRow(
              icon: PhosphorIconsFill.leaf,
              title: 'Dietary preferences respected',
              subtitle: 'Vegan, keto, gluten-free & more',
              isDark: isDark),
          const SizedBox(height: 12),
          _FeatureRow(
              icon: PhosphorIconsFill.lightning,
              title: 'One-tap meal adoption',
              subtitle: 'Log meals directly from your plan',
              isDark: isDark),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _TargetBadge extends StatelessWidget {
  final String label;
  final String unit;
  const _TargetBadge({required this.label, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.dynamicMint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.dynamicMint.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.dynamicMint,
              )),
          Text(unit,
              style: const TextStyle(
                fontSize: 9,
                color: Colors.white54,
                fontWeight: FontWeight.w500,
              )),
        ],
      ),
    );
  }
}

class _PlanTypeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final List<String> features;
  final VoidCallback onTap;
  final bool isDark;
  final bool highlighted;

  const _PlanTypeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.features,
    required this.onTap,
    required this.isDark,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppAnimatedPressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.charcoalCard : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: highlighted
                ? AppColors.dynamicMint.withValues(alpha: 0.4)
                : isDark
                    ? Colors.white.withValues(alpha: 0.07)
                    : Colors.black.withValues(alpha: 0.05),
            width: highlighted ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: highlighted
                  ? AppColors.dynamicMint.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: isDark ? 0 : 0.03),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: (gradient as LinearGradient)
                        .colors
                        .first
                        .withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : AppColors.lightTextPrimary,
                          )),
                      if (highlighted) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.dynamicMint,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('RECOMMENDED',
                              style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : Colors.black45)),
                  const SizedBox(height: 8),
                  ...features.map((f) => Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Row(
                          children: [
                            Icon(PhosphorIconsFill.checkCircle,
                                size: 12,
                                color: (gradient as LinearGradient).colors.first),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(f,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? Colors.white60
                                        : Colors.black54,
                                  )),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            Icon(PhosphorIconsRegular.caretRight,
                color: isDark ? Colors.white30 : Colors.black26, size: 18),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.dynamicMint.withValues(alpha: isDark ? 0.12 : 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.dynamicMint, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                  )),
              Text(subtitle,
                  style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.black45)),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Active plan view ───────────────────────────────────────────────────────────

class _ActivePlanView extends ConsumerWidget {
  final bool isDark;
  final MealPlanState planState;
  final int selectedDayIndex;
  final void Function(int) onDaySelected;
  final dynamic targets;

  const _ActivePlanView({
    required this.isDark,
    required this.planState,
    required this.selectedDayIndex,
    required this.onDaySelected,
    required this.targets,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = planState.activePlanModel;
    if (plan == null) return const SizedBox.shrink();

    final days = plan.days;
    final selectedDay =
        days.isNotEmpty && selectedDayIndex < days.length
            ? days[selectedDayIndex]
            : null;

    return CustomScrollView(
      slivers: [
        // ── Plan summary header ──────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0E2820), Color(0xFF0A1F18)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: AppColors.dynamicMint.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.dynamicMint.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(PhosphorIconsFill.sparkle,
                        color: AppColors.dynamicMint, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(plan.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            )),
                        Text(
                          '${days.length} days  ·  ${plan.dailyCalories} kcal/day',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                  // Regenerate
                  AppAnimatedPressable(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      ref.read(mealPlanNotifierProvider.notifier).generatePlan(
                            durationDays: planState.activePlan!.durationDays,
                          );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.dynamicMint.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color:
                                AppColors.dynamicMint.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(PhosphorIconsRegular.arrowsClockwise,
                              color: AppColors.dynamicMint, size: 13),
                          SizedBox(width: 5),
                          Text('Refresh',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.dynamicMint,
                              )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),
          ),
        ),

        // ── Day tabs ─────────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 0, 0),
            child: SizedBox(
              height: 54,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: days.length,
                itemBuilder: (_, i) {
                  final selected = i == selectedDayIndex;
                  return AppAnimatedPressable(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onDaySelected(i);
                    },
                    child: AnimatedContainer(
                      duration: 200.ms,
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.dynamicMint
                            : isDark
                                ? Colors.white.withValues(alpha: 0.07)
                                : Colors.black.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: AppColors.dynamicMint
                                      .withValues(alpha: 0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : [],
                      ),
                      child: Text(
                        days[i].day,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: selected
                              ? Colors.white
                              : isDark
                                  ? Colors.white60
                                  : Colors.black54,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        // ── Selected day meals ────────────────────────────────────────────────
        if (selectedDay != null) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Text(selectedDay.day,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.lightTextPrimary,
                      )),
                  const Spacer(),
                  // Adopt full day
                  AppAnimatedPressable(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      ref
                          .read(mealPlanNotifierProvider.notifier)
                          .adoptDay(selectedDayIndex);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'All meals from ${selectedDay.day} added to today\'s log'),
                          backgroundColor: AppColors.dynamicMint,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.dynamicMint,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.dynamicMint.withValues(alpha: 0.35),
                            blurRadius: 10,
                          )
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(PhosphorIconsFill.lightning,
                              color: Colors.white, size: 13),
                          SizedBox(width: 5),
                          Text('Log Full Day',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Day nutrition summary bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: _DayNutritionSummary(
                  day: selectedDay, isDark: isDark),
            ),
          ),

          // Meal items
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) {
                final meal = selectedDay.meals[i];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: _MealPlanItemCard(
                    meal: meal,
                    isDark: isDark,
                    onAdopt: () {
                      HapticFeedback.lightImpact();
                      ref
                          .read(mealPlanNotifierProvider.notifier)
                          .adoptMeal(meal);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${meal.name} added to today\'s log'),
                          backgroundColor: AppColors.dynamicMint,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      );
                    },
                  ).animate(delay: Duration(milliseconds: 60 * i))
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: 0.05),
                );
              },
              childCount: selectedDay.meals.length,
            ),
          ),
        ],

        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }
}

// ── Day nutrition summary ─────────────────────────────────────────────────────

class _DayNutritionSummary extends StatelessWidget {
  final MealPlanDay day;
  final bool isDark;
  const _DayNutritionSummary({required this.day, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final totalCal = day.meals.fold(0, (s, m) => s + m.calories);
    final totalProtein = day.meals.fold(0, (s, m) => s + m.protein);
    final totalCarbs = day.meals.fold(0, (s, m) => s + m.carbs);
    final totalFat = day.meals.fold(0, (s, m) => s + m.fat);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.charcoalCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NutrientBadge(
              label: 'Calories',
              value: '$totalCal',
              unit: 'kcal',
              color: AppColors.dynamicMint),
          _NutrientBadge(
              label: 'Protein',
              value: '${totalProtein}g',
              unit: 'protein',
              color: AppColors.danger),
          _NutrientBadge(
              label: 'Carbs',
              value: '${totalCarbs}g',
              unit: 'carbs',
              color: AppColors.warning),
          _NutrientBadge(
              label: 'Fat',
              value: '${totalFat}g',
              unit: 'fat',
              color: AppColors.softIndigo),
        ],
      ),
    );
  }
}

class _NutrientBadge extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _NutrientBadge({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        Text(unit,
            style: TextStyle(
                fontSize: 10,
                color: color.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// ── Meal plan item card ────────────────────────────────────────────────────────

class _MealPlanItemCard extends StatelessWidget {
  final MealPlanItem meal;
  final bool isDark;
  final VoidCallback onAdopt;

  const _MealPlanItemCard({
    required this.meal,
    required this.isDark,
    required this.onAdopt,
  });

  Color get _typeColor {
    switch (meal.type.toLowerCase()) {
      case 'breakfast': return const Color(0xFFF59E0B);
      case 'lunch': return AppColors.dynamicMint;
      case 'dinner': return AppColors.softIndigo;
      default: return AppColors.danger;
    }
  }

  IconData get _typeIcon {
    switch (meal.type.toLowerCase()) {
      case 'breakfast': return PhosphorIconsFill.coffee;
      case 'lunch': return PhosphorIconsFill.sun;
      case 'dinner': return PhosphorIconsFill.moon;
      default: return PhosphorIconsFill.cookingPot;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.charcoalCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
        ),
        boxShadow: [
          BoxShadow(
            color: _typeColor.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _typeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_typeIcon, color: _typeColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: _typeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        meal.type.toUpperCase(),
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: _typeColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  meal.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${meal.protein}g P  ·  ${meal.carbs}g C  ·  ${meal.fat}g F',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${meal.calories}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _typeColor,
                  )),
              Text('kcal',
                  style: TextStyle(
                    fontSize: 9,
                    color: isDark ? Colors.white38 : Colors.black38,
                  )),
              const SizedBox(height: 8),
              AppAnimatedPressable(
                onTap: onAdopt,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.dynamicMint.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.dynamicMint.withValues(alpha: 0.3)),
                  ),
                  child: const Text('+ Log',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.dynamicMint,
                      )),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
