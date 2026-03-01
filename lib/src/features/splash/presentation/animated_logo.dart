import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Draws the infinity-loop logo and animates a glowing stroke
/// travelling around the path — no external packages needed.
class AnimatedInfinityLogo extends StatefulWidget {
  final double size;
  final bool isDark;

  const AnimatedInfinityLogo({
    super.key,
    this.size = 120,
    required this.isDark,
  });

  @override
  State<AnimatedInfinityLogo> createState() => _AnimatedInfinityLogoState();
}

class _AnimatedInfinityLogoState extends State<AnimatedInfinityLogo>
    with TickerProviderStateMixin {
  // Main stroke draw-on animation
  late final AnimationController _drawCtrl;
  late final Animation<double> _drawAnim;

  // Glow pulse
  late final AnimationController _glowCtrl;
  late final Animation<double> _glowAnim;

  // Rotation of the travelling spark
  late final AnimationController _sparkCtrl;
  late final Animation<double> _sparkAnim;

  // Outer ring scale-in on entry
  late final AnimationController _scaleCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    // 1. Draw stroke from 0 → 1 in 1.4 s
    _drawCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _drawAnim = CurvedAnimation(parent: _drawCtrl, curve: Curves.easeInOut);
    _drawCtrl.forward();

    // 2. Glow pulse loop
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _glowAnim = CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut);

    // 3. Spark travels around path endlessly
    _sparkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
    _sparkAnim = CurvedAnimation(parent: _sparkCtrl, curve: Curves.linear);

    // 4. Background tile scale-in
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scaleAnim = CurvedAnimation(parent: _scaleCtrl, curve: Curves.elasticOut);
    _scaleCtrl.forward();
  }

  @override
  void dispose() {
    _drawCtrl.dispose();
    _glowCtrl.dispose();
    _sparkCtrl.dispose();
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDark
        ? const Color(0xFF0B0E14) // deepObsidian
        : const Color(0xFFF4F6F9); // cloudGray
    const mintColor = Color(0xFF00D4B2);

    return AnimatedBuilder(
      animation: Listenable.merge(
          [_drawAnim, _glowAnim, _sparkAnim, _scaleAnim]),
      builder: (context, _) {
        return ScaleTransition(
          scale: _scaleAnim,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(widget.size * 0.22),
              boxShadow: [
                BoxShadow(
                  color: mintColor
                      .withOpacity(0.18 + _glowAnim.value * 0.28),
                  blurRadius: 24 + _glowAnim.value * 24,
                  spreadRadius: 2 + _glowAnim.value * 4,
                ),
              ],
              border: Border.all(
                color: mintColor.withOpacity(0.08 + _glowAnim.value * 0.12),
                width: 1.2,
              ),
            ),
            child: CustomPaint(
              painter: _InfinityPainter(
                progress: _drawAnim.value,
                glowIntensity: _glowAnim.value,
                sparkProgress: _sparkAnim.value,
                isDark: widget.isDark,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _InfinityPainter extends CustomPainter {
  final double progress;
  final double glowIntensity;
  final double sparkProgress;
  final bool isDark;

  const _InfinityPainter({
    required this.progress,
    required this.glowIntensity,
    required this.sparkProgress,
    required this.isDark,
  });

  static const Color _mint = Color(0xFF00D4B2);
  static const Color _mintDim = Color(0xFF007A66);

  /// Build the infinity path in a [size x size] box centered at (cx, cy).
  Path _buildInfinityPath(double cx, double cy, double w, double h) {
    // Lemniscate of Bernoulli parametric:
    // x = a * cos(t) / (1 + sin²(t))
    // y = a * sin(t) * cos(t) / (1 + sin²(t))
    // Scaled to fit
    final path = Path();
    const steps = 300;
    final a = w * 0.38;

    for (int i = 0; i <= steps; i++) {
      final t = (i / steps) * 2 * math.pi;
      final sin2 = math.sin(t) * math.sin(t);
      final denom = 1.0 + sin2;
      final x = cx + a * math.cos(t) / denom;
      final y = cy + a * math.sin(t) * math.cos(t) / denom;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  /// Extract position at [t] ∈ [0,1] along the infinity curve.
  Offset _positionAt(double t, double cx, double cy, double a) {
    final angle = t * 2 * math.pi;
    final sin2 = math.sin(angle) * math.sin(angle);
    final denom = 1.0 + sin2;
    return Offset(
      cx + a * math.cos(angle) / denom,
      cy + a * math.sin(angle) * math.cos(angle) / denom,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final a = size.width * 0.38;

    final path = _buildInfinityPath(cx, cy, size.width, size.height);

    // ── 1. Dim base path (full, always visible) ─────────────────────────
    final basePaint = Paint()
      ..color = _mintDim.withOpacity(isDark ? 0.25 : 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.040
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, basePaint);

    // ── 2. Animated draw-on path (trim using PathMetrics) ─────────────
    if (progress > 0) {
      final pm = path.computeMetrics().toList();
      for (final metric in pm) {
        final len = metric.length;
        final extractedPath = metric.extractPath(0, len * progress);

        // Outer glow
        final glowPaint = Paint()
          ..color = _mint.withOpacity(0.18 + glowIntensity * 0.22)
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.095
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
        canvas.drawPath(extractedPath, glowPaint);

        // Core bright stroke
        final strokePaint = Paint()
          ..shader = LinearGradient(
            colors: [
              _mint.withOpacity(0.6),
              _mint,
              const Color(0xFF41C9E2),
              _mint,
            ],
            stops: const [0.0, 0.35, 0.65, 1.0],
          ).createShader(
              Rect.fromCenter(
                  center: Offset(cx, cy),
                  width: size.width,
                  height: size.height))
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.042
          ..strokeCap = StrokeCap.round;
        canvas.drawPath(extractedPath, strokePaint);
      }
    }

    // ── 3. Travelling spark dot ────────────────────────────────────────
    if (progress >= 1.0) {
      final sparkPos = _positionAt(sparkProgress, cx, cy, a);

      // Outer halo
      final haloPaint = Paint()
        ..color = _mint.withOpacity(0.35 + glowIntensity * 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(sparkPos, size.width * 0.065, haloPaint);

      // Inner bright dot
      final dotPaint = Paint()
        ..color = Colors.white.withOpacity(0.92)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(sparkPos, size.width * 0.028, dotPaint);

      // Thin trailing arc behind the spark (last 15% of path)
      final pm = path.computeMetrics().toList();
      for (final metric in pm) {
        final totalLen = metric.length;
        final trailEnd = sparkProgress * totalLen;
        final trailStart = (trailEnd - totalLen * 0.15).clamp(0.0, totalLen);
        if (trailEnd > trailStart) {
          final trail = metric.extractPath(trailStart, trailEnd);
          final trailPaint = Paint()
            ..shader = LinearGradient(
              colors: [
                _mint.withOpacity(0.0),
                _mint.withOpacity(0.55),
              ],
            ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
            ..style = PaintingStyle.stroke
            ..strokeWidth = size.width * 0.038
            ..strokeCap = StrokeCap.round;
          canvas.drawPath(trail, trailPaint);
        }
      }
    }

    // ── 4. Centre dot ──────────────────────────────────────────────────
    if (progress > 0.4) {
      final dotOpacity = ((progress - 0.4) / 0.6).clamp(0.0, 1.0);
      final centerGlow = Paint()
        ..color = _mint.withOpacity(0.55 * dotOpacity * (0.7 + glowIntensity * 0.3))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(cx, cy), size.width * 0.05, centerGlow);

      final centerDot = Paint()
        ..color = _mint.withOpacity(dotOpacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx, cy), size.width * 0.022, centerDot);
    }
  }

  @override
  bool shouldRepaint(_InfinityPainter old) =>
      old.progress != progress ||
      old.glowIntensity != glowIntensity ||
      old.sparkProgress != sparkProgress ||
      old.isDark != isDark;
}
