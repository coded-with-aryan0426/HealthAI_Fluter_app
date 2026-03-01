import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:health_app/src/theme/app_colors.dart';

import '../../application/workout_plan_controller.dart';
import '../../domain/workout_plan_model.dart';

/// Inline chat card shown when the AI emits a workout plan.
/// [planJson] is the raw JSON string stored in ChatMessageDoc.text.
class WorkoutPlanCard extends ConsumerStatefulWidget {
  final String planJson;
  const WorkoutPlanCard({super.key, required this.planJson});

  @override
  ConsumerState<WorkoutPlanCard> createState() => _WorkoutPlanCardState();
}

class _WorkoutPlanCardState extends ConsumerState<WorkoutPlanCard> {
  bool _saving = false;
  bool _saved = false;
  bool _isFav = false;
  WorkoutPlanData? _plan;
  int? _savedDocId;

  @override
  void initState() {
    super.initState();
    _parsePlan();
  }

  void _parsePlan() {
    try {
      final decoded = jsonDecode(widget.planJson) as Map<String, dynamic>;
      _plan = WorkoutPlanData.fromJson(decoded);
    } catch (e) {
      debugPrint('[WorkoutPlanCard] parse error: $e');
    }
  }

  Future<void> _save() async {
    final plan = _plan;
    if (plan == null || _saving || _saved) return;
    HapticFeedback.mediumImpact();
    setState(() => _saving = true);
    try {
      final doc =
          await ref.read(workoutPlanControllerProvider.notifier).savePlan(plan);
      if (mounted) {
        setState(() {
          _saving = false;
          _saved = true;
          _savedDocId = doc.id;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${plan.title} saved to My Plans ✓'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.dynamicMint.withOpacity(0.9),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 90),
          ),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _toggleFav() async {
    HapticFeedback.lightImpact();
    if (!_saved) await _save();
    final docId = _savedDocId;
    if (docId != null) {
      await ref
          .read(workoutPlanControllerProvider.notifier)
          .toggleFavourite(docId);
      if (mounted) setState(() => _isFav = !_isFav);
    }
  }

  void _startWorkout() {
    final plan = _plan;
    if (plan == null) return;
    HapticFeedback.heavyImpact();
    context.push('/workout/preview', extra: plan);
  }

  void _viewPlan() {
    final plan = _plan;
    if (plan == null) return;
    context.push('/workout/preview', extra: plan);
  }

  @override
  Widget build(BuildContext context) {
    final plan = _plan;
    if (plan == null) {
      return Container(
        height: 80,
        alignment: Alignment.center,
        child: Text(
          'Could not load plan',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        ),
      );
    }

    final isGym = plan.mode == 'gym';
    final accent = isGym ? AppColors.softIndigo : AppColors.dynamicMint;
    final modeLabel = isGym ? 'GYM' : 'HOME';
    final modeIcon =
        isGym ? PhosphorIconsFill.barbell : PhosphorIconsFill.house;

    final previewExercises = plan.allExercises.take(4).toList();
    final remaining = plan.totalExercises - previewExercises.length;

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.08),
            Colors.black.withValues(alpha: 0.01),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.25), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 14, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(modeIcon, color: accent, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Wrap(
                          spacing: 5,
                          runSpacing: 4,
                          children: [
                            _Chip(label: modeLabel, color: accent),
                            _Chip(
                              label:
                                  '${plan.days.length} DAY${plan.days.length > 1 ? 'S' : ''}',
                              color: Colors.grey.shade600,
                            ),
                            _Chip(
                              label: '~${plan.estimatedMinutes} MIN',
                              color: Colors.grey.shade600,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                // Favourite button
                GestureDetector(
                  onTap: _toggleFav,
                  child: AnimatedContainer(
                    duration: 250.ms,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _isFav
                          ? Colors.pinkAccent.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _isFav
                          ? PhosphorIconsFill.heart
                          : PhosphorIconsRegular.heart,
                      color:
                          _isFav ? Colors.pinkAccent : Colors.grey.shade500,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Summary ─────────────────────────────────────────────────────────
          if (plan.aiSummary != null && plan.aiSummary!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Text(
                plan.aiSummary!,
                style: TextStyle(
                  fontSize: 12.5,
                  color: Colors.grey.shade400,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // ── Exercise preview list ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Column(
              children: [
                ...previewExercises.asMap().entries.map((entry) {
                  final i = entry.key;
                  final ex = entry.value;
                  return _ExerciseRow(
                    index: i + 1,
                    name: ex.name,
                    sets: ex.sets,
                    reps: ex.reps,
                    accent: accent,
                  )
                      .animate()
                      .fadeIn(delay: Duration(milliseconds: i * 50))
                      .slideX(
                          begin: 0.04,
                          end: 0,
                          delay: Duration(milliseconds: i * 50),
                          duration: 250.ms);
                }),
                if (remaining > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, bottom: 2),
                    child: GestureDetector(
                      onTap: _viewPlan,
                      child: Text(
                        '+ $remaining more exercise${remaining > 1 ? 's' : ''} — tap to view all',
                        style: TextStyle(
                          fontSize: 12,
                          color: accent.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Action buttons ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: _saved
                          ? PhosphorIconsFill.checkCircle
                          : PhosphorIconsRegular.floppyDisk,
                      label: _saved ? 'Saved ✓' : (_saving ? 'Saving…' : 'Save to My Plans'),
                    color:
                        _saved ? AppColors.dynamicMint : Colors.grey.shade400,
                    filled: false,
                    onTap: _saved ? null : _save,
                  ),
                ),
                const SizedBox(width: 10),
                  Expanded(
                    child: _ActionButton(
                      icon: PhosphorIconsRegular.listBullets,
                      label: 'View',
                      color: accent,
                      filled: false,
                      onTap: _viewPlan,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: _ActionButton(
                      icon: PhosphorIconsFill.play,
                      label: 'Start',
                      color: Colors.white,
                      filled: true,
                      fillColor: accent,
                      onTap: _startWorkout,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(
            begin: 0.06,
            end: 0,
            duration: 300.ms,
            curve: Curves.easeOutCubic);
  }
}

// ── Exercise row ──────────────────────────────────────────────────────────────
class _ExerciseRow extends StatelessWidget {
  final int index;
  final String name;
  final int sets;
  final int reps;
  final Color accent;

  const _ExerciseRow({
    required this.index,
    required this.name,
    required this.sets,
    required this.reps,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '$index',
                style: TextStyle(
                  color: accent,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '$sets × $reps',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Small chip ────────────────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

// ── Action button ─────────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool filled;
  final Color? fillColor;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.filled,
    this.fillColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = filled ? (fillColor ?? color) : color.withValues(alpha: 0.1);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: 150.ms,
        opacity: onTap == null ? 0.4 : 1.0,
        child: Container(
          height: 42,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: filled
                ? null
                : Border.all(color: color.withValues(alpha: 0.25)),
            boxShadow: filled
                ? [
                    BoxShadow(
                        color: (fillColor ?? color).withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3))
                  ]
                : null,
          ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: filled ? Colors.white : color, size: 15),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: filled ? Colors.white : color,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
        ),
      ),
    );
  }
}
