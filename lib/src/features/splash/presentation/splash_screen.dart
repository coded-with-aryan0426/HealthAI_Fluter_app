import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'animated_logo.dart';

/// Full-screen splash shown on every cold start.
/// • Adapts background to the device's current brightness (dark / light).
/// • Logo draws itself on, spark loops, glow pulses.
/// • After [_minDisplayMs] the screen fades out automatically.
/// • Tapping the logo triggers an immediate exit.
class SplashScreen extends StatefulWidget {
  final bool showOnboarding;
  const SplashScreen({super.key, required this.showOnboarding});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // Fade-out overlay controller
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  bool _navigating = false;

  static const _minDisplayMs = 2800;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInCubic);

    // Auto-navigate after minimum display time
    Future.delayed(Duration(milliseconds: _minDisplayMs), _exitSplash);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _exitSplash() async {
    if (_navigating) return;
    _navigating = true;
    HapticFeedback.lightImpact();
    await _fadeCtrl.forward();
    if (!mounted) return;
    if (widget.showOnboarding) {
      context.go('/onboarding');
    } else {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;

    // Adaptive colours
    final bgColor = isDark
        ? const Color(0xFF0B0E14) // deepObsidian
        : const Color(0xFFF4F6F9); // cloudGray
    final subtitleColor = isDark
        ? const Color(0xFF8A91A4)
        : const Color(0xFF6B7488);
    final mintColor = const Color(0xFF00D4B2);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: bgColor,
        body: AnimatedBuilder(
          animation: _fadeAnim,
          builder: (context, child) {
            return Opacity(
              opacity: 1.0 - _fadeAnim.value,
              child: child,
            );
          },
          child: GestureDetector(
            onTap: _exitSplash,
            behavior: HitTestBehavior.opaque,
            child: Stack(
              children: [
                // ── Ambient radial glow behind logo ──────────────────────
                Center(
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          mintColor.withOpacity(isDark ? 0.12 : 0.08),
                          bgColor.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                )
                    .animate(
                      onPlay: (c) => c.repeat(reverse: true),
                    )
                    .scaleXY(
                      begin: 0.85,
                      end: 1.15,
                      duration: 3000.ms,
                      curve: Curves.easeInOut,
                    ),

                // ── Main centred content ──────────────────────────────────
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo tile — tappable
                      Hero(
                        tag: 'app_logo',
                        child: AnimatedInfinityLogo(
                          size: 128,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // App name
                      Text(
                        'HealthAI',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          color: isDark ? Colors.white : const Color(0xFF1C1E23),
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 600.ms, duration: 700.ms)
                          .slideY(begin: 0.18, end: 0),

                      const SizedBox(height: 8),

                      // Tagline
                      Text(
                        'Your AI-powered health companion',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.2,
                          color: subtitleColor,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 900.ms, duration: 700.ms)
                          .slideY(begin: 0.18, end: 0),
                    ],
                  ),
                ),

                // ── Tap-to-continue hint at the bottom ───────────────────
                Positioned(
                  bottom: 52,
                  left: 0,
                  right: 0,
                  child: Text(
                    'Tap anywhere to continue',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: subtitleColor.withOpacity(0.55),
                      letterSpacing: 0.4,
                    ),
                  )
                      .animate(
                        onPlay: (c) => c.repeat(reverse: true),
                      )
                      .fadeIn(delay: 1800.ms, duration: 600.ms)
                      .then()
                      .fadeOut(delay: 800.ms, duration: 600.ms),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
