import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:health_app/src/theme/app_colors.dart';
import 'package:health_app/src/theme/app_ui.dart';

import '../domain/workout_plan_model.dart';
import '../domain/exercise_model.dart';
import '../application/exercise_db_provider.dart';
import '../application/workout_plan_controller.dart';
import '../../../database/models/workout_plan_doc.dart';
import 'widgets/wger_exercise_widget.dart';

class WorkoutPlanPreviewScreen extends ConsumerStatefulWidget {
  final WorkoutPlanData? planData;
  final WorkoutPlanDoc? planDoc;

  const WorkoutPlanPreviewScreen({super.key, this.planData, this.planDoc})
      : assert(planData != null || planDoc != null);

  @override
  ConsumerState<WorkoutPlanPreviewScreen> createState() =>
      _WorkoutPlanPreviewScreenState();
}

class _WorkoutPlanPreviewScreenState
    extends ConsumerState<WorkoutPlanPreviewScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _saved = false;
  bool _saving = false;
  bool _isFav = false;
  WorkoutPlanDoc? _savedDoc;

  late String _title;
  late String _mode;
  late String? _summary;
  late List<WorkoutDayData> _days;

  @override
  void initState() {
    super.initState();
    _resolvePlan();
    _tabController = TabController(length: _days.length.clamp(1, 7), vsync: this);

    if (widget.planDoc != null) {
      _saved = true;
      _savedDoc = widget.planDoc;
      _isFav = widget.planDoc!.isFavourite;
    }
  }

  void _resolvePlan() {
    if (widget.planData != null) {
      final d = widget.planData!;
      _title = d.title;
      _mode = d.mode;
      _summary = d.aiSummary;
      _days = d.days;
    } else {
      final doc = widget.planDoc!;
      _title = doc.title;
      _mode = doc.mode;
      _summary = doc.aiSummary;
      _days = [
        WorkoutDayData(
          dayLabel: doc.title,
          exercises: doc.exercises
              .map((e) => PlannedExerciseData(
                    name: e.name,
                    sets: e.sets,
                    reps: e.reps,
                    restSeconds: e.restSeconds,
                    notes: e.notes.isNotEmpty ? e.notes : null,
                  ))
              .toList(),
        ),
      ];
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool get isGym => _mode == 'gym';
  Color get accent => isGym ? AppColors.softIndigo : AppColors.dynamicMint;

  Future<void> _savePlan() async {
    if (_saved || _saving) return;
    HapticFeedback.mediumImpact();
    setState(() => _saving = true);
    try {
      WorkoutPlanDoc doc;
      if (widget.planData != null) {
        doc = await ref.read(workoutPlanControllerProvider.notifier).savePlan(widget.planData!);
      } else {
        doc = await ref.read(workoutPlanControllerProvider.notifier).savePlanDoc(widget.planDoc!);
      }
      if (mounted) setState(() { _saving = false; _saved = true; _savedDoc = doc; });
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _toggleFav() async {
    HapticFeedback.lightImpact();
    if (!_saved) await _savePlan();
    final doc = _savedDoc;
    if (doc == null) return;
    await ref.read(workoutPlanControllerProvider.notifier).toggleFavourite(doc.id);
    if (mounted) setState(() => _isFav = !_isFav);
  }

  void _startWorkout() {
    HapticFeedback.heavyImpact();
    WorkoutPlanDoc docToPlay;
    if (_savedDoc != null) {
      docToPlay = _savedDoc!;
    } else if (widget.planData != null) {
      docToPlay = widget.planData!.toPlanDoc(dayIndex: _tabController.index);
    } else {
      docToPlay = widget.planDoc!;
    }
    context.push('/workout', extra: docToPlay);
  }

  @override
  Widget build(BuildContext context) {
    final exerciseDb = ref.watch(exerciseDbProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF07090F),
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [_buildSliverAppBar()],
        body: Column(
          children: [
            if (_days.length > 1) _buildTabBar(),
            Expanded(
              child: _days.length > 1
                  ? TabBarView(
                      controller: _tabController,
                      children: _days.map((day) => _buildDayView(day, exerciseDb)).toList(),
                    )
                  : _buildDayView(_days.first, exerciseDb),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      backgroundColor: const Color(0xFF07090F),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(PhosphorIconsRegular.caretLeft, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: Icon(_isFav ? PhosphorIconsFill.heart : PhosphorIconsRegular.heart, color: _isFav ? Colors.pinkAccent : Colors.white),
          onPressed: _toggleFav,
        ),
        IconButton(
          icon: Icon(_saved ? PhosphorIconsFill.checkCircle : PhosphorIconsRegular.floppyDisk, color: _saved ? AppColors.dynamicMint : Colors.white),
          onPressed: _saved ? null : _savePlan,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accent.withValues(alpha: 0.4), const Color(0xFF07090F)],
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                ),
              ),
            ),
            Opacity(
              opacity: 0.03,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 12),
                itemBuilder: (_, __) => Container(decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 0.2))),
              ),
            ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        _ModeBadge(mode: _mode, accent: accent),
                        const SizedBox(width: 8),
                        _InfoBadge(icon: PhosphorIconsFill.calendarBlank, label: '${_days.length} DAYS'),
                        const SizedBox(width: 8),
                        _InfoBadge(icon: PhosphorIconsFill.barbell, label: '${_days.expand((d) => d.exercises).length} EXS'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _title.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1.0, height: 1.0),
                    ),
                    if (_summary != null && _summary!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        _summary!,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13, height: 1.4, fontWeight: FontWeight.w500),
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: const Color(0xFF07090F),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicatorColor: accent,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white24,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1),
        unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        tabs: _days.map((d) => Tab(text: d.dayLabel.split(' - ').last.toUpperCase())).toList(),
      ),
    );
  }

  Widget _buildDayView(WorkoutDayData day, AsyncValue<List<ExerciseModel>> dbAsync) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      physics: scrollPhysics,
      itemCount: day.exercises.length,
      itemBuilder: (context, index) {
        final ex = day.exercises[index];
        final matched = dbAsync.whenOrNull(
          data: (db) {
            final lower = ex.name.toLowerCase();
            try {
              return db.firstWhere((e) => e.name.toLowerCase().contains(lower) || lower.contains(e.name.toLowerCase()));
            } catch (_) { return null; }
          },
        );
        return _ExerciseCard(index: index + 1, exercise: ex, matched: matched, mode: _mode, accent: accent)
            .animate().fadeIn(delay: Duration(milliseconds: index * 40)).slideX(begin: 0.05);
      },
    );
  }

  Widget _buildBottomBar() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + MediaQuery.of(context).padding.bottom),
          decoration: BoxDecoration(
            color: const Color(0xFF07090F).withValues(alpha: 0.8),
            border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
          ),
          child: Row(
            children: [
              if (!_saved)
                Expanded(
                  child: _BottomButton(
                    icon: _saving ? PhosphorIconsRegular.arrowClockwise : PhosphorIconsRegular.floppyDisk,
                    label: _saving ? 'SAVING' : 'SAVE PLAN',
                    color: Colors.white70, filled: false, onTap: _savePlan,
                  ),
                ),
              if (!_saved) const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _BottomButton(
                  icon: PhosphorIconsFill.play,
                  label: 'START WORKOUT',
                  color: Colors.black,
                  filled: true,
                  fillGradient: LinearGradient(
                    colors: isGym ? [AppColors.softIndigo, const Color(0xFF8B5CF6)] : [AppColors.dynamicMint, const Color(0xFF06B6D4)],
                  ),
                  onTap: _startWorkout,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatefulWidget {
  final int index;
  final PlannedExerciseData exercise;
  final ExerciseModel? matched;
  final String mode;
  final Color accent;

  const _ExerciseCard({required this.index, required this.exercise, required this.matched, required this.mode, required this.accent});

  @override
  State<_ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<_ExerciseCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;
    final matched = widget.matched;

    return AppAnimatedPressable(
      onTap: () { HapticFeedback.selectionClick(); setState(() => _expanded = !_expanded); },
      child: AnimatedContainer(
        duration: 300.ms,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: _expanded ? 0.08 : 0.04),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _expanded ? widget.accent.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.05), width: _expanded ? 2 : 1),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        width: 64, height: 64,
                        child: WgerExerciseWidget(
                          exerciseName: ex.name,
                          accentColor: widget.accent,
                          height: 64,
                        ),
                      ),
                    ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ex.name.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: -0.2), maxLines: 2),
                        const SizedBox(height: 6),
                        Row(children: [_StatPill('${ex.sets} SETS', widget.accent), const SizedBox(width: 6), _StatPill('${ex.reps} REPS', Colors.white30)]),
                      ],
                    ),
                  ),
                  Icon(_expanded ? PhosphorIconsRegular.caretUp : PhosphorIconsRegular.caretDown, color: Colors.white24, size: 18),
                ],
              ),
            ),
            if (_expanded)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Divider(height: 1, color: Colors.white.withValues(alpha: 0.1)),
                  _buildVisualContent(matched?.gifUrl, matched),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (ex.notes != null && ex.notes!.isNotEmpty) ...[
                          Row(children: [Icon(PhosphorIconsFill.notepad, color: widget.accent, size: 14), const SizedBox(width: 8), const Text('COACH NOTES', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1))]),
                          const SizedBox(height: 6),
                          Text(ex.notes!, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13, height: 1.5)),
                          const SizedBox(height: 20),
                        ],
                        const Text('TARGET MUSCLES', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8, runSpacing: 8,
                          children: matched != null 
                            ? [...matched.primaryMuscles.map((m) => _MusclePill(label: m, color: widget.accent)), ...matched.secondaryMuscles.take(3).map((m) => _MusclePill(label: m, color: Colors.white12))]
                            : [_MusclePill(label: 'General Strength', color: widget.accent)],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

    Widget _buildVisualContent(String? gifUrl, ExerciseModel? matched) {
      return SizedBox(
        height: 220,
        child: WgerExerciseWidget(
          exerciseName: widget.exercise.name,
          accentColor: widget.accent,
          height: 220,
          showAttribution: true,
        ),
      );
    }
}

class _StatPill extends StatelessWidget {
  final String label;
  final Color color;
  const _StatPill(this.label, this.color);
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)));
  }
}

class _MusclePill extends StatelessWidget {
  final String label;
  final Color color;
  const _MusclePill({required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withValues(alpha: 0.1))), child: Text(label.toUpperCase(), style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5)));
  }
}

class _ModeBadge extends StatelessWidget {
  final String mode;
  final Color accent;
  const _ModeBadge({required this.mode, required this.accent});
  @override
  Widget build(BuildContext context) {
    final isGym = mode == 'gym';
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8), border: Border.all(color: accent.withValues(alpha: 0.3))), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(isGym ? PhosphorIconsFill.barbell : PhosphorIconsFill.house, color: accent, size: 12), const SizedBox(width: 6), Text(isGym ? 'GYM' : 'HOME', style: TextStyle(color: accent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1))]));
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoBadge({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: Colors.white54, size: 12), const SizedBox(width: 6), Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w800))]));
  }
}

class _BottomButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool filled;
  final LinearGradient? fillGradient;
  final VoidCallback onTap;
  const _BottomButton({required this.icon, required this.label, required this.color, required this.filled, required this.onTap, this.fillGradient});

  @override
  Widget build(BuildContext context) {
    return AppAnimatedPressable(
      onTap: onTap,
      child: Container(
        height: 58,
        decoration: BoxDecoration(gradient: filled ? fillGradient : null, color: filled ? null : Colors.white.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(20), border: filled ? null : Border.all(color: Colors.white.withValues(alpha: 0.1)), boxShadow: filled && fillGradient != null ? [BoxShadow(color: fillGradient!.colors.first.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))] : null),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: color, size: 20), const SizedBox(width: 10), Text(label, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1))]),
      ),
    );
  }
}
