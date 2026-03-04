import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:health_app/src/theme/app_colors.dart';
import '../../application/daily_activity_provider.dart';

class HeroActivityRings extends ConsumerStatefulWidget {
  const HeroActivityRings({super.key});

  @override
  ConsumerState<HeroActivityRings> createState() => _HeroActivityRingsState();
}

class _HeroActivityRingsState extends ConsumerState<HeroActivityRings>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progress;

  double _prevCalPct = 0;
  double _prevExPct = 0;
  double _prevStandPct = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _progress = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animateToNewValues() {
    if (mounted) _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dailyActivityProvider);

    final calPct =
        (state.caloriesBurned / state.caloriesBurnedGoal).clamp(0.0, 1.2);
    final exPct = state.exerciseGoalMinutes > 0
        ? (state.exerciseCompletedMinutes / state.exerciseGoalMinutes)
            .clamp(0.0, 1.2)
        : 0.0;
    final standPct = state.standGoalHours > 0
        ? (state.standCompletedHours / state.standGoalHours).clamp(0.0, 1.2)
        : 0.0;

    // Re-animate whenever values change
    if (calPct != _prevCalPct ||
        exPct != _prevExPct ||
        standPct != _prevStandPct) {
      _prevCalPct = calPct;
      _prevExPct = exPct;
      _prevStandPct = standPct;
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _animateToNewValues());
    }

    return Center(
      child: SizedBox(
        width: 260,
        height: 260,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Glow backdrop
            Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.warning.withValues(alpha: 0.08),
                    blurRadius: 60,
                    spreadRadius: 20,
                  ),
                  BoxShadow(
                    color: AppColors.dynamicMint.withValues(alpha: 0.06),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),

            // Animated rings using AnimatedBuilder so they re-animate on data change
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _progress,
                builder: (context, _) {
                  final v = _progress.value;
                  return CustomPaint(
                    painter: _GlowRingsPainter(
                      caloriesPercent: (calPct * v).clamp(0.0, 1.2),
                      exercisePercent: (exPct * v).clamp(0.0, 1.2),
                      standPercent: (standPct * v).clamp(0.0, 1.2),
                      caloriesColor: AppColors.warning,
                      exerciseColor: AppColors.dynamicMint,
                      standColor: AppColors.softIndigo,
                      trackColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.black.withValues(alpha: 0.06),
                    ),
                  );
                },
              )
                  .animate()
                  .scale(
                      duration: 800.ms,
                      begin: const Offset(0.75, 0.75),
                      curve: Curves.easeOutBack),
            ),

            // Center text — animated calorie counter
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _progress,
                  builder: (_, __) {
                    final displayVal =
                        (state.caloriesBurned * _progress.value).round();
                    return Text(
                      '$displayVal',
                      style: const TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -2,
                      ),
                    );
                  },
                ).animate().fadeIn(delay: 300.ms),
                Text(
                  'KCAL BURNED',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.45),
                  ),
                ).animate().fadeIn(delay: 500.ms),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.3),
                        width: 1),
                  ),
                  child: Text(
                    '${(calPct * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.warning,
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowRingsPainter extends CustomPainter {
  final double caloriesPercent;
  final double exercisePercent;
  final double standPercent;
  final Color caloriesColor;
  final Color exerciseColor;
  final Color standColor;
  final Color trackColor;

  _GlowRingsPainter({
    required this.caloriesPercent,
    required this.exercisePercent,
    required this.standPercent,
    required this.caloriesColor,
    required this.exerciseColor,
    required this.standColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = size.width / 2 - 4;
    const strokeW = 20.0;
    const gap = 10.0;

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round;

    const start = -math.pi / 2;
    const full = math.pi * 2;

    // --- Ring 1: Calories (outer) ---
    final r1 = maxR;
    trackPaint.color = trackColor;
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: r1), 0, full, false, trackPaint);

    if (caloriesPercent > 0) {
      progressPaint.color = caloriesColor;
      progressPaint.maskFilter =
          const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawArc(Rect.fromCircle(center: center, radius: r1), start,
          full * caloriesPercent.clamp(0, 1), false, progressPaint);
      progressPaint.maskFilter = null;
    }

    // --- Ring 2: Exercise (middle) ---
    final r2 = r1 - strokeW - gap;
    trackPaint.color = trackColor;
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: r2), 0, full, false, trackPaint);

    if (exercisePercent > 0) {
      progressPaint.color = exerciseColor;
      progressPaint.maskFilter =
          const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawArc(Rect.fromCircle(center: center, radius: r2), start,
          full * exercisePercent.clamp(0, 1), false, progressPaint);
      progressPaint.maskFilter = null;
    }

    // --- Ring 3: Stand (inner) ---
    final r3 = r2 - strokeW - gap;
    trackPaint.color = trackColor;
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: r3), 0, full, false, trackPaint);

    if (standPercent > 0) {
      progressPaint.color = standColor;
      progressPaint.maskFilter =
          const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawArc(Rect.fromCircle(center: center, radius: r3), start,
          full * standPercent.clamp(0, 1), false, progressPaint);
      progressPaint.maskFilter = null;
    }
  }

  @override
  bool shouldRepaint(covariant _GlowRingsPainter old) =>
      old.caloriesPercent != caloriesPercent ||
      old.exercisePercent != exercisePercent ||
      old.standPercent != standPercent ||
      old.trackColor != trackColor;
}
