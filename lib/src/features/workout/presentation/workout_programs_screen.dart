import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:health_app/src/theme/app_colors.dart';
import 'package:health_app/src/theme/app_ui.dart';
import '../application/program_controller.dart';
import '../../../database/models/workout_program_doc.dart';
import '../../../database/models/workout_plan_doc.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class WorkoutProgramsScreen extends ConsumerWidget {
  const WorkoutProgramsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final programsAsync = ref.watch(allProgramsProvider);
    final activeAsync = ref.watch(activeProgramProvider);

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
                    color: isDark
                        ? Colors.white
                        : AppColors.lightTextPrimary,
                    size: 18),
              ),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: Icon(PhosphorIconsRegular.chartLineUp,
                    color: isDark
                        ? Colors.white70
                        : AppColors.lightTextSecondary,
                    size: 22),
                onPressed: () => context.push('/workout/progress'),
                tooltip: 'Strength Charts',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(56, 0, 16, 52),
              title: Text(
                'Programs',
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
        ],
        body: programsAsync.when(
          loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.softIndigo)),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (programs) {
            final active = activeAsync.valueOrNull;
            if (programs.isEmpty) {
              return _EmptyState(isDark: isDark);
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              itemCount: programs.length,
              itemBuilder: (_, i) {
                final program = programs[i];
                final isActive = active?.id == program.id;
                return _ProgramCard(
                  program: program,
                  isActive: isActive,
                  isDark: isDark,
                )
                    .animate(delay: Duration(milliseconds: 60 * i))
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.1, end: 0, duration: 400.ms);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/chat'),
        backgroundColor: AppColors.softIndigo,
        elevation: 8,
        icon: const Icon(PhosphorIconsFill.sparkle,
            color: Colors.white, size: 18),
        label: const Text('AI Program',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13)),
      ).animate().scale(delay: 400.ms, curve: Curves.easeOutBack),
    );
  }
}

// ── Program card ──────────────────────────────────────────────────────────────

class _ProgramCard extends ConsumerWidget {
  final WorkoutProgramDoc program;
  final bool isActive;
  final bool isDark;

  const _ProgramCard({
    required this.program,
    required this.isActive,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGym = program.mode == 'gym';
    final accent = isGym ? AppColors.softIndigo : AppColors.dynamicMint;
    final progress = program.weeksTotal > 0
        ? program.currentWeek / program.weeksTotal
        : 0.0;

    return AppAnimatedPressable(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push('/workout/program-detail', extra: program);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.charcoalGlass : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive
                ? accent.withValues(alpha: 0.5)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.04)),
            width: isActive ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: isActive ? 0.15 : 0.06),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [accent, accent.withValues(alpha: 0.6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                            color: accent.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3))
                      ],
                    ),
                    child: Icon(
                      isGym
                          ? PhosphorIconsFill.barbell
                          : PhosphorIconsFill.personSimpleRun,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                program.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.lightTextPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isActive)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.dynamicMint
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: AppColors.dynamicMint
                                          .withValues(alpha: 0.4)),
                                ),
                                child: const Text(
                                  'ACTIVE',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.dynamicMint,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          program.goal,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? Colors.white54
                                : AppColors.lightTextSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Week progress bar
              Row(
                children: [
                  Text(
                    'Week ${program.currentWeek} / ${program.weeksTotal}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white60 : AppColors.lightTextSecondary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${(progress * 100).round()}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.06),
                  valueColor: AlwaysStoppedAnimation<Color>(accent),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 14),

              // Chips row
              Row(
                children: [
                  _Chip(
                      label: '${program.weeksTotal} weeks',
                      color: accent),
                  const SizedBox(width: 6),
                  _Chip(label: isGym ? 'Gym' : 'Home', color: accent),
                  const SizedBox(width: 6),
                  _Chip(
                    label: program.isActive ? 'In Progress' : 'Saved',
                    color: program.isActive
                        ? AppColors.dynamicMint
                        : (isDark
                            ? Colors.white38
                            : AppColors.lightTextSecondary),
                  ),
                  const Spacer(),
                  // Arrow
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child:
                        Icon(PhosphorIconsRegular.arrowRight, color: accent, size: 16),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.softIndigo.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(PhosphorIconsFill.trophy,
                  size: 38, color: AppColors.softIndigo),
            ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 20),
            Text(
              'No programs yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.lightTextPrimary,
              ),
              textAlign: TextAlign.center,
            ).animate(delay: 100.ms).fadeIn(),
            const SizedBox(height: 8),
            Text(
              'Ask AI to create a multi-week training program tailored to your goals.',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: isDark
                    ? Colors.white38
                    : AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ).animate(delay: 180.ms).fadeIn(),
          ],
        ),
      ),
    );
  }
}

// ── Program detail screen ─────────────────────────────────────────────────────

class WorkoutProgramDetailScreen extends ConsumerStatefulWidget {
  final WorkoutProgramDoc program;
  const WorkoutProgramDetailScreen({super.key, required this.program});

  @override
  ConsumerState<WorkoutProgramDetailScreen> createState() =>
      _WorkoutProgramDetailScreenState();
}

class _WorkoutProgramDetailScreenState
    extends ConsumerState<WorkoutProgramDetailScreen> {
  bool _activating = false;
  bool _advancing = false;
  int _selectedWeek = 0; // 0-indexed

  @override
  void initState() {
    super.initState();
    _selectedWeek = (widget.program.currentWeek - 1).clamp(
        0, (widget.program.weeksTotal - 1).clamp(0, 999));
  }

  WorkoutProgramDoc get _program => widget.program;
  bool get isGym => _program.mode == 'gym';
  Color get accent => isGym ? AppColors.softIndigo : AppColors.dynamicMint;

  List<Map<String, dynamic>> _parseWeek(int weekIndex) {
    if (weekIndex >= _program.weeklyPlanJson.length) return [];
    try {
      final json = _program.weeklyPlanJson[weekIndex];
      final decoded = jsonDecode(json);
      if (decoded is List) {
        return decoded.map((d) => Map<String, dynamic>.from(d as Map)).toList();
      }
      if (decoded is Map && decoded['days'] is List) {
        return (decoded['days'] as List)
            .map((d) => Map<String, dynamic>.from(d as Map))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> _activateOrDeactivate() async {
    if (_activating) return;
    setState(() => _activating = true);
    try {
      if (_program.isActive) {
        await ref.read(programControllerProvider.notifier).deactivateAll();
      } else {
        await ref
            .read(programControllerProvider.notifier)
            .activateProgram(_program.id);
      }
    } finally {
      if (mounted) setState(() => _activating = false);
    }
  }

  Future<void> _advanceWeek() async {
    if (_advancing || !_program.isActive) return;
    setState(() => _advancing = true);
    try {
      await ref
          .read(programControllerProvider.notifier)
          .advanceWeek(_program.id);
      if (mounted) {
        setState(() {
          final nextWeek = _program.currentWeek; // already incremented in DB
          _selectedWeek =
              (nextWeek - 1).clamp(0, _program.weeksTotal - 1);
        });
      }
    } finally {
      if (mounted) setState(() => _advancing = false);
    }
  }

  void _startDayWorkout(Map<String, dynamic> day) {
    HapticFeedback.mediumImpact();
    final exercises = (day['exercises'] as List<dynamic>? ?? [])
        .map((e) => PlannedExercise()
          ..name = e['name'] as String? ?? ''
          ..sets = e['sets'] as int? ?? 3
          ..reps = e['reps'] as int? ?? 12
          ..restSeconds = e['rest_seconds'] as int? ?? 60
          ..notes = e['notes'] as String? ?? '')
        .toList();

    final plan = WorkoutPlanDoc()
      ..title = '${_program.name} — ${day['day'] ?? 'Workout'}'
      ..createdAt = DateTime.now()
      ..source = 'ai'
      ..mode = _program.mode
      ..exercises = exercises;

    context.push('/workout', extra: plan);
  }

  @override
  Widget build(BuildContext context) {
    final days = _parseWeek(_selectedWeek);
    final progress = _program.weeksTotal > 0
        ? _program.currentWeek / _program.weeksTotal
        : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFF07090F),
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF07090F),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(PhosphorIconsRegular.caretLeft,
                  color: Colors.white),
              onPressed: () => context.pop(),
            ),
            actions: [
              // Delete button
              IconButton(
                icon: const Icon(PhosphorIconsRegular.trash,
                    color: Colors.white54, size: 20),
                onPressed: () => _confirmDelete(context),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accent.withValues(alpha: 0.4),
                          const Color(0xFF07090F)
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Grid overlay
                  Opacity(
                    opacity: 0.03,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 12),
                      itemBuilder: (_, __) => Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.white, width: 0.2))),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 56, 24, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              _Badge(
                                  icon: isGym
                                      ? PhosphorIconsFill.barbell
                                      : PhosphorIconsFill.house,
                                  label: isGym ? 'GYM' : 'HOME',
                                  accent: accent),
                              const SizedBox(width: 8),
                              _Badge(
                                  icon: PhosphorIconsFill.calendar,
                                  label:
                                      '${_program.weeksTotal} WEEKS',
                                  accent: Colors.white38),
                              if (_program.isActive) ...[
                                const SizedBox(width: 8),
                                _Badge(
                                    icon: PhosphorIconsFill.lightning,
                                    label: 'ACTIVE',
                                    accent: AppColors.dynamicMint),
                              ],
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _program.name.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _program.goal,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.55),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (_program.aiSummary?.isNotEmpty == true) ...[
                            const SizedBox(height: 8),
                            Text(
                              _program.aiSummary!,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 12,
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 16),
                          // Progress bar
                          Row(
                            children: [
                              Text(
                                'Week ${_program.currentWeek} / ${_program.weeksTotal}',
                                style: const TextStyle(
                                    color: Colors.white54, fontSize: 11),
                              ),
                              const Spacer(),
                              Text(
                                '${(progress * 100).round()}% complete',
                                style: TextStyle(
                                    color: accent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress.clamp(0.0, 1.0),
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.1),
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(accent),
                              minHeight: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        body: Column(
          children: [
            // ── Week selector ────────────────────────────────────────────
            _WeekSelector(
              weeksTotal: _program.weeksTotal,
              selectedWeek: _selectedWeek,
              currentWeek: _program.currentWeek,
              accent: accent,
              onSelect: (w) => setState(() => _selectedWeek = w),
            ),
            // ── Day list ─────────────────────────────────────────────────
            Expanded(
              child: days.isEmpty
                  ? Center(
                      child: Text('No data for this week.',
                          style: TextStyle(
                              color: Colors.white38, fontSize: 13)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 140),
                      itemCount: days.length,
                      itemBuilder: (_, i) {
                        final day = days[i];
                        return _DayCard(
                          day: day,
                          accent: accent,
                          weekIndex: _selectedWeek,
                          currentWeek: _program.currentWeek,
                          onStart: () => _startDayWorkout(day),
                        )
                            .animate(
                                delay: Duration(milliseconds: 50 * i))
                            .fadeIn(duration: 350.ms)
                            .slideX(begin: 0.05);
                      },
                    ),
            ),
            // ── Bottom action bar ─────────────────────────────────────────
            _BottomBar(
              isActive: _program.isActive,
              isGym: isGym,
              accent: accent,
              activating: _activating,
              advancing: _advancing,
              canAdvance: _program.isActive &&
                  _program.currentWeek < _program.weeksTotal,
              onActivate: _activateOrDeactivate,
              onAdvance: _advanceWeek,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF12151E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Program?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        content: const Text(
          'This will permanently delete the program and all its data.',
          style: TextStyle(color: Colors.white54),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.white54))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete',
                  style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref
          .read(programControllerProvider.notifier)
          .deleteProgram(_program.id);
      if (mounted) context.pop();
    }
  }
}

// ── Week selector row ─────────────────────────────────────────────────────────

class _WeekSelector extends StatelessWidget {
  final int weeksTotal;
  final int selectedWeek;
  final int currentWeek;
  final Color accent;
  final ValueChanged<int> onSelect;

  const _WeekSelector({
    required this.weeksTotal,
    required this.selectedWeek,
    required this.currentWeek,
    required this.accent,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF07090F),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: weeksTotal,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final active = i == selectedWeek;
            final isCurrent = i + 1 == currentWeek;
            return AppAnimatedPressable(
              onTap: () => onSelect(i),
              child: AnimatedContainer(
                duration: 200.ms,
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: active
                      ? accent
                      : Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isCurrent && !active
                        ? accent.withValues(alpha: 0.5)
                        : Colors.transparent,
                  ),
                ),
                child: Text(
                  'W${i + 1}',
                  style: TextStyle(
                    color: active ? Colors.white : Colors.white54,
                    fontSize: 12,
                    fontWeight:
                        active ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Day card ──────────────────────────────────────────────────────────────────

class _DayCard extends StatefulWidget {
  final Map<String, dynamic> day;
  final Color accent;
  final int weekIndex;
  final int currentWeek;
  final VoidCallback onStart;

  const _DayCard({
    required this.day,
    required this.accent,
    required this.weekIndex,
    required this.currentWeek,
    required this.onStart,
  });

  @override
  State<_DayCard> createState() => _DayCardState();
}

class _DayCardState extends State<_DayCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final dayName = widget.day['day'] as String? ?? 'Day';
    final exercises =
        widget.day['exercises'] as List<dynamic>? ?? [];
    final focus = widget.day['focus'] as String?;

    return AppAnimatedPressable(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _expanded = !_expanded);
      },
      child: AnimatedContainer(
        duration: 250.ms,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: _expanded ? 0.07 : 0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _expanded
                ? widget.accent.withValues(alpha: 0.35)
                : Colors.white.withValues(alpha: 0.06),
            width: _expanded ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Day number circle
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: widget.accent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: widget.accent.withValues(alpha: 0.4)),
                    ),
                    child: Center(
                      child: Text(
                        _extractDayNum(dayName),
                        style: TextStyle(
                          color: widget.accent,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (focus != null || exercises.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            focus ?? '${exercises.length} exercises',
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 11),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Start button
                    AppAnimatedPressable(
                      onTap: () {
                        widget.onStart();
                      },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: widget.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color:
                                widget.accent.withValues(alpha: 0.3)),
                      ),
                      child: Icon(PhosphorIconsFill.play,
                          color: widget.accent, size: 16),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _expanded
                        ? PhosphorIconsRegular.caretUp
                        : PhosphorIconsRegular.caretDown,
                    color: Colors.white24,
                    size: 16,
                  ),
                ],
              ),
            ),
            if (_expanded && exercises.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.08)),
                    const SizedBox(height: 12),
                    ...exercises.map((e) {
                      final name = e['name'] as String? ?? '';
                      final sets = e['sets'] as int? ?? 0;
                      final reps = e['reps'] as int? ?? 0;
                      final rest = e['rest_seconds'] as int? ?? 0;
                      return Padding(
                        padding:
                            const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: widget.accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                name,
                                style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    fontWeight:
                                        FontWeight.w600),
                              ),
                            ),
                            Text(
                              '$sets×$reps',
                              style: TextStyle(
                                color: widget.accent,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${rest}s',
                              style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 11),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _extractDayNum(String dayName) {
    final match = RegExp(r'\d+').firstMatch(dayName);
    return match?.group(0) ?? 'D';
  }
}

// ── Bottom action bar ─────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final bool isActive;
  final bool isGym;
  final Color accent;
  final bool activating;
  final bool advancing;
  final bool canAdvance;
  final VoidCallback onActivate;
  final VoidCallback onAdvance;

  const _BottomBar({
    required this.isActive,
    required this.isGym,
    required this.accent,
    required this.activating,
    required this.advancing,
    required this.canAdvance,
    required this.onActivate,
    required this.onAdvance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 14, 20, 14 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: const Color(0xFF07090F).withValues(alpha: 0.95),
        border: Border(
            top: BorderSide(
                color: Colors.white.withValues(alpha: 0.07))),
      ),
      child: Row(
        children: [
          // Activate / Deactivate
          Expanded(
            child: AppAnimatedPressable(
              onTap: activating ? null : onActivate,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: isActive
                      ? null
                      : LinearGradient(colors: [accent, accent.withValues(alpha: 0.7)]),
                  color: isActive
                      ? Colors.white.withValues(alpha: 0.06)
                      : null,
                  borderRadius: BorderRadius.circular(16),
                  border: isActive
                      ? Border.all(
                          color: Colors.white.withValues(alpha: 0.1))
                      : null,
                  boxShadow: isActive
                      ? null
                      : [
                          BoxShadow(
                              color: accent.withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6))
                        ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (activating)
                      const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                    else
                      Icon(
                        isActive
                            ? PhosphorIconsRegular.pause
                            : PhosphorIconsFill.lightning,
                        color:
                            isActive ? Colors.white54 : Colors.black,
                        size: 18,
                      ),
                    const SizedBox(width: 8),
                    Text(
                      isActive ? 'Deactivate' : 'Activate',
                      style: TextStyle(
                        color: isActive
                            ? Colors.white54
                            : Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (canAdvance) ...[
            const SizedBox(width: 12),
            AppAnimatedPressable(
              onTap: advancing ? null : onAdvance,
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (advancing)
                      const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.warning))
                    else
                      const Icon(PhosphorIconsRegular.arrowRight,
                          color: AppColors.warning, size: 18),
                    const SizedBox(width: 6),
                    const Text(
                      'Next Week',
                      style: TextStyle(
                        color: AppColors.warning,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accent;
  const _Badge(
      {required this.icon, required this.label, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: accent, size: 11),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
                color: accent,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8),
          ),
        ],
      ),
    );
  }
}
