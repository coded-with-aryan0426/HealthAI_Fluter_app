import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:health_app/src/theme/app_colors.dart';
import '../../application/daily_activity_provider.dart';

class HeroActivityRings extends ConsumerWidget {
  const HeroActivityRings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dailyActivityProvider);

    final calPercent =
        (state.caloriesBurned / state.caloriesBurnedGoal).clamp(0.0, 1.2);
    final exPercent = state.exerciseGoalMinutes > 0
        ? (state.exerciseCompletedMinutes / state.exerciseGoalMinutes)
            .clamp(0.0, 1.2)
        : 0.0;
    final standPercent = state.standGoalHours > 0
        ? (state.standCompletedHours / state.standGoalHours).clamp(0.0, 1.2)
        : 0.0;

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
                    color: AppColors.warning.withOpacity(0.08),
                    blurRadius: 60,
                    spreadRadius: 20,
                  ),
                  BoxShadow(
                    color: AppColors.dynamicMint.withOpacity(0.06),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),

            // Animated rings
            Positioned.fill(
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: 1600.ms,
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return CustomPaint(
                    painter: _GlowRingsPainter(
                      caloriesPercent: (calPercent * value).clamp(0.0, 1.2),
                      exercisePercent: (exPercent * value).clamp(0.0, 1.2),
                      standPercent: (standPercent * value).clamp(0.0, 1.2),
                      caloriesColor: AppColors.warning,
                      exerciseColor: AppColors.dynamicMint,
                      standColor: AppColors.softIndigo,
                      trackColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.06)
                          : Colors.black.withOpacity(0.06),
                    ),
                  );
                },
              ).animate().scale(
                  duration: 800.ms,
                  begin: const Offset(0.75, 0.75),
                  curve: Curves.easeOutBack),
            ),

            // Center text
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: state.caloriesBurned),
                  duration: 1600.ms,
                  curve: Curves.easeOutCubic,
                  builder: (_, val, __) => Text(
                    '$val',
                    style: const TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -2,
                    ),
                  ),
                ).animate().fadeIn(delay: 300.ms),
                Text(
                  'KCAL BURNED',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
                  ),
                ).animate().fadeIn(delay: 500.ms),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.warning.withOpacity(0.3), width: 1),
                  ),
                  child: Text(
                    '${(calPercent * 100).toInt()}%',
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

    progressPaint.color = caloriesColor;
    progressPaint.maskFilter =
        MaskFilter.blur(BlurStyle.normal, caloriesPercent > 0 ? 3 : 0);
    canvas.drawArc(Rect.fromCircle(center: center, radius: r1), start,
        full * caloriesPercent.clamp(0, 1), false, progressPaint);
    progressPaint.maskFilter = null;

    // --- Ring 2: Exercise (middle) ---
    final r2 = r1 - strokeW - gap;
    trackPaint.color = trackColor;
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: r2), 0, full, false, trackPaint);

    progressPaint.color = exerciseColor;
    progressPaint.maskFilter =
        MaskFilter.blur(BlurStyle.normal, exercisePercent > 0 ? 3 : 0);
    canvas.drawArc(Rect.fromCircle(center: center, radius: r2), start,
        full * exercisePercent.clamp(0, 1), false, progressPaint);
    progressPaint.maskFilter = null;

    // --- Ring 3: Stand (inner) ---
    final r3 = r2 - strokeW - gap;
    trackPaint.color = trackColor;
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: r3), 0, full, false, trackPaint);

    progressPaint.color = standColor;
    progressPaint.maskFilter =
        MaskFilter.blur(BlurStyle.normal, standPercent > 0 ? 3 : 0);
    canvas.drawArc(Rect.fromCircle(center: center, radius: r3), start,
        full * standPercent.clamp(0, 1), false, progressPaint);
    progressPaint.maskFilter = null;
  }

  @override
  bool shouldRepaint(covariant _GlowRingsPainter old) =>
      old.caloriesPercent != caloriesPercent ||
      old.exercisePercent != exercisePercent ||
      old.standPercent != standPercent;
}
