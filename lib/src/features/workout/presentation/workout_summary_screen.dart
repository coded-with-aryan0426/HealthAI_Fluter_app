import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:health_app/src/theme/app_colors.dart';
import '../domain/workout_session_data.dart';

class WorkoutSummaryScreen extends StatelessWidget {
  final WorkoutSummaryData data;
  const WorkoutSummaryScreen({super.key, required this.data});

  String _formatTime(int secs) {
    final m = secs ~/ 60;
    final s = secs % 60;
    if (m == 0) return '${s}s';
    if (s == 0) return '${m}m';
    return '${m}m ${s}s';
  }

  // Estimated calories: ~5 kcal/min moderate intensity
  int get _estimatedCalories =>
      ((data.durationSeconds / 60) * 5).round().clamp(1, 9999);

  double get _completionRate =>
      data.totalSets == 0 ? 1.0 : data.completedSets / data.totalSets;

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.dynamicMint;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0A1628), Colors.black],
                  stops: [0.0, 0.6],
                ),
              ),
            ),
          ),

          // Glow orb
          Positioned(
            top: -60,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.dynamicMint.withValues(alpha: 0.12),
                      blurRadius: 120,
                      spreadRadius: 40,
                    ),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                children: [
                  // ── Trophy & Title ─────────────────────────────────────────
                  const SizedBox(height: 24),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.dynamicMint,
                          AppColors.softIndigo,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.dynamicMint.withValues(alpha: 0.4),
                          blurRadius: 40,
                          spreadRadius: 0,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(PhosphorIconsFill.trophy,
                        color: Colors.white, size: 46),
                  )
                      .animate()
                      .scale(
                          duration: 600.ms,
                          curve: Curves.easeOutBack,
                          begin: const Offset(0.5, 0.5))
                      .fadeIn(duration: 400.ms),

                  const SizedBox(height: 20),

                  Text(
                    'SESSION COMPLETE',
                    style: TextStyle(
                      color: accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                    ),
                  ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.3),

                  const SizedBox(height: 8),

                  Text(
                    data.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.3),

                  const SizedBox(height: 32),

                  // ── Big 3 Stats ────────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _BigStatCard(
                          icon: PhosphorIconsFill.clock,
                          value: _formatTime(data.durationSeconds),
                          label: 'Duration',
                          accent: accent,
                          delay: 400,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _BigStatCard(
                          icon: PhosphorIconsFill.fire,
                          value: '$_estimatedCalories',
                          label: 'Kcal Burned',
                          accent: const Color(0xFFFF6B35),
                          delay: 500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _BigStatCard(
                          icon: PhosphorIconsFill.barbell,
                          value: '${data.exerciseCount}',
                          label: 'Exercises',
                          accent: AppColors.softIndigo,
                          delay: 600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Completion ring card ───────────────────────────────────
                  _CompletionCard(
                    rate: _completionRate,
                    completedSets: data.completedSets,
                    totalSets: data.totalSets,
                    accent: accent,
                  ).animate(delay: 700.ms).fadeIn().slideY(begin: 0.2),

                  const SizedBox(height: 16),

                  // ── Per-exercise breakdown ─────────────────────────────────
                  _ExerciseBreakdown(
                    exercises: data.exercises,
                    accent: accent,
                  ).animate(delay: 800.ms).fadeIn().slideY(begin: 0.2),

                  const SizedBox(height: 32),

                  // ── CTA buttons ────────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        context.go('/home');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text(
                        'BACK TO HOME',
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            letterSpacing: 1),
                      ),
                    ),
                  ).animate(delay: 900.ms).fadeIn().slideY(begin: 0.2),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          context.push('/workout/progress');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.2)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text(
                          'VIEW MY PROGRESS',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              letterSpacing: 0.5),
                        ),
                      ),
                    ).animate(delay: 1000.ms).fadeIn(),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          context.pushReplacement('/workout/library');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.2)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text(
                          'VIEW WORKOUT LIBRARY',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              letterSpacing: 0.5),
                        ),
                      ),
                    ).animate(delay: 1100.ms).fadeIn(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Big stat card ─────────────────────────────────────────────────────────────

class _BigStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color accent;
  final int delay;

  const _BigStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.accent,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 11,
                fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.2);
  }
}

// ── Completion ring card ──────────────────────────────────────────────────────

class _CompletionCard extends StatelessWidget {
  final double rate;
  final int completedSets;
  final int totalSets;
  final Color accent;

  const _CompletionCard({
    required this.rate,
    required this.completedSets,
    required this.totalSets,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (rate * 100).round();
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          // Ring
          SizedBox(
            width: 90,
            height: 90,
            child: Stack(
              alignment: Alignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: rate),
                  duration: 1200.ms,
                  curve: Curves.easeOutCubic,
                  builder: (_, v, __) => CustomPaint(
                    size: const Size(90, 90),
                    painter: _RingPainter(progress: v, color: accent),
                  ),
                ),
                Text(
                  '$pct%',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'COMPLETION RATE',
                  style: TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5),
                ),
                const SizedBox(height: 8),
                Text(
                  '$completedSets of $totalSets sets',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  pct >= 100
                      ? 'Perfect session! Every set crushed.'
                      : pct >= 80
                          ? 'Excellent effort. Almost perfect!'
                          : pct >= 60
                              ? 'Solid work — keep pushing!'
                              : 'Every rep counts. Keep going!',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 13,
                      height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  const _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 7;
    const stroke = 7.0;

    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..color = Colors.white.withValues(alpha: 0.07));

    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        math.pi * 2 * progress,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..color = color);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress;
}

// ── Per-exercise breakdown ────────────────────────────────────────────────────

class _ExerciseBreakdown extends StatelessWidget {
  final List<ExerciseState> exercises;
  final Color accent;

  const _ExerciseBreakdown(
      {required this.exercises, required this.accent});

  @override
  Widget build(BuildContext context) {
    if (exercises.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'EXERCISE BREAKDOWN',
            style: TextStyle(
                color: Colors.white38,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5),
          ),
          const SizedBox(height: 16),
          ...exercises.asMap().entries.map((entry) {
            final i = entry.key;
            final ex = entry.value;
            final rate = ex.totalSets == 0
                ? 1.0
                : ex.completedSets / ex.totalSets;
            final pct = (rate * 100).round();

            // Best set stats
            double bestWeight = 0;
            int bestReps = 0;
            for (final log in ex.setLogs) {
              if (log.weightKg > bestWeight) bestWeight = log.weightKg;
              if (log.reps > bestReps) bestReps = log.reps;
            }

            return Container(
              margin: EdgeInsets.only(bottom: i < exercises.length - 1 ? 12 : 0),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: rate >= 1.0
                              ? accent.withValues(alpha: 0.2)
                              : Colors.white.withValues(alpha: 0.06),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: rate >= 1.0
                              ? Icon(PhosphorIconsBold.check,
                                  color: accent, size: 14)
                              : Text('${i + 1}',
                                  style: TextStyle(
                                      color: Colors.white
                                          .withValues(alpha: 0.5),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          ex.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${ex.completedSets}/${ex.totalSets} sets',
                        style: TextStyle(
                            color: rate >= 1.0
                                ? accent
                                : Colors.white.withValues(alpha: 0.45),
                            fontSize: 12,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  if (bestWeight > 0 || bestReps > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const SizedBox(width: 42),
                        if (bestWeight > 0)
                          _MiniChip(
                              label:
                                  'Best: ${bestWeight.toStringAsFixed(1)}kg',
                              color: accent),
                        if (bestWeight > 0 && bestReps > 0)
                          const SizedBox(width: 6),
                        if (bestReps > 0)
                          _MiniChip(
                              label: '${bestReps} reps',
                              color: Colors.white38),
                        const Spacer(),
                        // Mini progress bar
                        SizedBox(
                          width: 70,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: rate,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.08),
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(accent),
                              minHeight: 4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$pct%',
                          style: TextStyle(
                              color: accent,
                              fontSize: 11,
                              fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}
