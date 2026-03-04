import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:health_app/src/theme/app_colors.dart';
import 'animated_logo.dart';

class SplashScreen extends StatefulWidget {
  final bool showOnboarding;
  const SplashScreen({super.key, required this.showOnboarding});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;
  late final AnimationController _bgPulseCtrl;
  bool _navigating = false;

  static const _minDisplayMs = 2800;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInCubic);

    _bgPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    Future.delayed(Duration(milliseconds: _minDisplayMs), _exitSplash);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _bgPulseCtrl.dispose();
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
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final bgColor = isDark ? AppColors.deepObsidian : AppColors.cloudGray;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: bgColor,
        body: AnimatedBuilder(
          animation: _fadeAnim,
          builder: (_, child) => Opacity(
            opacity: 1.0 - _fadeAnim.value,
            child: Transform.scale(
              scale: 1.0 + _fadeAnim.value * 0.05,
              child: child,
            ),
          ),
          child: GestureDetector(
            onTap: _exitSplash,
            behavior: HitTestBehavior.opaque,
            child: Stack(
              children: [
                // ── Ambient radial glow 1 (behind logo) ─────────────────────
                Center(
                  child: AnimatedBuilder(
                    animation: _bgPulseCtrl,
                    builder: (_, __) => Container(
                      width: 340,
                      height: 340,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.dynamicMint.withValues(
                              alpha: isDark
                                  ? 0.07 + _bgPulseCtrl.value * 0.06
                                  : 0.05 + _bgPulseCtrl.value * 0.04,
                            ),
                            bgColor.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Secondary indigo glow (off-center) ──────────────────────
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.25,
                  right: -60,
                  child: AnimatedBuilder(
                    animation: _bgPulseCtrl,
                    builder: (_, __) => Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.softIndigo.withValues(
                              alpha: isDark
                                  ? 0.06 + _bgPulseCtrl.value * 0.04
                                  : 0.03,
                            ),
                            bgColor.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Main centred content ─────────────────────────────────────
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      Hero(
                        tag: 'app_logo',
                        child: AnimatedInfinityLogo(
                          size: 130,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // App name
                      Text(
                        'HealthAI',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.0,
                          height: 1.0,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 550.ms, duration: 700.ms)
                          .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),

                      const SizedBox(height: 10),

                      // Tagline
                      Text(
                        'Your AI-powered health companion',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                          color: subtitleColor,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 800.ms, duration: 700.ms)
                          .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),

                      const SizedBox(height: 40),

                      // Version / tagline pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.dynamicMint.withValues(alpha: isDark ? 0.25 : 0.2),
                          ),
                          color: AppColors.dynamicMint.withValues(alpha: isDark ? 0.08 : 0.06),
                        ),
                        child: Text(
                          'Powered by Gemma AI',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.dynamicMint,
                            letterSpacing: 0.5,
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 1100.ms, duration: 600.ms)
                          .scaleXY(
                            begin: 0.85,
                            end: 1.0,
                            delay: 1100.ms,
                            duration: 600.ms,
                            curve: Curves.easeOutBack,
                          ),
                    ],
                  ),
                ),

                // ── Tap-to-continue hint ─────────────────────────────────────
                Positioned(
                  bottom: 52,
                  left: 0,
                  right: 0,
                  child: Text(
                    'Tap anywhere to continue',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: subtitleColor.withValues(alpha: 0.5),
                      letterSpacing: 0.4,
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .fadeIn(delay: 1800.ms, duration: 700.ms)
                      .then()
                      .fadeOut(delay: 900.ms, duration: 700.ms),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
