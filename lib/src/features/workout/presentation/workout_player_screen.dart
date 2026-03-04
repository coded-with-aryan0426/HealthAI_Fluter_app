import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:health_app/src/theme/app_colors.dart';
import 'package:health_app/src/theme/app_ui.dart';
import 'package:health_app/src/database/models/workout_plan_doc.dart';
import 'package:health_app/src/database/models/workout_doc.dart';
import '../application/workout_controller.dart';
import '../application/exercise_db_provider.dart';
import '../domain/exercise_model.dart';
import '../domain/workout_session_data.dart';
import '../../../services/local_db_service.dart';
import 'package:isar/isar.dart';
import 'widgets/wger_exercise_widget.dart';

export '../domain/workout_session_data.dart';

class WorkoutPlayerScreen extends ConsumerStatefulWidget {
  final WorkoutPlanDoc? planDoc;
  const WorkoutPlayerScreen({super.key, this.planDoc});

  @override
  ConsumerState<WorkoutPlayerScreen> createState() =>
      _WorkoutPlayerScreenState();
}

class _WorkoutPlayerScreenState extends ConsumerState<WorkoutPlayerScreen>
    with TickerProviderStateMixin {

  // ── Timers ──────────────────────────────────────────────────────────────────
  int _elapsedSeconds = 0;
  Timer? _workoutTimer;

  bool _isResting = false;
  int _restSeconds = 60;
  int _restTotal = 60;
  Timer? _restTimer;

  // ── State ───────────────────────────────────────────────────────────────────
  int _currentExIndex = 0;
  List<ExerciseState> _exStates = [];

  /// Last-session ghost data: exercise name → list of (weightKg, reps) per set
  Map<String, List<SetLog>> _lastSessionGhosts = {};

  /// All-time PR per exercise name (max weightKg × reps volume)
  Map<String, double> _allTimePrVolume = {};

  @override
  void initState() {
    super.initState();
    _workoutTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isResting && mounted) setState(() => _elapsedSeconds++);
    });
    _initExercises();
    _loadHistoricalData();
  }

  /// Loads the most recent same-title session for ghost text,
  /// and all-time best per exercise for PR detection.
  void _loadHistoricalData() {
    final planTitle = widget.planDoc?.title;
    if (planTitle == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final isar = ref.read(isarProvider);

        // Last session with the same plan title (skip the very first one)
        final recentSessions = isar.workoutDocs
            .where()
            .sortByDateDesc()
            .limit(100)
            .findAllSync();

        // Find the most recent finished session with matching title
        WorkoutDoc? lastSession;
        for (final doc in recentSessions) {
          if (doc.title == planTitle && doc.durationSeconds > 0) {
            lastSession = doc;
            break;
          }
        }

        if (lastSession != null) {
          final ghosts = <String, List<SetLog>>{};
          for (final ex in lastSession.exercises) {
            ghosts[ex.name.toLowerCase()] = ex.sets
                .map((s) => SetLog(weightKg: s.weightKg, reps: s.reps))
                .toList();
          }
          if (mounted) setState(() => _lastSessionGhosts = ghosts);
        }

        // All-time best: scan all sessions for each exercise
        final allTimePr = <String, double>{};
        for (final doc in recentSessions) {
          for (final ex in doc.exercises) {
            final key = ex.name.toLowerCase();
            for (final s in ex.sets) {
              if (s.completed && s.weightKg > 0) {
                final vol = s.weightKg;
                if ((allTimePr[key] ?? 0) < vol) allTimePr[key] = vol;
              }
            }
          }
        }
        if (mounted) setState(() => _allTimePrVolume = allTimePr);
      } catch (_) {}
    });
  }

  /// Returns ghost SetLog for a given exercise + set index (null if none).
  SetLog? _ghostFor(String exerciseName, int setIndex) {
    final ghosts = _lastSessionGhosts[exerciseName.toLowerCase()];
    if (ghosts == null || setIndex >= ghosts.length) return null;
    final g = ghosts[setIndex];
    return (g.weightKg > 0 || g.reps > 0) ? g : null;
  }

  /// Returns true if [weightKg] beats the all-time PR for this exercise.
  bool _isPR(String exerciseName, double weightKg) {
    if (weightKg <= 0) return false;
    final prev = _allTimePrVolume[exerciseName.toLowerCase()];
    return prev == null || weightKg > prev;
  }

  void _initExercises() {
    final plan = widget.planDoc;
    if (plan != null && plan.exercises.isNotEmpty) {
      _exStates = plan.exercises
          .map((e) => ExerciseState(
                name: e.name,
                totalSets: e.sets,
                reps: e.reps,
                restSeconds: e.restSeconds,
              ))
          .toList();
      // Register active workout so dashboard banner is visible
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (ref.read(activeWorkoutProvider) == null) {
          ref.read(activeWorkoutProvider.notifier).startPlanWorkout(plan.title);
        }
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (ref.read(activeWorkoutProvider) == null) {
          ref.read(activeWorkoutProvider.notifier).startWorkout('Upper Body Push');
        }
      });
    }
  }

  @override
  void dispose() {
    _workoutTimer?.cancel();
    _restTimer?.cancel();
    super.dispose();
  }

  // ── Set logging ─────────────────────────────────────────────────────────────
  void _logSet(int setIndex) {
    if (_exStates.isEmpty) return;
    final ex = _exStates[_currentExIndex];
    if (setIndex >= ex.completedSets) {
      _showSetInputSheet(ex, setIndex);
    }
  }

  void _completeSetDirect() {
    if (_exStates.isEmpty) return;
    final ex = _exStates[_currentExIndex];
    if (ex.completedSets >= ex.totalSets) return;
    _showSetInputSheet(ex, ex.completedSets);
  }

  void _showSetInputSheet(ExerciseState ex, int setIndex) {
    // Use logged value → ghost value → empty, in that order
    final ghost = _ghostFor(ex.name, setIndex);
    final hasLogged = ex.setLogs[setIndex].weightKg > 0;

    final weightCtrl = TextEditingController(
        text: hasLogged
            ? ex.setLogs[setIndex].weightKg.toStringAsFixed(1)
            : (ghost != null && ghost.weightKg > 0
                ? ghost.weightKg.toStringAsFixed(1)
                : ''));
    final repsCtrl = TextEditingController(
        text: hasLogged
            ? '${ex.setLogs[setIndex].reps}'
            : (ghost != null && ghost.reps > 0
                ? '${ghost.reps}'
                : '${ex.reps}'));

    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: _SetInputSheet(
          setNumber: setIndex + 1,
          weightCtrl: weightCtrl,
          repsCtrl: repsCtrl,
          accent: widget.planDoc?.mode == 'gym'
              ? AppColors.softIndigo
              : AppColors.dynamicMint,
          onConfirm: () {
            final w = double.tryParse(weightCtrl.text) ?? 0;
            final r = int.tryParse(repsCtrl.text) ?? ex.reps;
            setState(() {
              ex.setLogs[setIndex] = SetLog(weightKg: w, reps: r);
              ex.completedSets = setIndex + 1;
            });
            Navigator.pop(context);
            _startRestTimer(ex.restSeconds.clamp(15, 300));
          },
        ),
      ),
    );
  }

  void _nextExercise() {
    if (_currentExIndex < _exStates.length - 1) {
      HapticFeedback.lightImpact();
      setState(() => _currentExIndex++);
    }
  }

  void _prevExercise() {
    if (_currentExIndex > 0) {
      HapticFeedback.lightImpact();
      setState(() => _currentExIndex--);
    }
  }

  void _startRestTimer(int seconds) {
    _restTimer?.cancel();
    setState(() {
      _isResting = true;
      _restSeconds = seconds;
      _restTotal = seconds;
    });
    _restTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        if (_restSeconds > 0) {
          _restSeconds--;
          if (_restSeconds <= 3 && _restSeconds > 0) {
            HapticFeedback.lightImpact();
          }
        } else {
          _isResting = false;
          t.cancel();
          final ex = _exStates[_currentExIndex];
          if (ex.completedSets >= ex.totalSets &&
              _currentExIndex < _exStates.length - 1) {
            Future.delayed(500.ms, () {
              if (mounted) setState(() => _currentExIndex++);
            });
          }
        }
      });
    });
  }

  void _adjustRest(int deltaSeconds) {
    setState(() {
      _restSeconds = (_restSeconds + deltaSeconds).clamp(5, 600);
      _restTotal = math.max(_restTotal, _restSeconds);
    });
    HapticFeedback.selectionClick();
  }

  String _formatTime(int secs) {
    final m = (secs ~/ 60).toString().padLeft(2, '0');
    final s = (secs % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  bool get _usingPlan => _exStates.isNotEmpty;

  int get _totalSetsCompleted =>
      _exStates.fold(0, (sum, e) => sum + e.completedSets);
  int get _totalSets =>
      _exStates.fold(0, (sum, e) => sum + e.totalSets);

  @override
  Widget build(BuildContext context) {
    if (!_usingPlan) return _buildLegacyPlayer(context);
    return _buildPlanPlayer(context);
  }

  Widget _buildPlanPlayer(BuildContext context) {
    final ex = _exStates[_currentExIndex];
    final exerciseDb = ref.watch(exerciseDbProvider);
    final matched = exerciseDb.whenOrNull(
      data: (db) {
        final lower = ex.name.toLowerCase();
        try {
          return db.firstWhere((e) =>
              e.name.toLowerCase().contains(lower) ||
              lower.contains(e.name.toLowerCase()));
        } catch (_) { return null; }
      },
    );
    final isGym = widget.planDoc?.mode == 'gym';
    final accent = isGym ? AppColors.softIndigo : AppColors.dynamicMint;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0, height: 380,
            child: _buildImmersiveExercise(ex, accent),
          ),
          Column(
            children: [
              _buildModernHeader(context, accent),
              const Spacer(),
              _buildContentCard(ex, matched, accent),
              _buildPlanBottomBar(context, ex, accent),
            ],
          ),
          if (_isResting)
            Positioned.fill(child: _buildRestOverlay(accent)),
        ],
      ),
    );
  }

  Widget _buildImmersiveExercise(ExerciseState ex, Color accent) {
    return Container(
      decoration: const BoxDecoration(color: Colors.black),
      child: Stack(
        children: [
          Positioned.fill(
            child: WgerExerciseWidget(
              exerciseName: ex.name,
              accentColor: accent,
              height: 380,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.85),
                    Colors.black,
                  ],
                  stops: const [0.0, 0.25, 0.75, 1.0],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context, Color accent) {
    final progress = _exStates.isEmpty
        ? 0.0
        : (_currentExIndex + 1) / _exStates.length;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Row(
              children: [
                _BlurCircleButton(
                  icon: PhosphorIconsRegular.caretDown,
                  onTap: () => context.pop(),
                ),
                const Spacer(),
                Column(
                  children: [
                    Text(
                      _formatTime(_elapsedSeconds),
                      style: TextStyle(
                        color: accent,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      'WORKOUT DURATION',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1),
                    ),
                  ],
                ),
                const Spacer(),
                _BlurCircleButton(
                  icon: PhosphorIconsRegular.dotsThree,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(accent),
                minHeight: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentCard(
      ExerciseState ex, ExerciseModel? matched, Color accent) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EXERCISE ${_currentExIndex + 1} OF ${_exStates.length}',
                      style: TextStyle(
                          color: accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ex.name.toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          height: 1.1),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _TopStat(label: 'SETS', value: '${ex.totalSets}'),
              const SizedBox(width: 16),
              _TopStat(label: 'REPS', value: '${ex.reps}'),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _VerticalStat(
                    label: 'DONE',
                    value: '$_totalSetsCompleted',
                    accent: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _VerticalStat(
                    label: 'REST',
                    value: '${ex.restSeconds}S',
                    accent: Colors.orangeAccent),
              ),
              if (matched != null && matched.primaryMuscles.isNotEmpty) ...[
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: accent.withValues(alpha: 0.15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('MUSCLES',
                            style: TextStyle(
                                color: accent.withValues(alpha: 0.6),
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5)),
                        const SizedBox(height: 4),
                        Text(
                          matched.primaryMuscles.take(2).join(', '),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 20),
          _buildSetGrid(ex, accent),
          const SizedBox(height: 28),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, curve: Curves.easeOut).slideY(begin: 0.05);
  }

  Widget _buildSetGrid(ExerciseState ex, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'SETS',
              style: TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5),
            ),
            Text(
              '${ex.completedSets} / ${ex.totalSets} COMPLETED',
              style: TextStyle(
                  color: accent.withValues(alpha: 0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.w900),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            SizedBox(
              width: 36,
              child: Text('SET',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1)),
            ),
            Expanded(
              child: Text('WEIGHT (kg)',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1)),
            ),
            Expanded(
              child: Text('REPS',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1)),
            ),
            const SizedBox(width: 48),
          ],
        ),
        const SizedBox(height: 8),
        ...List.generate(ex.totalSets, (i) {
          final done = i < ex.completedSets;
          final log = ex.setLogs[i];
          final ghost = _ghostFor(ex.name, i);
          final isPr = done && _isPR(ex.name, log.weightKg);

          return AppAnimatedPressable(
            onTap: done ? null : () => _logSet(i),
            child: AnimatedContainer(
              duration: 350.ms,
              margin: const EdgeInsets.only(bottom: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: done
                    ? (isPr
                        ? const Color(0xFFFFD700).withValues(alpha: 0.1)
                        : accent.withValues(alpha: 0.12))
                    : Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: done
                      ? (isPr
                          ? const Color(0xFFFFD700).withValues(alpha: 0.5)
                          : accent.withValues(alpha: 0.35))
                      : Colors.white.withValues(alpha: 0.08),
                  width: done ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  // Set number / checkmark
                  SizedBox(
                    width: 36,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: done
                            ? (isPr
                                ? const Color(0xFFFFD700)
                                : accent)
                            : Colors.white.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: done
                            ? const Icon(PhosphorIconsBold.check,
                                color: Colors.black, size: 12)
                            : Text('${i + 1}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ),

                  // Weight column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          done && log.weightKg > 0
                              ? '${log.weightKg.toStringAsFixed(1)} kg'
                              : '— kg',
                          style: TextStyle(
                              color: done
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.3),
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                        ),
                        // Ghost hint
                        if (!done && ghost != null && ghost.weightKg > 0)
                          Text(
                            'Last: ${ghost.weightKg.toStringAsFixed(1)} kg',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.28),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Reps column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          done ? '${log.reps} reps' : '${ex.reps} reps',
                          style: TextStyle(
                              color: done
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.3),
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                        ),
                        // Ghost reps hint
                        if (!done && ghost != null && ghost.reps > 0)
                          Text(
                            'Last: ${ghost.reps} reps',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.28),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // PR badge or pencil icon
                  SizedBox(
                    width: 48,
                    child: done && isPr
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: const Color(0xFFFFD700)
                                      .withValues(alpha: 0.5)),
                            ),
                            child: const Text(
                              'PR',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFFFFD700),
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          )
                            .animate()
                            .scale(
                                begin: const Offset(0.5, 0.5),
                                end: const Offset(1.0, 1.0),
                                duration: 400.ms,
                                curve: Curves.easeOutBack)
                            .fade()
                        : !done
                            ? Container(
                                width: 40,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: accent.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: accent.withValues(alpha: 0.3)),
                                ),
                                child: Icon(PhosphorIconsRegular.pencil,
                                    color: accent, size: 14),
                              )
                            : const SizedBox(width: 40),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPlanBottomBar(
      BuildContext context, ExerciseState ex, Color accent) {
    final allSetsDone = ex.completedSets >= ex.totalSets;
    final isLast = _currentExIndex == _exStates.length - 1;
    final hasNext = !isLast;
    final nextEx = hasNext ? _exStates[_currentExIndex + 1] : null;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.fromLTRB(
              20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.85),
            border: Border(
                top: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1))),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Next exercise preview strip
              if (hasNext && nextEx != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 9),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Row(
                    children: [
                      Icon(PhosphorIconsRegular.arrowRight,
                          color: Colors.white.withValues(alpha: 0.35),
                          size: 14),
                      const SizedBox(width: 8),
                      Text(
                        'NEXT UP',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.35),
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          nextEx.name,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 13,
                              fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${nextEx.totalSets}×${nextEx.reps}',
                        style: TextStyle(
                            color: accent.withValues(alpha: 0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ],

              // Nav + main CTA row
              Row(
                children: [
                  if (_currentExIndex > 0)
                    _NavButton(
                      icon: PhosphorIconsRegular.caretLeft,
                      onTap: _prevExercise,
                    ),
                  if (_currentExIndex > 0) const SizedBox(width: 12),

                  Expanded(
                    child: AppAnimatedPressable(
                      onTap: () {
                        if (allSetsDone) {
                          if (isLast) {
                            _finishWorkout(context);
                          } else {
                            _nextExercise();
                          }
                        } else {
                          _completeSetDirect();
                        }
                      },
                      child: Container(
                        height: 58,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: allSetsDone
                                ? (isLast
                                    ? [
                                        const Color(0xFFFF3D3D),
                                        const Color(0xFFFF8E3D)
                                      ]
                                    : [
                                        accent,
                                        accent.withValues(alpha: 0.7)
                                      ])
                                : [accent, accent.withValues(alpha: 0.8)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: (allSetsDone && isLast
                                      ? Colors.red
                                      : accent)
                                  .withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            allSetsDone
                                ? (isLast
                                    ? 'FINISH SESSION'
                                    : 'NEXT EXERCISE')
                                : 'LOG SET ${ex.completedSets + 1}',
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                letterSpacing: 1),
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (!isLast) const SizedBox(width: 12),
                  if (!isLast)
                    _NavButton(
                      icon: PhosphorIconsRegular.caretRight,
                      onTap: _nextExercise,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRestOverlay(Color accent) {
    return Container(
      color: Colors.black.withValues(alpha: 0.96),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'REST IN PROGRESS',
            style: TextStyle(
                color: accent,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 4),
          ),
          const SizedBox(height: 32),
          _ModernTimer(
            seconds: _restSeconds,
            total: _restTotal,
            accent: accent,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _RestAdjustButton(
                label: '-15s',
                onTap: () => _adjustRest(-15),
              ),
              const SizedBox(width: 16),
              AppAnimatedPressable(
                onTap: () {
                  _restTimer?.cancel();
                  setState(() => _isResting = false);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12)),
                  ),
                  child: const Text(
                    'SKIP REST',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        letterSpacing: 1),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              _RestAdjustButton(
                label: '+15s',
                onTap: () => _adjustRest(15),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildLegacyPlayer(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
          child: Text('Please select a valid workout plan.',
              style: TextStyle(color: Colors.white))),
    );
  }

  void _finishWorkout(BuildContext context) {
    final elapsedSnapshot = _elapsedSeconds;

    // Persist the completed exercises + sets so they can be used as ghost data next time
    final isar = ref.read(isarProvider);
    final sessionDoc = WorkoutDoc()
      ..date = DateTime.now()
      ..title = widget.planDoc?.title ?? 'Workout'
      ..durationSeconds = elapsedSnapshot
      ..source = 'pre_built'
      ..exercises = _exStates.map((ex) {
        return WorkoutExercise()
          ..name = ex.name
          ..sets = List.generate(ex.totalSets, (i) {
            final log = ex.setLogs[i];
            return WorkoutSetDoc()
              ..weightKg = log.weightKg
              ..reps = log.reps
              ..completed = i < ex.completedSets;
          });
      }).toList();

    isar.writeTxnSync(() => isar.workoutDocs.putSync(sessionDoc));

    ref
        .read(activeWorkoutProvider.notifier)
        .endWorkout(actualDurationSeconds: elapsedSnapshot);

    final data = WorkoutSummaryData(
      title: widget.planDoc?.title ?? 'Workout',
      durationSeconds: elapsedSnapshot,
      totalSets: _totalSets,
      completedSets: _totalSetsCompleted,
      exerciseCount: _exStates.length,
      exercises: List.from(_exStates),
    );

    context.pushReplacement('/workout/summary', extra: data);
  }
}

// ── Set input bottom sheet ────────────────────────────────────────────────────

class _SetInputSheet extends StatelessWidget {
  final int setNumber;
  final TextEditingController weightCtrl;
  final TextEditingController repsCtrl;
  final Color accent;
  final VoidCallback onConfirm;

  const _SetInputSheet({
    required this.setNumber,
    required this.weightCtrl,
    required this.repsCtrl,
    required this.accent,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: const BoxDecoration(
        color: Color(0xFF111318),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'LOG SET $setNumber',
            style: TextStyle(
                color: accent,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 2),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _InputField(
                  controller: weightCtrl,
                  label: 'WEIGHT (kg)',
                  hint: '0',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  accent: accent,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _InputField(
                  controller: repsCtrl,
                  label: 'REPS',
                  hint: '10',
                  keyboardType: TextInputType.number,
                  accent: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
              ),
              child: const Text(
                'CONFIRM SET',
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final Color accent;

  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.keyboardType,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.2), fontSize: 28),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.06),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: accent, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }
}

// ── Rest adjust button ────────────────────────────────────────────────────────

class _RestAdjustButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _RestAdjustButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppAnimatedPressable(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Text(
          label,
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
              letterSpacing: 0.5),
        ),
      ),
    );
  }
}

// ── Shared display widgets ────────────────────────────────────────────────────

class _TopStat extends StatelessWidget {
  final String label;
  final String value;
  const _TopStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900)),
        Text(label,
            style: const TextStyle(
                color: Colors.white38,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 1)),
      ],
    );
  }
}

class _VerticalStat extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  const _VerticalStat(
      {required this.label, required this.value, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 74,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: accent,
                  fontSize: 20,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  color: accent.withValues(alpha: 0.6),
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5)),
        ],
      ),
    );
  }
}

class _BlurCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _BlurCircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppAnimatedPressable(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppAnimatedPressable(
      onTap: onTap,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}

class _ModernTimer extends StatelessWidget {
  final int seconds;
  final int total;
  final Color accent;
  const _ModernTimer(
      {required this.seconds, required this.total, required this.accent});

  @override
  Widget build(BuildContext context) {
    final progress = seconds / math.max(1, total);
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: accent.withValues(alpha: 0.15),
                    blurRadius: 80,
                    spreadRadius: 10),
              ],
            ),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 1.0, end: progress),
            duration: const Duration(seconds: 1),
            builder: (context, value, _) => CustomPaint(
              size: const Size(220, 220),
              painter: _TimerPainter(progress: value, color: accent),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 56,
                    fontWeight: FontWeight.w200,
                    letterSpacing: -2),
              ),
              const SizedBox(height: 4),
              Text(
                'SECONDS LEFT',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimerPainter extends CustomPainter {
  final double progress;
  final Color color;
  const _TimerPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const strokeW = 6.0;

    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW
          ..color = Colors.white.withValues(alpha: 0.05));

    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
        rect,
        -math.pi / 2,
        -math.pi * 2 * progress,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW
          ..strokeCap = StrokeCap.round
          ..color = color
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2));
  }

  @override
  bool shouldRepaint(covariant _TimerPainter old) =>
      old.progress != progress;
}
